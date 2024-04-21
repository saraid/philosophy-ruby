module Philosophy
  class ActivationContext
    module Operation
      Place = Data.define(:player, :tile, :location, :direction) do
        def to_tuple = [:place, player.color.code, tile.name, location.name, direction]
      end
      Move = Data.define(:from_location, :impact_direction, :impact_distance) do
        def to_tuple = [:move, from_location.name, impact_direction, impact_distance]
      end
      Rotate = Data.define(:target_location, :target_direction) do
        def to_tuple = [:rotate, target_location.name, target_direction.value]
      end
    end

    def initialize(current_player)
      @current_player = current_player
      @spaces = {}
      @removed_tiles = []
      @possible_activations = Set.new
      @possible_activation_targets = Set.new
      @player_options = {}
      @operations = []
    end
    attr_reader :current_player
    attr_reader :spaces
    attr_reader :removed_tiles, :player_options
    attr_reader :possible_activations, :possible_activation_targets
    attr_reader :operations

    def [](location) = spaces[location]

    def next_context
      new_context = ActivationContext.new(current_player).with_spaces(spaces)
      removed_tiles.each { new_context.removing_tile _1 }
      possible_activations.each { new_context.can_activate _1 }
      possible_activation_targets.each { new_context.can_be_targeted _1 }
      operations.each { new_context.log _1 }
      new_context.with_player_options(@player_options)
    end
    def reset_context
      ActivationContext.new(current_player).with_spaces(spaces)
    end

    PErr = Philosophy::Game::Placement
    def place(player:, tile:, location:, direction:, testing: false)
      Philosophy.logger.debug("#place #{player.color.name} #{tile} #{location} #{direction}")
      raise PErr::InvalidTileType, tile unless IdeaTile.registry.key?(tile)
      raise PErr::InvalidLocation, location unless spaces.key?(location)
      raise PErr::LocationOutsidePlacementSpace, location unless spaces[location].playable? || testing
      raise PErr::CannotPlaceAtopExistingTile, location if spaces[location].occupied?

      tile_instance = player.placed_tile(tile)
      raise PErr::UnavailableTile, tile if tile_instance.nil?
      raise PErr::CannotOrientInTargetDirection, direction unless IdeaTile.registry[tile].valid_target?(direction)
      tile_instance.target = Board::Direction[direction]

      next_context
        .with_spaces(spaces[location].with(tile: tile_instance))
        .log(Operation::Place.new(player, tile, location, direction))
        .consider_activating(location)
    end

    def move(from_location:, impact_direction:, impact_distance: 1)
      Philosophy.logger.debug("#move #{from_location} #{impact_direction} #{impact_distance}")
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
        .log(Operation::Move.new(spaces[from_location], impact_direction, impact_distance))
        .consider_activating(target_space.coordinate)
    end

    def rotate(target_location:, target_direction:)
      direction = Board::Direction[target_direction]
      new_tile = spaces[target_location].tile.with(target: direction)
      possible_activation = spaces[spaces[target_location].coordinate.translate(direction)]
      next_context
        .with_spaces(spaces[target_location].with(tile: new_tile))
        .log(Operation::Rotate.new(spaces[target_location], target_direction))
        .consider_activating(possible_activation.coordinate)
    end

    private_class_method def self.chain(method_name)
      alias_method("_unchained_#{method_name}", method_name)
      define_method(method_name) do |*args, **kwargs|
        send("_unchained_#{method_name}", *args, **kwargs)
        self
      end
    end

    chain def log(op) = @operations << op
    chain def with_spaces(new_spaces) = spaces.merge!(new_spaces.to_h)
    chain def with_player_options(options) = @player_options = options
    chain def without_player_options = @player_options = {}
    chain def removing_tile(tile) = @removed_tiles << tile
    chain def can_activate(location) = @possible_activations << spaces[location].name
    chain def can_be_targeted(location) = @possible_activation_targets << spaces[location].name
    chain def without_tiles_belonging_to(player) 
      to_board.each
        .select { _1.tile&.owner == player }
        .map { _1.with(tile: nil) }
        .reduce(:merge)
        .then { with_spaces _1 }
    end
    chain def consider_activating(location)
      space = spaces[location]
      return without_player_options unless space&.occupied?
      if space.tile.owner.color == current_player.color
        can_activate location
      else
        can_be_targeted location
      end
        .without_player_options
        .with_chain_reactions
    end
    chain def with_chain_reactions
      activation_candidates
        .tap { Philosophy.logger.debug "with_chain_reactions: #{_1}" }
        .each
        .with_object({}) { |candidate, memo| memo[candidate] = lambda { activate(candidate) } }
        .then { with_player_options _1 }
    end

    def activation_candidates
      current_player_spaces = spaces.values.select { _1.occupied? && _1.tile.owner == current_player }
      targeting_enemy_activatables = possible_activation_targets.map do |target|
        current_player_spaces.select do |space|
          next if space.tile&.already_activated?
          space.tile.activation_target(spaces, space.name).name == target
        end.map(&:name)
      end.flatten.compact

      real_activatables = possible_activations.select do |location|
        space = spaces[location]
        next unless space.occupied?
        next if space.tile.already_activated?
        target_space = space.tile.activation_target(spaces, space.name)
        target_space.occupied? && target_space.tile.owner != current_player
      end

      Set.new(real_activatables + targeting_enemy_activatables)
    end

    def activate(location)
      Philosophy.logger.debug("#activate #{location}")
      spaces[location].tile.already_activated!
      activated_tile = spaces[location].tile
      targeted_space = activated_tile.activation_target(spaces, spaces[location].name)

      case activated_tile
      when Tile::Push, Tile::CornerPush,
        Tile::LongShot, Tile::CornerLongShot
        move(from_location: targeted_space.name, impact_direction: activated_tile.target)
      when Tile::SlideLeft
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.left)
      when Tile::SlideRight
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.right)
      when Tile::PullLeft
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.pull_left)
      when Tile::PullRight
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.pull_right)
      when Tile::Toss
        move(
          from_location: targeted_space.name,
          impact_direction: activated_tile.target.backward,
          impact_distance: 2
        )
      when Tile::Persuade
        # using collision to move yourself
        move(from_location: targeted_space.name, impact_direction: activated_tile.target.backward)
      when Tile::Decision
        target_direction = activated_tile.target
        options = {}
        options[spaces[targeted_space.coordinate.translate(target_direction.left)]&.name || :OO] = lambda do
          move(from_location: targeted_space.name, impact_direction: target_direction.left)
        end
        options[spaces[targeted_space.coordinate.translate(target_direction.right)]&.name || :OO] = lambda do
          move(from_location: targeted_space.name, impact_direction: target_direction.right)
        end
        with_player_options(options)
      when Tile::Rephrase
        ts = targeted_space.name
        IdeaTile::VALID_TARGETS[targeted_space.tile.class.target]
          .map { Board::Direction[_1] }
          .each.with_object({}) do |dir, memo|
            memo[dir.notation] = lambda do
              rotate(target_location: ts, target_direction: dir)
            end
          end
          .tap { Philosophy.logger.debug("options: #{_1.keys.sort}") }
          .then { with_player_options _1 }
      end
    end

    def make_automatic_choices!
      Philosophy.logger.debug("#make_automatic_choices! #{@player_options.size}")
      return self unless @player_options.size == 1
      choose(@player_options.keys.first)
        .make_automatic_choices!
    end

    
    def choose(option)
      Philosophy.logger.debug("#choose #{option}")
      raise Philosophy::Game::Choice::Error, option unless @player_options.key? option

      @player_options.fetch(option).call
        .make_automatic_choices!
    end

    def to_board = Board.new(spaces)
    def conclusions_count = to_board.conclusions.size
  end
end
