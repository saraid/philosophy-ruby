module Philosophy
  class Game
    class Error < ArgumentError; end
    class InsufficientPlayers < Error; end

    def initialize(rules: Rules.default)
      @rules = rules
      @board = Board.new
      @history = History.new

      @respect = nil
      @players = []
      @current_player = @players.first
      @current_context = nil
    end
    attr_reader :current_player, :current_context

    def board_state = @current_context.to_board.notation('/')
    def player_options = @current_context.player_options.keys.sort
    def nearing_conclusion? = @current_context.to_board.nearing_conclusion?
    def concluded? = @current_context.to_board.concluded?
    def conclusions = @current_context.to_board.conclusions

    def players
      @players.each.with_object({}) { _2.merge!(Hash[ _1.color.name => _1, _1.color.code => _1]) }
    end

    def add_player(color)
      Philosophy.logger.debug("Adding player #{color}")
      @players << Player.new(color)
      @current_player = @players.first
      puts "Current: #{@current_player.color}"
      @current_context ||= ActivationContext.new(@current_player).with_spaces(@board.spaces)
    end

    def remove_player(color)
    end

    def advance_player(context)
      Philosophy.logger.debug("Advancing turn")
      @board = context.to_board
      @players << @players.shift
      @current_player = @players.first
      @current_context = ActivationContext.new(@current_player).with_spaces(@board.spaces)
    end

    def return_tiles(tiles)
      tiles.each do |tile|
        tile.owner.tile_returned(tile)
      end
    end

    def holding_respect_token = @respect
    def respect=(player)
      @respect = player
    end

    def <<(event)
      case event
      when String then Event.from_notation(event)
      when Event then event
      else raise ArgumentError, event.inspect
      end
        .then { @current_event = _1 }
        .then { @history << _1 }

      new_context = @current_event.execute(self)
      return if new_context == @current_context
      return_tiles(new_context.removed_tiles)
      @current_context =
        if new_context.player_options.empty?
          advance_player(new_context)
        else new_context
        end
    end

    class Rules
      def self.default = nil
    end

    class History
      def initialize
        @events = []
      end

      def <<(event) = @events << event
    end

    class Event
      def notation = raise NoMethodError
      def self.from_notation(notation)
        [PlayerChange, Placement, Choice, Respect]
          .find { _1::NOTATION_REGEX.match? notation }
          &.from_notation(notation)
          &.tap { raise ArgumentError, notation unless _1 }
      end

      def execute(game) = raise NoMethodError
    end

    class PlayerChange < Event
      class PlayerCodeAlreadyUsed < Game::Error; end

      NOTATION_REGEX = /(?<code>[A-Z][a-z])(?<type>[+-])(:(?<name>\w+))?/
      TYPES = {
        :+ => :joined,
        :- => :left,
      }

      def self.from_notation(notation)
        md = notation.match(NOTATION_REGEX)
        new(
          code: md[:code].to_sym,
          type: TYPES.fetch(md[:type].to_sym),
          name: md[:name]&.to_sym
        )
      end

      def initialize(code:, type:, name: nil)
        @code, @type, @name = code, type, name
        @name ||= @code
      end
      attr_reader :code, :type, :name

      def execute(game)
        raise PlayerCodeAlreadyUsed, code if type == :joined && game.players.key?(code)
        case type
        when :joined then game.add_player(Player::Color.new(name, code))
        when :left then game.remove_player(code)
        end
      end
    end

    class Placement < Event
      class Error < ArgumentError; end
      class InvalidTileType < Error; end
      class UnavailableTile < Error; end
      class InvalidLocation < Error; end
      class LocationOutsidePlacementSpace < InvalidLocation; end
      class CannotPlaceAtopExistingTile < Error; end
      class CannotOrientInTargetDirection < Error; end
      class IncorrectPlayer < Error; end

      REGEXES = {
        player: "(?<player>[A-Z][a-z]):?",
        location: "(?<location>[CNESW][we1-9])",
        tile: "(?<tile>[A-Z][a-z])",
        direction: "(?<direction>No|We|Ea|So|[NS][we])",
        parameters: "\\[?(?<parameters>(?:[A-Z][a-z1-9]|OO)*)\\]?",
        conclusion: "(?<conclusion>\\.?)",
      }
      NOTATION_REGEX = REGEXES
        .values_at(:player, :location, :tile, :direction, :parameters, :conclusion)
        .join
        .then { Regexp.new _1 }

      def self.from_notation(notation)
        md = notation.match(NOTATION_REGEX)
        new(
          player: md[:player].to_sym,
          location: md[:location].to_sym,
          tile: md[:tile].to_sym,
          direction: md[:direction].to_sym,
          parameters: md[:parameters].each_char.each_cons(2).map(&:join).map(&:to_sym),
          conclusion: md[:conclusion] == '.'
        )
      end

      def initialize(player:, location:, tile:, direction:, parameters: [], conclusion: false)
        @player, @location, @tile, @direction, @parameters, @conclusion =
          player, location, tile, direction, parameters, conclusion
        @options = {}
      end
      attr_reader :player, :location, :tile, :direction, :parameters, :options

      def conclusion? = @conclusion
      def execute(game)
        raise Game::InsufficientPlayers if game.players.size < 2
        raise IncorrectPlayer if game.current_player.color.code != player
        game.current_context
          .place(player: game.current_player, location: location, tile: tile, direction: direction)
          .make_automatic_choices!
          .then { parameters.reduce(_1, :choose) }
      end
    end

    class Choice < Event
      class Error < ArgumentError; end

      NOTATION_REGEX = /^(?<choice>[CNESW][owe1-9]|OO)$/

      def self.from_notation(notation)
        notation
          .match(NOTATION_REGEX)
          .then { _1[:choice].to_sym }
          .then { new(choice: _1) }
      end

      def initialize(choice:)
        @choice = choice
      end
      attr_reader :choice

      def execute(game) = game.current_context.choose(choice)
    end

    class Respect < Event
      NOTATION_REGEX = /^R:(?<player>[A-Z][a-z])$/

      def self.from_notation(notation)
        notation
          .match(NOTATION_REGEX)
          .then { _1[:player].to_sym }
          .then { new(player: _1) }
      end

      def initialize(player:)
        @player = player
      end
      attr_reader :player

      def execute(game)
        game.respect = player
        game.current_context
      end
    end
  end
end
