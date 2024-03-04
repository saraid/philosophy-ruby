
module Philosophy
  class Player
    Color = Data.define(:name, :code)

    private_class_method def self.players = @players ||= {}
    def self.register(color)
      new(color).then do
        players[color.code] ||= _1
        players[color.name] ||= _1
      end
    end

    def self.[](color_name_or_code) = players.fetch(color_name_or_code)

    #private_class_method :new

    def initialize(color)
      @color = color
      @tiles = IdeaTile.registry.values.uniq.map { _1.new(self) }
    end
    attr_reader :color

    private def idea(type) = @tiles.find { _1.class == IdeaTile.registry[type] }
    def has_idea?(type) = !!idea(type)
    def placed_tile(type) = @tiles.delete(idea(type))
    def tile_returned(tile) = @tiles << tile

    #def without(tile: tile_type) = Player.new(color, tiles: tiles - [idea(tile_type)])
    #def with(tile: tile_type) = Player.new(color, tiles: tiles + [ # TODO

    def notation = @color.code
    def to_s = color.to_s.capitalize
  end

  Player.register Player::Color.new(:teal, :Te)
  Player.register Player::Color.new(:indigo, :In)
  Player.register Player::Color.new(:amber, :Am)
  Player.register Player::Color.new(:sage, :Sa)

  class Lemma
    def initialize(player, key, &lemma)
    end
  end
end
