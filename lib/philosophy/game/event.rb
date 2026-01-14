module Philosophy
  class Game
    class Event
      class UnrecognizedNotation < Game::Error; end

      def self.from_notation(notation)
        [PlayerChange, Placement, Choice, Respect, RuleChange]
          .find { _1::NOTATION_REGEX.match? notation }
          &.from_notation(notation)
          .tap { raise UnrecognizedNotation, notation unless _1 }
      end
      attr_reader :context, :operations

      def execute(game) = raise NoMethodError
      def notation = raise NoMethodError
      def context=(c)
        @context = c
        @operations = c.operations
      end
    end
  end
end

require_relative 'event/choice'
require_relative 'event/placement'
require_relative 'event/player_change'
require_relative 'event/respect'
require_relative 'event/rule_change'
