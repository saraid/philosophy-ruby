module Philosophy
  class Game
    class Error < ArgumentError; end
  end
end

require_relative 'game/event'
require_relative 'game/history'
require_relative 'game/rules'

module Philosophy
  class Game
    class InsufficientPlayers < Error; end
    class DisallowedByRule < Error; end

    class Metadata
      def self.empty = new({})

      REGEX = /^\[(?<name>\w+) "(?<value>.+)"\]$/
      def self.from_pgn(notation)
        notation.each_line.with_object({}) do |line, memo|
          name, value = line.match(REGEX).values_at(:name, :value)
          memo[name.to_sym] = value
        end
          .then { new _1 }
      end

      def initialize(hash)
        @values = hash
      end

      def each(...) = @values.each(...)
      def fetch(...) = @values.fetch(...)
      def [](...) = @values.[](...)
      def []=(...)
        @values.[]=(...)
      end

      def to_pgn = @values.map { %Q![#{_1} "#{_2}"]! }.join($/)
      def to_rules
        ruleset = {}
        self[:JoinPermitted]&.then { (ruleset[:join] ||= {})[:permitted] = _1.downcase.gsub(' ', '_').to_sym }
        self[:JoinWhere]&.then { (ruleset[:join] ||= {})[:where] = _1.downcase.gsub(' ', '_').to_sym }
        self[:LeavePermitted]&.then { (ruleset[:leave] ||= {})[:permitted] = _1.downcase.gsub(' ', '_').to_sym }
        self[:LeaveEffect]&.then { (ruleset[:leave] ||= {})[:effect] = _1.downcase.gsub(' ', '_').to_sym }
        ruleset
      end
    end

    def initialize(rules: Rules.default, metadata: Metadata.empty)
      @metadata = metadata
      @rules = Rules.new(**rules)
      @board = Board.new
      @history = History.new

      @started = false
      @force_conclusion = false

      @respect = nil
      @players = []
      @current_player = @players.first
      @current_context = nil
    end
    attr_reader :current_player, :current_context
    attr_reader :board, :history
    attr_reader :metadata

    def player_order = @players.map(&:color).map(&:code)
    def board_state = @current_context.to_board.notation(delimiter: '/')
    def player_options = @current_context.player_options.keys.sort
    def board_operations = @current_context.operations.map(&:to_tuple)
    def nearing_conclusion? = @current_context.to_board.nearing_conclusion?
    def conclusions = @current_context.to_board.conclusions
    def concluded? = @force_conclusion || conclusions.one?
    def winner = conclusions.then { _1.values.first if _1.one? }
    def continuable? = !@current_context.to_board.playable_area_full? && @current_player.has_tiles?

    def started? = @started ||= !!@history.find { Placement === _1 }

    def players
      @players.each.with_object({}) { _2.merge!(Hash[ _1.color.name => _1, _1.color.code => _1]) }
    end

    def rule_change(rule:, variable:, value:) 
      @rules.change(rule:, variable:, value:)
      @metadata[:"#{rule.to_s.capitalize}#{variable.to_s.capitalize}"] =
        value.to_s.gsub('_', ' ').split(' ').map(&:capitalize).join(' ')
      @current_context
    end

    private def normalize_player_state
      @current_player = @players.first
      @current_context = ActivationContext.new(@current_player).with_spaces(@board&.spaces || {})
    end

    def add_player(color)
      Philosophy.logger.debug("Adding player #{color}")
      raise DisallowedByRule if started? && @rules.can_join.only_before_any_placement?
      previous_player_options = @current_context&.player_options || {}
      if !started? || @rules.can_join.after_a_full_turn?
        Philosophy.logger.debug("Adding player to the end")
        @players << Player.new(color)
      elsif player_options.any?
        Philosophy.logger.debug("Adding player as next player")
        @players.insert(1, Player.new(color))
      else
        Philosophy.logger.debug("Adding player to the beginning")
        @players.unshift Player.new(color)
      end
      metadata[:"Color#{color.code}"] ||= color.name unless color.code == color.name
      normalize_player_state
        .with_player_options(previous_player_options)
    end

    def remove_player(color_code)
      Philosophy.logger.debug("Removing player #{color_code}")
      raise DisallowedByRule if @rules.can_leave.never?
      raise DisallowedByRule if @rules.can_leave.only_before_any_placement? && started?
      removed_player = @players.delete(players[color_code])
      if @rules.upon_leaving.remove_their_tiles?
        @board = @current_context.without_tiles_belonging_to(removed_player).to_board
      end
      if @rules.upon_leaving.rollback_placement?
        @board = @previous_context.to_board
      end
      if @rules.upon_leaving.ends_game?
        @force_conclusion = true
      end
      normalize_player_state
    end

    def advance_player(context)
      Philosophy.logger.debug("Advancing turn")
      @board = context.to_board.reset_state
      @players << @players.shift
      normalize_player_state
    end

    def return_tiles(tiles)
      tiles.each do |tile|
        tile.owner.tile_returned(tile)
      end
    end

    def holding_respect_token = @respect
    attr_writer :respect

    def <<(event)
      case event
      when String then Event.from_notation(event)
      when Event then event
      else raise ArgumentError, event.inspect
      end
        .then { @current_event = _1 }
        .then { @history << _1 }

      @previous_context = @current_context if Placement === @current_event
      @current_event.execute(self).then do |new_context|
        next if new_context == @current_context

        return_tiles(new_context.removed_tiles)
        @current_context =
          if new_context.player_options.empty?
            advance_player(new_context)
          else new_context
          end
      end

      @current_event
    end

    def self.from_pgn(pgn)
      metadata, movetext = pgn.split("#{$/}#{$/}")
      metadata = Metadata.from_pgn(metadata)
      rules = metadata.to_rules

      game = new(rules: rules, metadata: metadata)
      movetext.each_line do
        md = _1.match(/\d+\. (?<move>.*)/)
        next if md.nil?

        game << md[:move]
      end
      game
    end
    def to_pgn = [@metadata.to_pgn, nil, @history.notation(with_ordinals: true)].join($/)
  end
end
