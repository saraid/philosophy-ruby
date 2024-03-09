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

    def initialize(rules: Rules.default)
      @rules = rules
      @board = Board.new
      @history = History.new

      @started = false

      @respect = nil
      @players = []
      @current_player = @players.first
      @current_context = nil
    end
    attr_reader :current_player, :current_context
    attr_reader :board, :history

    def player_order = @players.map(&:color).map(&:code)
    def board_state = @current_context.to_board.notation(delimiter: '/')
    def player_options = @current_context.player_options.keys.sort
    def nearing_conclusion? = @current_context.to_board.nearing_conclusion?
    def conclusions = @current_context.to_board.conclusions
    def concluded? = conclusions.one?

    def started? = @started ||= !!@history.find { Placement === _1 }

    def players
      @players.each.with_object({}) { _2.merge!(Hash[ _1.color.name => _1, _1.color.code => _1]) }
    end

    private def normalize_player_state
      @current_player = @players.first
      @current_context = ActivationContext.new(@current_player).with_spaces(@board.spaces)
    end

    def add_player(color)
      Philosophy.logger.debug("Adding player #{color}")
      raise DisallowedByRule if started? && @rules.can_join.before_any_placement?
      if !started? || @rules.can_join.after_a_full_turn?
        Philosophy.logger.debug("Adding player to the end")
        @players << Player.new(color)
      else
        Philosophy.logger.debug("Adding player to the beginning")
        @players.unshift Player.new(color)
      end
      normalize_player_state
    end

    def remove_player(color_code)
      Philosophy.logger.debug("Removing player #{color_code}")
      raise DisallowedByRule if @rules.can_leave.never?
      raise DisallowedByRule if @rules.can_leave.before_any_placement? && started?
      @players.reject! { _1.color.code == color_code }
      normalize_player_state
    end

    def advance_player(context)
      Philosophy.logger.debug("Advancing turn")
      @board = context.to_board
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
  end
end
