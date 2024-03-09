module Philosophy
  class Game
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

