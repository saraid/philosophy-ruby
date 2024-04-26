require 'json'

module Philosophy
  class Game
    class Event
      def self.from_json(json) = new(**json)
      def json_serializable = raise NoMethodError
      def to_json = json_serializable.map { [_1, public_send(_1)] }.to_h
    end

    class Choice
      def json_serializable = %i[ choice ]
    end

    class Placement
      def json_serializable = %i[ player location tile direction parameters conclusions ]
    end

    class PlayerChange
      def json_serializable = %i( code type name )
    end

    class Respect
      def json_serializable = %i( player )
    end

    class RuleChange
      def json_serializable = %i(rule variable value)
    end

    def self.from_json(json)
      json.each.with_object(new) do |event, game|
        game << event
      end
    end

    def to_json = history.map(&:to_json)
  end
end
