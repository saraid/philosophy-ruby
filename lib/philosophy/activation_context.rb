module Philosophy
  class ActivationContext
    def initialize(current_player)
      @current_player = current_player
      @spaces = {}
      @removed_tiles = []
      @possible_activations = Set.new
      @possible_activation_targets = Set.new
      @already_activated = Set.new
      @player_options = {}
    end
    attr_reader :current_player
    attr_reader :spaces
    attr_reader :removed_tiles, :player_options
    attr_reader :possible_activations, :possible_activation_targets, :already_activated

    def [](location) = spaces[location]

    def next_context
      new_context = ActivationContext.new(current_player).with_spaces(spaces)
      removed_tiles.each { new_context.removing_tile _1 }
      possible_activations.each { new_context.can_activate _1 }
      possible_activation_targets.each { new_context.can_be_activated _1 }
      already_activated.each { new_context.was_already_activated _1 }
      new_context.with_player_options(@player_options)
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
        .consider_activating(location)
    end

    def move(from_location:, impact_direction:, impact_distance: 1)
      moved_tile = spaces[from_location].tile
      target_space = spaces[spaces[from_location].coordinate.translate(impact_direction, impact_distance)]
      if target_space.nil?
        return next_context
          .with_spaces(spaces[from_location].with(tile: nil))
          .removing_tile(moved_tile)
      end

      if target_space.occupied?
        move(from_location: target_space.coordinate, impact_direction: impact_direction)
      else
        next_context
      end
        .with_spaces(spaces[from_location].with(tile: nil))
        .with_spaces(target_space.with(tile: moved_tile))
        .consider_activating(target_space.coordinate)
    end

    def rotate(target_location:, target_direction:)
      direction = Board::Direction[target_direction]
      new_tile = spaces[target_location].tile.with(target: direction)
      possible_activation = spaces[spaces[target_location].coordinate.translate(direction)]
      next_context
        .with_spaces(spaces[target_location].with(tile: new_tile))
        .consider_activating(possible_activation.coordinate)
    end

    private_class_method def self.chain(method_name)
      alias_method("_unchained_#{method_name}", method_name)
      define_method(method_name) do |*args, **kwargs|
        send("_unchained_#{method_name}", *args, **kwargs)
        self
      end
    end

    chain def with_spaces(new_spaces) = spaces.merge!(new_spaces.to_h)
    chain def with_player_options(options) = @player_options = options
    chain def removing_tile(tile) = @removed_tiles << tile
    chain def can_activate(location) = @possible_activations << spaces[location].name
    chain def can_be_activated(location) = @possible_activation_targets << spaces[location].name
    chain def was_already_activated(location) = @already_activated << spaces[location].name
    chain def consider_activating(location)
      space = spaces[location]
      return unless space&.occupied?
      if space.tile.owner == current_player
        can_activate location
      else
        can_be_activated location
      end
    end

    def activation_candidates
      current_player_spaces = spaces.values.select { _1.occupied? && _1.tile.owner == current_player }
      targeting_enemy_activatables = possible_activation_targets.map do |target|
        current_player_spaces.select do |space|
          space.tile.activation_target(spaces, space.name).name == target
        end.map(&:name)
      end.flatten.compact

      real_activatables = possible_activations.select do |location|
        space = spaces[location]
        target_space = space.tile.activation_target(spaces, space.name)
        target_space.occupied? && target_space.tile.owner != current_player
      end

      Set.new(real_activatables + targeting_enemy_activatables) - already_activated
    end

    def activate(location)
      @already_activated << spaces[location].name
      activated_tile = spaces[location].tile
      targeted_space = activated_tile.activation_target(spaces, spaces[location].name)

      case activated_tile
      when Tile::Push, Tile::CornerPush,
        Tile::SlideLeft, Tile::SlideRight,
        Tile::LongShot, Tile::CornerLongShot
        move(from_location: targeted_space.name, impact_direction: activated_tile.target)
      when Tile::PullLeft
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.pull_left)
      when Tile::PullRight
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.pull_right)
      when Tile::Toss
        move(from_location: targeted_space.name,
             impact_direction: activated_tile.target.backward,
             impact_distance: 2
            )
      when Tile::Persuade
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.backward)
      when Tile::Decision
        target_direction = activated_tile.target
        options = {}
        options[spaces[targeted_space.coordinate.translate(target_direction.left)].name] =
          lambda { move(from_location: targeted_space.name, impact_direction: target_direction.left) }
        options[spaces[targeted_space.coordinate.translate(target_direction.right)].name] =
          lambda { move(from_location: targeted_space.name, impact_direction: target_direction.right) }
        with_player_options(options)
      when Tile::Rephrase
        ts = targeted_space.name
        IdeaTile::VALID_TARGETS[targeted_space.tile.class.target]
          .map { Board::Direction[_1] }
          .each.with_object({}) do |dir, memo|
            memo[dir.notation] = lambda { rotate(target_location: ts, target_direction: dir) }
          end
          .then { with_player_options _1 }
      end
    end

    def choose(option)
      raise ArgumentError unless @player_options.key? option

      @player_options.fetch(option).call
    end

    def to_board = Board.new(spaces)
  end
end
