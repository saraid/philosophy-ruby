module Philosophy
  class Game
    def initialize(rules: Rules.default, colors: {})
      @rules, @colors = rules, colors
      @board = Board.new
      @history = History.new

      @players = []
      @current_player = @players.first
      @current_context = nil
    end
    attr_reader :current_player, :current_context
    attr_reader :players

    def board_state = @current_context.to_board.notation('/')
    def player_options = @current_context.player_options.keys.sort

    def add_player(color)
      @players << Player.new(color)
      @current_player = @players.first
      @current_context ||= ActivationContext.new(@current_player).with_spaces(@board.spaces)
    end

    def remove_player(color)
    end

    def advance_player(context)
      @board = context.to_board
      @players << @players.shift
      @current_player = @players.first
      @current_context = ActivationContext.new(@current_player).with_spaces(@board.spaces)
    end

    def update_context(&)
      raise ArgumentError, 'block required' unless block_given?
      @current_context = @current_context.instance_eval(&)
    end

    def <<(event)
      @history << (@current_event = event)
      @current_context = @current_event.execute(self)
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
        [PlayerChange, Placement, Choice]
          .find { _1::NOTATION_REGEX.match? notation }
          &.from_notation(notation)
      end
    end

    class PlayerChange < Event
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
      end
      attr_reader :code, :type, :name

      def execute(game)
        case type
        when :joined then game.add_player(Player::Color.new(name, code))
        when :left then game.remove_player(code)
        end
      end
    end

    class Placement < Event
      REGEXES = {
        player: "(?<player>[A-Z][a-z]):?",
        location: "(?<location>[CNESW][we1-9])",
        tile: "(?<tile>[A-Z][a-z])",
        direction: "(?<direction>No|We|Ea|So|[NS][we])",
        parameters: "\\[?(?<parameters>(?:[A-Z][a-z1-9])*)\\]?",
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
        new_context = game.current_context
          .place(player: game.current_player, location: location, tile: tile, direction: direction)
          .make_automatic_choices!
          .then { parameters.reduce(_1, :choose) }

        if new_context.player_options.empty?
          game.advance_player(new_context)
        else
          new_context
        end
      end
    end

    class Choice < Event
      NOTATION_REGEX = /^(?<choice>[CNESW][we1-9])$/

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

      def execute(game)
        game.current_context.choose(choice)
      end
    end
  end
end
