
module Philosophy
  class Board
    Coordinate = Data.define(:row, :col) do
      def north = self.class.new(row-1, col)
      def south = self.class.new(row+1, col)
      def east = self.class.new(row, col+1)
      def west = self.class.new(row, col-1)
      def ne = north.east
      def se = south.east
      def nw = north.west
      def sw = south.west

      def each_direction(...) = %i[ north south west east ne nw se sw ].map { [_1, translate(_1)] }.to_h.each(...)
      def translate(direction, amount = 1)
        method_name =
          case direction
          when Symbol then direction
          when Direction then direction.value
          end
        byebug if method_name.nil?
        amount.times.reduce(self) { _1.public_send(method_name) }
      end
    end

    DIRECTIONAL_KEYS = %i[ west north east south nw ne se sw ]
    UNICODE_SINGLE_ARROWS = <<~UNICODE.split($/).map { _1.split(/\s+/)[1] }.then { DIRECTIONAL_KEYS.zip(_1).to_h }
      2190	 ← 	LEFTWARDS ARROW
      2191	 ↑ 	UPWARDS ARROW
      2192	 → 	RIGHTWARDS ARROW
      2193	 ↓ 	DOWNWARDS ARROW
      2196	 ↖ 	NORTH WEST ARROW
      2197	 ↗ 	NORTH EAST ARROW
      2198	 ↘ 	SOUTH EAST ARROW
      2199	 ↙ 	SOUTH WEST ARROW
    UNICODE

    UNICODE_DOUBLE_ARROWS = <<~UNICODE.split($/).map { _1.split(/\s+/)[1] }.then { DIRECTIONAL_KEYS.zip(_1).to_h }
      21D0	 ⇐ 	LEFTWARDS DOUBLE ARROW
      21D1	 ⇑ 	UPWARDS DOUBLE ARROW
      21D2	 ⇒ 	RIGHTWARDS DOUBLE ARROW
      21D3	 ⇓ 	DOWNWARDS DOUBLE ARROW
      21D6	 ⇖ 	NORTH WEST DOUBLE ARROW
      21D7	 ⇗ 	NORTH EAST DOUBLE ARROW
      21D8	 ⇘ 	SOUTH EAST DOUBLE ARROW
      21D9	 ⇙ 	SOUTH WEST DOUBLE ARROW
    UNICODE

    TWO_CHAR_DIRECTIONS = DIRECTIONAL_KEYS.zip(%i[ We No Ea So Nw Ne Se Sw ]).to_h
    ONE_CHAR_DIRECTIONS = DIRECTIONAL_KEYS.zip(%i[ 4 2 6 8 1 3 7 5 ]).to_h

    NOTATION_TO_DIRECTION = TWO_CHAR_DIRECTIONS.invert

    Direction = Data.define(:value) do
      def self.[](value)
        case value
        when Symbol then Direction.new(NOTATION_TO_DIRECTION[value] || value)
        when Direction then value
        else raise ArgumentError, value.inspect
        end
      end

      def initialize(value:)
        raise ArgumentError, "Not allowed: #{value.inspect}" unless CLOCK.include?(value)
        super(value: value)
      end

      CLOCK = %i[ north ne east se south sw west nw ]
      def clock = CLOCK.index(value).then { CLOCK[_1..] + CLOCK[.._1] }

      def forward = self.class.new(clock[0])
      def right = self.class.new(clock[2])
      def backward = self.class.new(clock[4])
      def left = self.class.new(clock[6])
      def pull_right = self.class.new(clock[3])
      def pull_left = self.class.new(clock[5])

      def notation = TWO_CHAR_DIRECTIONS[value]
      def to_s = value.to_s
    end

    NAMED_COORDINATES = {
      [:N, 1..3] => [0, 2..4],
      [:N, 4..6] => [1, 2..4],
      [:N, :W] => [1, 1],
      [:E, 1..2] => [2, 5..6],
      [:E, 3..4] => [3, 5..6],
      [:E, 5..6] => [4, 5..6],
      [:N, :E] => [1, 5],
      [:C, 1..3] => [2, 2..4],
      [:C, 4..6] => [3, 2..4],
      [:C, 7..9] => [4, 2..4],
      [:S, :E] => [5, 5],
      [:S, 1..3] => [5, 2..4],
      [:S, 4..6] => [6, 2..4],
      [:S, :W] => [5, 1],
      [:W, 1..2] => [2, 0..2],
      [:W, 3..4] => [3, 0..2],
      [:W, 5..6] => [4, 0..2],
    }.each.with_object({}) do |(name_def, coord_def), memo|
      name1, name2 = name_def
      coord1, coord2 = coord_def

      Array(name1).zip(Array(coord1)).each do |name_1, coord_1|
        Array(name2).zip(Array(coord2)).each do |name_2, coord_2|
          memo[:"#{name_1}#{name_2}"] = Coordinate.new(coord_1, coord_2)
        end
      end
    end
    
    class Space
      def initialize(board, name, coordinate)
        @board, @name, @coordinate = board, name, coordinate
        @tile = nil
        @neighbors = {}
        @playable = name.to_s[0] == 'C'
      end
      attr_reader :name, :coordinate
      attr_reader :neighbors
      attr_accessor :tile
      def inspect = "Space(#{name}, #{coordinate})"
      def occupied? = !@tile.nil?
      def playable? = @playable

      def initialize_neighbors!
        return if @neighbors.any?
        coordinate.each_direction do |direction, neighbor|
          @neighbors[direction] = @board.spaces[neighbor] unless @board.spaces[neighbor].nil?
        end
      end

      def with(tile:)
        new_space = dup
        new_space.tile = tile

        hash = Hash.new
        hash[name] = new_space
        hash[coordinate] = new_space
        hash
      end

      def notation = "#{name}:#{tile&.notation}"
      def to_s = @name.to_s
    end

    def self.from_notation(notation)
      notation.split(%r{[\s/]+}).each.with_object(new) do |notated_space, board|
        space, player, tile, direction = notated_space
          .match(%r!(?<space>\w{2}):(?<player>\w{2})(?<tile>\w{2})(?<direction>\w{2})!)
          .values_at(:space, :player, :tile, :direction)
      end
    end

    def initialize(spaces = nil)
      @spaces = spaces || NAMED_COORDINATES.each.with_object({}) do |(name, coordinate), memo|
        space = Space.new(self, name, coordinate)
        memo[name] = space
        memo[coordinate] = space
      end
      @spaces.values.uniq.each(&:initialize_neighbors!)
    end
    attr_reader :spaces

    def inspect = "Board(#{notation(delimiter: '/')})"
    def [](location) = spaces[location]
    def each(...) = NAMED_COORDINATES.keys.map { spaces[_1] }.each(...)
    def with(tile:, on_location:) = Board.new(spaces.merge(spaces[on_location].with(tile: tile)))
    def reset_state
      each { _1.tile.reset_state if _1.occupied? }
      self
    end

    # Providing a reliable ordering.
    SPACE_NAMES = [
      (1..9).map { :"C#{_1}" },
      [:NW],
      (1..6).map { :"N#{_1}" },
      [:NE],
      (1..6).map { :"E#{_1}" },
      [:SE],
      (1..6).map { :"S#{_1}" },
      [:SW],
      (1..6).map { :"W#{_1}" },
    ].reduce(:+)
    def notation(delimiter: $/)
      SPACE_NAMES
        .map { @spaces[_1] }
        .map { _1.notation if _1.occupied? }
        .compact
        .join(delimiter)
    end

    def playable_area_full? = (1..9).map { spaces[:"C#{_1}"] }.all?(&:occupied?)

    COORDINATE_NAMES = NAMED_COORDINATES.invert
    CONCLUSIONS = COORDINATE_NAMES.each.with_object(Set.new) do |(coordinate, name), conclusions|
      coordinate.each_direction do |direction, coord2|
        name2 = COORDINATE_NAMES[coord2]
        next if name2.nil?
        name3 = COORDINATE_NAMES[coord2.translate(direction)]
        next if name3.nil?
        conclusions << Set.new([name, name2, name3])
      end
    end
    # There are only 84 possible conclusions, so let's just brute-force this.
    def conclusions
      CONCLUSIONS.select do |conclusion|
        owners = conclusion.map { spaces[_1].tile&.owner }
        owners.compact.size == 3 && owners.uniq.size == 1
      end.each.with_object({}) do |conclusion, memo|
        memo[conclusion] = spaces[conclusion.first].tile.owner
      end
    end
    def concluded? = conclusions.one?
    def nearing_conclusion?
      CONCLUSIONS.any? do |conclusion|
        owners = conclusion.map { spaces[_1].tile&.owner }
        empty_space = spaces[conclusion.find { spaces[_1].tile.nil? }]
        owners.compact.size == 2 && owners.compact.uniq.size == 1
      end
    end
  end
end
