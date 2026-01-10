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
  @current_move = nil
  render_game
end

def remove_listeners_from_playable_area!
  (1..9).each do
    document.querySelector("#space-C#{_1}")[:classList].remove 'clickable'
    #document.querySelector("#space-C#{_1}").removeEventListener('click')
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
      puts "clicked #{location}"
      if document.querySelector("#space-#{location}")[:classList].contains 'clickable'
        puts "handling click on #{location}"
        set_current_move_location(location)
        remove_listeners_from_playable_area!
        activate_compass!
      end
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
    end
  compass[:style] = [
    grid_position,
    'display:grid;',
  ].join
  Philosophy::Board::TWO_CHAR_DIRECTIONS.each_value do |direction|
    button = document.querySelector("#compass-#{direction}")
    button.addEventListener('click') do
      set_current_move_direction(direction)
      deactivate_compass!
      submit_current_move
    end
  end
end

def deactivate_compass!
  wrapper = document.querySelector('#compass-wrapper')
  wrapper[:style] = 'pointer-events:none;'
  compass = document.querySelector('#compass')
  compass[:style] = 'display:none;'
end
