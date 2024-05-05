module Philosophy
  class Game
    class PlayerChange < Event
      class PlayerCodeAlreadyUsed < Game::Error; end

      NOTATION_REGEX = /(?<code>[A-Z][a-z])(?<type>[+-])(:(?<name>.+))?/
      TYPES = {
        :+ => :joined,
        :- => :left,
      }

      def self.from_notation(notation)
        md = notation.match(NOTATION_REGEX)
        new(
          code: md[:code].to_sym,
          type: TYPES.fetch(md[:type].to_sym),
          name: md[:name]&.to_sym
        )
      end

      def initialize(code:, type:, name: nil)
        @code, @type, @name = code, type, name
      end
      attr_reader :code, :type, :name

      def notation = "#{code}#{TYPES.invert.fetch(type)}"
      def execute(game)
        @name ||= game.metadata[:"Color#{code}"] || @code
        raise PlayerCodeAlreadyUsed, code if type == :joined && game.players.key?(code)

        case type
        when :joined then game.add_player(Player::Color.new(name, code))
        when :left then game.remove_player(code)
        end
      end
    end
  end
end
