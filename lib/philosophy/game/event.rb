module Philosophy
  class Game
    class Event
      def self.from_notation(notation)
        [PlayerChange, Placement, Choice, Respect, RuleChange]
          .find { _1::NOTATION_REGEX.match? notation }
          &.from_notation(notation)
          &.tap { raise ArgumentError, notation unless _1 }
      end

      def execute(game) = raise NoMethodError
      def notation = raise NoMethodError
    end
  end
end

require_relative 'event/choice'
require_relative 'event/placement'
require_relative 'event/player_change'
require_relative 'event/respect'
require_relative 'event/rule_change'
