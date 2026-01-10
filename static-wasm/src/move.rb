def current_move
  @current_move ||= {
    player: nil,
    location: nil,
    tile: nil,
    direction: nil,
  }
end

def set_current_move_player(player) = current_move.store(:player, player)
def set_current_move_location(location) = current_move.store(:location, location)
def set_current_move_tile(tile) = current_move.store(:tile, tile)
def set_current_move_direction(direction) = current_move.store(:direction, direction)

def submit_current_move
  current_game << Philosophy::Game::Placement.new(**current_move)
  complete_submission
end

def submit_choice(choice)
  current_game << Philosophy::Game::Choice.new(choice:)
  complete_submission
end

def complete_submission
  if current_game.player_options.any?
    add_listeners_to_player_options!
  else
    @current_move = nil
    set_current_state! :choose_tile_for_move
    render_game
  end
end

REPHRASE_OPTIONS = Philosophy::IdeaTile::VALID_TARGETS.values
  .map { |dir| dir.map { Philosophy::Board::TWO_CHAR_DIRECTIONS[_1] }.sort } 
def add_listeners_to_player_options!
  case current_game.player_options
  when *REPHRASE_OPTIONS # rephrase
    puts "rephrase options: #{current_game.player_options.inspect}"
    set_current_state! :choose_direction_for_choice
    coord = current_game.board[current_move[:location]].coordinate
      .translate(Philosophy::Board::Direction[current_move[:direction]])
    grid_position = coord.then { "grid-column:#{_1.col+1};grid-row:#{_1.row+1};" }

    wrapper = document.querySelector('#compass-wrapper')
    wrapper[:style] = 'pointer-events:auto;'
    compass = document.querySelector('#compass')
    compass[:style] = [
      grid_position,
      'display:grid;',
    ].join

    current_game.player_options.each do |direction|
      button = document.querySelector("#compass-#{direction}")
      button[:style] = 'display:block;'
      button.addEventListener('click') do
        select_direction(direction) if button[:style][:display] == 'block'
      end
    end
  else # choose a space
    puts "space options: #{current_game.player_options.inspect}"
    set_current_state! :choose_space_for_choice
    current_game.player_options.each do |location|
      space = document.querySelector("#space-#{location}")
      space[:classList].add 'clickable'
      space.addEventListener('click') do
        select_space(location)
      end
    end
  end
end

def deactivate_clickability_from_spaces!
  document.querySelectorAll(".space").forEach do |node|
    node[:classList].remove 'clickable'
  end
end

def add_listeners_to_playable_area!
  puts "adding listeners to playable area"
  (1..9).each do
    location = :"C#{_1}"
    puts "adding listener to #{location}"
    space = document.querySelector("#space-#{location}")
    space[:classList].add 'clickable'
    space.addEventListener('click') do
      select_space(location) if document.querySelector("#space-#{location}")[:classList].contains 'clickable'
      nil
    end
  end
end

def activate_compass!
  puts "activating compass on #{current_move[:location]}"
  wrapper = document.querySelector('#compass-wrapper')
  wrapper[:style] = 'pointer-events:auto;'
  compass = document.querySelector('#compass')
  grid_position =
    case current_move[:location]
    when :C1 then 'grid-column:3;grid-row:3;'
    when :C2 then 'grid-column:4;grid-row:3;'
    when :C3 then 'grid-column:5;grid-row:3;'
    when :C4 then 'grid-column:3;grid-row:4;'
    when :C5 then 'grid-column:4;grid-row:4;'
    when :C6 then 'grid-column:5;grid-row:4;'
    when :C7 then 'grid-column:3;grid-row:5;'
    when :C8 then 'grid-column:4;grid-row:5;'
    when :C9 then 'grid-column:5;grid-row:5;'
    end
  compass[:style] = [
    grid_position,
    'display:grid;',
  ].join
  puts grid_position
  valid_directions = Philosophy::IdeaTile::VALID_TARGETS[Philosophy::IdeaTile.registry[current_move[:tile]].target]
  Philosophy::Board::TWO_CHAR_DIRECTIONS.each_value do |direction|
    next unless valid_directions.include? Philosophy::Board::NOTATION_TO_DIRECTION[direction]
    button = document.querySelector("#compass-#{direction}")
    button[:style] = 'display:block;'
    button.addEventListener('click') do
      select_direction(direction) if button[:style][:display] == 'block'
    end
  end
end

def select_direction(direction)
  case current_state
  when :choose_direction_for_choice
    deactivate_compass!
    submit_choice direction
  when :choose_direction_for_move
    set_current_move_direction(direction)
    deactivate_compass!
    submit_current_move
  else
    puts "Invalid state for selecting direction: #{current_state}"
  end
  nil
end

def deactivate_compass!
  wrapper = document.querySelector('#compass-wrapper')
  wrapper[:style] = 'pointer-events:none;'
  compass = document.querySelector('#compass')
  compass[:style] = 'display:none;'
  compass[:childNodes].forEach do |button|
    button[:style] = 'display:none;'
  end
end

def select_space(location)
  puts "handling click on #{location}"
  case current_state
  when :choose_space_for_choice
    puts "chose #{location}"
    submit_choice(location)
    deactivate_clickability_from_spaces!
  when :choose_space_for_move
    puts "place at #{location}"
    set_current_move_location(location)
    deactivate_clickability_from_spaces!
    set_current_state! :choose_direction_for_move
    activate_compass!
  else
    puts "Invalid state for selecting space: #{current_state}"
  end
  nil
end
