require_relative 'board/compass'
require_relative 'board/space'

module Ux
  module Board
    def self.operations = document.querySelector('#operations')

    def self.clean
      current_game.board.each do
        space = Space.for(_1.name)
        space[:classList].remove Space::OCCUPIED
        space[:innerHTML] = _1.name.to_s
      end
      operations[:childNodes].forEach do |child|
        operations.removeChild(child)
      end
    end

    def self.render_occupied_spaces
      current_game.board.each.select(&:occupied?).each do
        space = Space.for _1.name
        space[:classList].add Space::OCCUPIED
        space[:innerHTML] = _1.tile.notation
        space[:title] = <<~TEXT
          Player: #{_1.tile.owner.color.name}
          Tile: #{_1.to_s}
          Direction: #{_1.tile.target}
        TEXT
      end
    end

    def self.render_operations
      puts "operations: #{current_game.last_board_operations.map(&:to_tuple)}"
      current_game.last_board_operations.each do
        case _1
        when Philosophy::ActivationContext::Operation::Place
          location = _1.location.name
          current_html = Space.for(location)[:innerHTML]
          Space.for(location)[:innerHTML] = "#{current_html}<br/>#{_1.to_svg}"
        when Philosophy::ActivationContext::Operation::Rotate
          location = _1.target_location.name
          current_html = Space.for(location)[:innerHTML]
          Space.for(location)[:innerHTML] = "#{current_html}<br/>#{_1.to_svg}"
        when Philosophy::ActivationContext::Operation::Move
          render_move_operation _1
        end
      end
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

    def self.render_conclusions
      Space.nothing_is_concluded!
      current_game.conclusions.each do |conclusion, player|
        conclusion.each do |location|
          Space.for(location)[:classList].add Space::CONCLUSION
        end
      end
    end

    def self.render
      clean
      render_occupied_spaces
      render_operations
      render_conclusions
    end

    def self.setup
      board = Ux.build_element element: :div, id: :board

      Space.build_elements
        .then { board.appendChild _1 }
      Ux.build_element(element: :div, id: :operations)
        .then { board.appendChild _1 }
      Compass.build_elements
        .then { board.appendChild _1 }

      Ux.main.appendChild board
    end
  end
end

