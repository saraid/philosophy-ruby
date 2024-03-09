module Philosophy
  class Game
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
          parameters: md[:parameters].each_char.each_slice(2).map(&:join).map(&:to_sym),
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
      def notation(parameters: [])
        option_notation = options.keys.sort.join.then { "(#{_1})" unless _1.empty? } || ''
        parameter_notation = parameters
          .join
          .then { _1.prepend '[' unless _1.empty? }
          &.then { if options.any? then _1 else _1 << ']' end } || ''
        parameter_notation << option_notation

        "#{player}:#{location}#{tile}#{direction}#{parameter_notation}#{'.' if conclusion?}"
      end
      def execute(game)
        raise Game::InsufficientPlayers if game.players.size < 2
        raise IncorrectPlayer if game.current_player.color.code != player
        game.current_context
          .place(player: game.current_player, location: location, tile: tile, direction: direction)
          .make_automatic_choices!
          .then { parameters.reduce(_1, :choose) }
          .tap { @options = _1.player_options }
      end
    end
  end
end
