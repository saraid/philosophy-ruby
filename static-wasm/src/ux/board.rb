require_relative 'board/compass'
require_relative 'board/space'
require_relative 'board/tile'

module Ux
  module Board
    def self.operations = document.querySelector('#operations')
    def self.tiles = document.querySelector('#tiles')

    def self.grid_position(location)
      current_game.board[location]
        .coordinate
        .then { "grid-column:#{_1.col+1};grid-row:#{_1.row+1};" }
    end

    def self.clean
      Philosophy::Board::NAMED_COORDINATES.each_key do
        space = Space.for(_1.name)
        space[:classList].remove Space::OCCUPIED
        space[:innerHTML] = _1.name.to_s
      end

      tiles[:innerHTML] = ''
      operations[:innerHTML] = ''
      nil
    end

    def self.render_occupied_spaces(context, activated_tiles)
      context.to_board.each.select(&:occupied?).each do
        space = Space.for _1.name
        space[:classList].add Space::OCCUPIED
        Tile.place(_1, activated: activated_tiles.include?(_1.tile))
      end
    end

    def self.render_operations(ops)
      puts "operations: #{ops.map(&:to_tuple)}"
      ops.each do
        case _1
        when Philosophy::ActivationContext::Operation::Place
          location = _1.location.name
          Ux.build_element(element: :div, innerHTML: _1.to_svg, style: grid_position(location.to_sym))
            .then { |node| operations.appendChild node }
        when Philosophy::ActivationContext::Operation::Rotate
          location = _1.target_location.name
          style = [grid_position(location.to_sym), 'fill:red;opacity:0.5'].join
          Ux.build_element(element: :div, innerHTML: _1.to_svg, style:)
            .then { |node| operations.appendChild node }
        when Philosophy::ActivationContext::Operation::Move
          render_move_operation _1
        end
      end
      nil
    end

    def self.render_move_operation(operation)
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
        ].join

      Ux.build_element(
        element: :div, classes: %w[ operation-move ], style: [grid_position, 'z-index:2;'].join,
        innerHTML: operation.to_svg
      ).then { operations.appendChild _1 }
    end

    def self.render_conclusions(context)
      Space.nothing_is_concluded!
      context.to_board.conclusions.each do |conclusion, player|
        conclusion.each do |location|
          Space.for(location)[:classList].add Space::CONCLUSION
        end
      end
    end

    def self.render(context = current_game.current_context,
                    operations = current_game.last_board_operations,
                    activated_tiles = current_game.last_activated_tiles
                   )
      clean
      render_occupied_spaces(context, activated_tiles)
      render_operations(operations)
      render_conclusions(context)
      if current_game.concluded?
        Ux::Console::Pgn.element[:classList].add "bgcolor-#{current_game.conclusions.first.last.color.code}"
      end
      nil
    end

    def self.setup
      board = Ux.build_element element: :div, id: :board

      Space.build_elements
        .then { board.appendChild _1 }
      Ux.build_element(element: :div, id: :tiles)
        .then { board.appendChild _1 }
      Ux.build_element(element: :div, id: :operations)
        .then { board.appendChild _1 }
      Compass.build_elements
        .then { board.appendChild _1 }

      Ux.main.appendChild board
    end
  end
end

