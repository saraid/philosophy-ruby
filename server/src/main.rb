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
require_relative 'move'
require_relative 'player'
require_relative 'tests'

def document = JS.global[:document]

def update_pgn = JS.global[:document].querySelector('#pgn')[:innerHTML] = current_game.to_pgn

def render_game(game = current_game)
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
  render_all_players
  update_pgn
  game.board.each.select(&:occupied?).each do
    JS.global[:document].querySelector("#space-#{_1.name}")[:innerHTML] = _1.tile.notation
  end

  game.last_board_operations.each do |operation|
    case operation
    when Philosophy::ActivationContext::Operation::Place
      location = operation.location.name
      current_html = JS.global[:document].querySelector("#space-#{location}")[:innerHTML]
      JS.global[:document].querySelector("#space-#{location}")[:innerHTML] = "#{current_html}<br/>#{operation.to_svg}"
    when Philosophy::ActivationContext::Operation::Rotate
      location = operation.target_location.name
      current_html = JS.global[:document].querySelector("#space-#{location}")[:innerHTML]
      JS.global[:document].querySelector("#space-#{location}")[:innerHTML] = "#{current_html}<br/>#{operation.to_svg}"
    when Philosophy::ActivationContext::Operation::Move
      from_location = operation.from_location.coordinate
      start_column = from_location.col + 1
      end_column =
        case operation.impact_direction.value
        when :east, :ne, :se then start_column + operation.impact_distance
        when :west, :nw, :sw then start_column - operation.impact_distance
        else start_column
        end
      start_row = from_location.row + 1
      end_row =
        case operation.impact_direction.value
        when :north, :nw, :ne then start_row - operation.impact_distance
        when :south, :sw, :se then start_row + operation.impact_distance
        else start_row
        end
      grid_position =
        [ [start_column, end_column].sort.then { "grid-column-start:#{_1};grid-column-end:span #{_2};" },
          [start_row, end_row].sort.then { "grid-row-start:#{_1};grid-row-end:span #{_2};" },
        ].join#.tap { puts "v2: #{_1}" }

      div = JS.global[:document].createElement("div")
      div[:class] = "operation-move"
      div[:style] = [
        grid_position,
        "z-index:2;"
      ].join
      div[:innerHTML] = operation.to_svg
      JS.global[:document].querySelector("#operations").appendChild(div)
    else
      puts "unknown operation: #{operation.inspect}"
    end
  end
  nil # return nil to stop a mystery error about JS::Object#call receiving a non-JS::Object on arg 2.
end

def current_game = @current_game
@current_game = Philosophy::Game.new

def input  = document.querySelector('#input input')
def submit_movetext
  begin
    current_game << input[:value].to_s
    render_game
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
document.querySelector('#input button').call(:addEventListener, "click") { |event| submit_movetext }
input.addEventListener("keypress") do |event|
  case event[:key].to_s
  when 'Enter'
    submit_movetext
  else
    #puts event[:key].inspect
  end
end

render_game
