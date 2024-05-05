require 'philosophy'
require 'json'

module Philosophy
  class Player
    def to_h
      { color: {
          code: color.code,
          name: color.name
        },
        tiles: tiles
      }
    end
  end

  class Game
    class Event
      def self.from_json(json) = new(**json)
      def json_serializable = raise NoMethodError
      def to_h = json_serializable.map { [_1, public_send(_1)] }.to_h
      def to_json = to_h.to_json
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

    class History
      def to_h = @events.map(&:to_h)
    end

    def self.from_json(json)
      json.each.with_object(new) do |event, game|
        game << event
      end
    end

    def to_h
      { history: history.map(&:to_h),
        current_player: current_player.color.code,
        player_options: player_options,
        players: @players.map(&:to_h)
      }
    end
  end
end
