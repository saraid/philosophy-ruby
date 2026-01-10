module Ux
  module Board
    module Compass
      def self.wrapper = document.querySelector('#compass-wrapper')
      def self.actual = document.querySelector('#compass')

      def self.build_elements
        wrapper = Ux.build_element element: :div, id: :'compass-wrapper'
        compass = Ux.build_element element: :div, id: :compass

        Philosophy::Board::NOTATION_TO_DIRECTION.each_key do |direction|
          button = Ux.build_element element: :button, id: "compass-#{direction}", innerHTML: direction
          button.addEventListener('click') { select_direction direction }
          compass.appendChild button
        end

        wrapper.appendChild compass
        wrapper
      end

      def self.grid_position(location)
        current_game.board[location]
          .coordinate
          .then { "grid-column:#{_1.col+1};grid-row:#{_1.row+1};" }
      end

      def self.each_button(&) = document.querySelector("#compass")[:childNodes].forEach(&)
      def self.button_for(direction) = document.querySelector("#compass-#{direction}")
      def self.activate!(location:, options: [])
        puts "Compass.activate! #{location} #{options.inspect} #{grid_position(location)}"
        wrapper[:style] = 'pointer-events:auto;'
        actual[:style] = [grid_position(location), 'display:grid;'].join
        options.each do
          button_for(Philosophy::Board::TWO_CHAR_DIRECTIONS[_1])[:style] = 'display:block;'
        end
      end

      def self.deactivate!
        wrapper[:style] = 'pointer-events:none;'
        actual[:style] = 'display:none;'
        each_button { _1[:style] = 'display:none;' }
      end

      def self.select_direction(direction)
        case Ux::State.current
        when Ux::State.choose_direction_for_choice
          deactivate!
          Ux::Move.choose! direction
        when Ux::State.choose_direction_for_move
          Ux::Move.current.store(:direction, direction)
          deactivate!
          Ux::Move.submit!
        else
          puts "Invalid state for selecting direction: #{Ux::State.current}"
        end
      end
    end
  end
end
