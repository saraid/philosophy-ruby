require 'js'

# Patch require_relative to load from remote
require 'js/require_remote'

module Kernel
  alias original_require_relative require_relative

  # The require_relative may be used in the embedded Gem.
  # First try to load from the built-in filesystem, and if that fails,
  # load from the URL.
  def require_relative(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    dir = File.dirname(caller_path)
    file = File.absolute_path(path, dir)

    original_require_relative(file)
  rescue LoadError
    JS::RequireRemote.instance.load(path)
  end
end

require_relative '../lib/philosophy'
require_relative '../lib/philosophy/shims/svg'

def render_game(game)
  # clean the state
  JS.global[:document].querySelector('#error')[:innerHTML] = ""
  game.board.each do
    JS.global[:document].querySelector("#space-#{_1.name}")[:innerHTML] = _1.name.to_s
  end
  overlay = JS.global[:document].querySelector("#operations")
  JS.global[:document].querySelector("#operations")[:childNodes].forEach do |child|
    overlay.removeChild(child)
  end

  # render new state
  JS.global[:document].querySelector('#pgn')[:innerHTML] = game.to_pgn
  game.board.each.select(&:occupied?).each do
    JS.global[:document].querySelector("#space-#{_1.name}")[:innerHTML] = _1.tile.notation
  end

  puts game.last_board_operations.map(&:to_tuple).inspect
  game.last_board_operations.each do |operation|
    case operation
    #in [:place, _, _, location, _]
    when Philosophy::ActivationContext::Operation::Place
      location = operation.location.name
      current_html = JS.global[:document].querySelector("#space-#{location}")[:innerHTML]
      JS.global[:document].querySelector("#space-#{location}")[:innerHTML] = "#{current_html}<br/>#{operation.to_svg}"
    when Philosophy::ActivationContext::Operation::Rotate
      location = operation.target_location.name
      current_html = JS.global[:document].querySelector("#space-#{location}")[:innerHTML]
      JS.global[:document].querySelector("#space-#{location}")[:innerHTML] = "#{current_html}<br/>#{operation.to_svg}"
    when Philosophy::ActivationContext::Operation::Move
      grid_position =
        case operation.impact_direction.value
        when :north
          { "grid-column-start": "#{operation.from_location.coordinate.col+1};",
            "grid-column-end": "#{operation.from_location.coordinate.col+1};",
            "grid-row-start": "#{operation.from_location.coordinate.row};",
            "grid-row-end": "span #{operation.from_location.coordinate.row+1};",
          }
        when :south
          { "grid-column-start": "#{operation.from_location.coordinate.col+1};",
            "grid-column-end": "#{operation.from_location.coordinate.col+1};",
            "grid-row-start": "#{operation.from_location.coordinate.row+1};",
            "grid-row-end": "span #{operation.from_location.coordinate.row+2};",
          }
        when :west
          { "grid-column-start": "#{operation.from_location.coordinate.col};",
            "grid-column-end": "span #{operation.from_location.coordinate.col+1};",
            "grid-row-start": "#{operation.from_location.coordinate.row+1};",
            "grid-row-end": "#{operation.from_location.coordinate.row+1};",
          }
        when :east
          { "grid-column-start": "#{operation.from_location.coordinate.col+1};",
            "grid-column-end": "span #{operation.from_location.coordinate.col+2};",
            "grid-row-start": "#{operation.from_location.coordinate.row+1};",
            "grid-row-end": "#{operation.from_location.coordinate.row+1};",
          }
        when :ne
          { "grid-column-start": "#{operation.from_location.coordinate.col+1};",
            "grid-column-end": "span #{operation.from_location.coordinate.col+2};",
            "grid-row-start": "#{operation.from_location.coordinate.row};",
            "grid-row-end": "span #{operation.from_location.coordinate.row+1};",
          }
        when :se
          { "grid-column-start": "#{operation.from_location.coordinate.col+1};",
            "grid-column-end": "span #{operation.from_location.coordinate.col+2};",
            "grid-row-start": "#{operation.from_location.coordinate.row+1};",
            "grid-row-end": "span #{operation.from_location.coordinate.row+2};",
          }
        when :sw
          { "grid-column-start": "#{operation.from_location.coordinate.col};",
            "grid-column-end": "span #{operation.from_location.coordinate.col+1};",
            "grid-row-start": "#{operation.from_location.coordinate.row+1};",
            "grid-row-end": "span #{operation.from_location.coordinate.row+2};",
          }
        when :nw
          { "grid-column-start": "#{operation.from_location.coordinate.col};",
            "grid-column-end": "span #{operation.from_location.coordinate.col+1};",
            "grid-row-start": "#{operation.from_location.coordinate.row};",
            "grid-row-end": "span #{operation.from_location.coordinate.row+1};",
          }
        end.map { "#{_1}:#{_2}" }.join
      puts grid_position

      div = JS.global[:document].createElement("div")
      div[:class] = "operation-move"
      div[:style] = [
      grid_position,
        "z-index:2;"
      ].join
      div[:innerHTML] = operation.to_svg
      JS.global[:document].querySelector("#operations").appendChild(div)
    else
    end
  end
end

game = Philosophy::Game.new
game << 'In+:indigo'
game << 'Te+:teal'
game << 'In:C4PuNo'
game << 'Te:C1ToSo'
#game << 'Te:C7PuNo'
#game << 'Te:C1PuSo'
#game << 'Te:C2ReSw[Ea]'

input = JS.global[:document].querySelector('#input input')
button = JS.global[:document].querySelector('#input button')
button.addEventListener("click") do |event|
  begin
    game << input[:value].to_s
    render_game(game)
  rescue Philosophy::Game::Placement::InvalidFirstMove
    JS.global[:document].querySelector('#error')[:innerHTML] = "You may not play C5 first."
  rescue Philosophy::Game::Placement::LocationOutsidePlacementSpace
    JS.global[:document].querySelector('#error')[:innerHTML] = "You must play within the central 9 spaces."
  rescue Philosophy::Game::Placement::InvalidTileType
    JS.global[:document].querySelector('#error')[:innerHTML] = "Unrecognized tile type selected."
  rescue Philosophy::Game::Placement::UnavailableTile
    JS.global[:document].querySelector('#error')[:innerHTML] = "You've already played that tile."
  rescue Philosophy::Game::Placement::InvalidLocation
    JS.global[:document].querySelector('#error')[:innerHTML] = "This location does not exist."
  rescue Philosophy::Game::Placement::CannotPlaceAtopExistingTile
    JS.global[:document].querySelector('#error')[:innerHTML] = "A tile is already in this space. Cannot place."
  rescue Philosophy::Game::Placement::CannotOrientInTargetDirection
    JS.global[:document].querySelector('#error')[:innerHTML] = "This tile cannot be oriented in that direction."
  rescue Philosophy::Game::Placement::IncorrectPlayer
    JS.global[:document].querySelector('#error')[:innerHTML] = "It is not this player's turn."
  rescue Philosophy::Game::Choice::Error
    JS.global[:document].querySelector('#error')[:innerHTML] = "Not a valid choice."
  end
end

render_game(game)
