
module Philosophy
  class Game
    def initialize(rules: Rules.default, players: [], lemmas: {})
    end

    class Rules
      def self.default = nil
    end

    class Event
    end

    class PlayerChange < Event
    end

    class Placement < Event
      def initialize(player:, space:, tile:, direction:)
      end
    end

    class Action
    end
  end
end
