
module Philosophy
  class Game
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
  end
end
