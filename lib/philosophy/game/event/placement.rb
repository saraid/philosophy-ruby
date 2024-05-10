module Philosophy
  class Game
    class Placement < Event
      class Error < ArgumentError; end
      class InvalidTileType < Error; end
      class UnavailableTile < Error; end
      class InvalidLocation < Error; end
      class InvalidFirstMove < InvalidLocation; end
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
        conclusions: "(?<conclusions>\\.*)?",
      }
      NOTATION_REGEX = REGEXES
        .values_at(:player, :location, :tile, :direction, :parameters, :conclusions)
        .join
        .then { Regexp.new _1 }

      def self.from_notation(notation)
        md = notation.match(NOTATION_REGEX)
        new(
          player: md[:player].to_sym,
          location: md[:location].to_sym,
          tile: md[:tile].to_sym,
          direction: md[:direction].to_sym,
          parameters: md[:parameters].each_char.each_slice(2).map(&:join).map(&:to_sym),
          conclusions: md[:conclusions].size
        )
      end

      def initialize(player:, location:, tile:, direction:, parameters: [], conclusions: 0)
        @player, @location, @tile, @direction, @parameters, @conclusions =
          player, location, tile, direction, parameters, conclusions
        @options = {}
      end
      attr_reader :player, :location, :tile, :direction, :parameters, :conclusions, :options

      def notation(parameters: [], options: {})
        option_notation = options.keys.sort.join.then { "(#{_1})" unless _1.empty? } || ''
        parameter_notation = parameters
          .join
          .then { _1.prepend '[' unless _1.empty? }
          &.then { if options.any? then _1 else _1 << ']' end } || ''
        parameter_notation << option_notation
        conclusion_notation = conclusions.times.map { '.' }.join

        "#{player}:#{location}#{tile}#{direction}#{parameter_notation}#{conclusion_notation}"
      end
      def execute(game)
        raise Game::InsufficientPlayers if game.players.size < 2
        raise IncorrectPlayer if game.current_player.color.code != player
        raise InvalidFirstMove if game.first_move?(self) && location == :C5
        game.current_context
          .place(player: game.current_player, location: location, tile: tile, direction: direction)
          .make_automatic_choices!
          .then { parameters.reduce(_1, :choose) }
          .tap { @options = _1.player_options }
          .tap { @conclusions = _1.conclusions_count }
      end
    end
  end
end
