module Philosophy
  class ActivationContext
    def initialize(current_player)
      @current_player = current_player
      @spaces = {}
      @removed_tiles = []
      @possible_activations = Set.new
      @possible_activation_targets = Set.new
    end
    attr_reader :current_player
    attr_reader :spaces
    attr_reader :removed_tiles
    attr_reader :possible_activations, :possible_activation_targets

    def next_context
      new_context = ActivationContext.new(current_player).with_spaces(spaces)
      removed_tiles.each { new_context.removing_tile _1 }
      possible_activations.each { new_context.can_activate _1 }
      possible_activation_targets.each { new_context.can_be_activated _1 }
      new_context
    end
    def reset_context = ActivationContext.new(current_player).with_spaces(spaces)

    class PlacementError < ArgumentError; end
    class InvalidTileType < PlacementError; end
    class UnavailableTile < PlacementError; end
    class InvalidCoordinate < PlacementError; end
    class CoordinateOutsidePlacementSpace < InvalidCoordinate; end
    class CannotPlaceAtopExistingTile < PlacementError; end
    class CannotOrientInTargetDirection < PlacementError; end
    def place(player:, tile:, location:, direction:)
      raise CannotPlaceAtopExistingTile if spaces[location].occupied?

      tile_instance = player.placed_tile(tile)
      tile_instance.target = Board::Direction[direction]

      next_context
        .with_spaces(spaces[location].with(tile: tile_instance))
        .can_activate(location)
    end

    def move(from_location:, impact_direction:, impact_distance: 1)
      moved_tile = spaces[from_location].tile
      target_space = spaces[spaces[from_location].coordinate.translate(impact_direction, impact_distance)]
      if target_space.nil?
        return next_context
          .with_spaces(spaces[from_location].with(tile: nil))
          .removing_tile(moved_tile)
      end

      context_with_collisions_resolved =
        if target_space.occupied?
          move(from_location: target_space.coordinate, impact_direction: impact_direction)
        end
      next_context
        .with_spaces(context_with_collisions_resolved&.spaces)
        .with_spaces(spaces[from_location].with(tile: nil))
        .with_spaces(target_space.with(tile: moved_tile))
    end

    def rotate(target_location:, target_direction:)
      direction = Board::Direction[target_direction]
      new_tile = spaces[target_location].tile.with(target: direction)
      context = next_context
        .with_spaces(spaces[target_location].with(tile: new_tile))

      possible_activation = spaces[spaces[target_location].coordinate.translate(direction)]
      if possible_activation.occupied?
        if possible_activation.tile.owner == current_player
          context.can_activate(possible_activation.coordinate)
        else
          context.can_be_activated(possible_activation.coordinate)
        end
      end
      context
    end

    private_class_method def self.chain(method_name)
      alias_method("_unchained_#{method_name}", method_name)
      define_method(method_name) do |*args, **kwargs|
        send("_unchained_#{method_name}", *args, **kwargs)
        self
      end
    end

    chain def with_spaces(new_spaces) = spaces.merge!(new_spaces.to_h)
    chain def removing_tile(tile) = @removed_tiles << tile
    chain def can_activate(location) = @possible_activations << spaces[location].name
    chain def can_be_activated(location) = @possible_activation_targets << spaces[location].name

    def to_board = Board.new(spaces)
  end
end
