
module Philosophy
  class Player
    COLORS = {
      teal: :Te,
      indigo: :In,
      amber: :Am,
      sage: :Sa,
    }

    private_class_method def self.players = @player ||= {}
    COLORS.keys.each { |color| define_singleton_method(color) { players[color] ||= new(color) } }
    private_class_method :new

    def initialize(color, tiles: nil, lemmas: [])
      raise ArgumentError, "Unknown color #{color.inspect}" unless COLORS.key?(color)
      @color = color
      @tiles = tiles || IdeaTile.registry.values.uniq.map { _1.new(self) }
      @lemmas = lemmas
    end
    attr_reader :color
    attr_accessor :lemmas

    private def idea(type) = @tiles.find { _1.class == IdeaTile.registry[type] }
    def has_idea?(type) = !!idea(type)
    def placed_tile(type) = @tiles.delete(idea(type))
    def tile_returned(tile) = @tiles << tile

    def without(tile: tile_type) = Player.new(color, tiles: tiles - [idea(tile_type)])
    #def with(tile: tile_type) = Player.new(color, tiles: tiles + [ # TODO

    def notation = COLORS[color]
    def to_s = color.to_s.capitalize

    def choose_lemma!(index = 0)
      @lemmas[index]&.execute!
      @lemmas.clear
    end
  end
end
