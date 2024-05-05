module Philosophy
  class Player
    Color = Data.define(:name, :code)

    def initialize(color)
      @color = color
      @tiles = IdeaTile.registry.values.uniq.map { _1.new(self) }
    end
    attr_reader :color

    def tiles = @tiles.map(&:class).map(&:key)

    private def idea(type) = @tiles.find { _1.class == IdeaTile.registry[type] }
    def has_idea?(type) = !!idea(type)
    def placed_tile(type) = @tiles.delete(idea(type))
    def tile_returned(tile) = @tiles << tile
    def has_tiles? = @tiles.any?

    def notation = @color.code
    def to_s = color.to_s.capitalize
  end
end
