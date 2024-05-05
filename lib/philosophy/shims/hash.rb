require 'philosophy'

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
      def serializable = raise NoMethodError, self.class.name
      def to_h = serializable.map { [_1, public_send(_1)] }.to_h
    end

    class Choice
      def serializable = %i[ choice ]
    end

    class Placement
      def serializable = %i[ player location tile direction parameters conclusions ]
    end

    class PlayerChange
      def serializable = %i( code type name )
    end

    class Respect
      def serializable = %i( player )
    end

    class RuleChange
      def serializable = %i(rule variable value)
    end

    class Board
      class Space
        def to_h
          { tile: tile.class.key,
            owner: tile.owner.color.code,
            direction: tile.direction,
          }
        end
      end

      def to_h
        SPACE_NAMES
          .map { @spaces[_1] }
          .each.with_object({}) { _2[_1.name] = _1.to_h if _1.occupied? }
      end
    end

    class History
      def to_h = @events.map(&:to_h)
    end

    def self.from_events(events)
      events.each.with_object(new) do |event, game|
        game << event
      end
    end

    def to_h
      { history: history.map(&:to_h),
        current_player: current_player.color.code,
        player_options: player_options,
        players: @players.map(&:to_h),
        board: @current_context.to_board.to_h
      }
    end
  end
end
