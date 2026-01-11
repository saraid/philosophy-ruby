module Ux
  module Board
    module Space
      CLICKABLE = 'clickable'
      CONCLUSION = 'conclusion'
      OCCUPIED = 'occupied'

      def self.for(location) = document.querySelector("#space-#{location}")

      def self.build_elements
        spaces = Ux.build_element element: :div, id: :spaces
        current_game.board.each do |space|
          classes = %W[ space space-#{space.name} ]
          classes << 'playable' if space.playable?
          Ux.build_element(element: :div, id: "space-#{space.name}", classes:, innerHTML: space.name)
            .tap { _1.addEventListener('click') { select space.name } }
            .tap { _1.addEventListener('mouseover') { mouseover space.name } }
            #.tap { _1.addEventListener('mouseout') { mouseout space.name } }
            .then { spaces.appendChild _1 }
        end
        spaces
      end

      def self.mouseover(location)
        Ux.debounce(id: "mouseover-#{location}", timeout: 200.milliseconds) do
          case Ux::State.current
          when Ux::State.choose_space_for_move, Ux::State.choose_direction_for_move
            return unless current_game.board[location].playable?
            Ux::Move.current.store(:location, location)
            Ux::Move.current.store(:direction, nil)
            Ux::State.set_to Ux::State.choose_direction_for_move
            options = Philosophy::IdeaTile::VALID_TARGETS[Philosophy::IdeaTile.registry[Ux::Move.current[:tile]].target]
            Compass.activate!(location:, options:)
          end
        end
        nil
      end

      def self.select(location)
        case Ux::State.current
        when Ux::State.choose_space_for_choice
          Ux::Move.choose! location
          nothing_is_clickable!
        when Ux::State.choose_space_for_move, Ux::State.choose_direction_for_move
          Ux::Move.current.store(:location, location)
          Ux::Move.current.store(:direction, nil)
          Ux::State.set_to Ux::State.choose_direction_for_move
          options = Philosophy::IdeaTile::VALID_TARGETS[Philosophy::IdeaTile.registry[Ux::Move.current[:tile]].target]
          Compass.activate!(location:, options:)
        else
          puts "Invalid state for selecting space: #{Ux::State.current}"
        end
        nil
      end

      def self.all = document.querySelectorAll(".space")
      def self.playable
        if current_game.started?
          document.querySelectorAll('.space.playable:not(.occupied)')
        else
          document.querySelectorAll('.space.playable:not(#space-C5)')
        end
      end
      def self.nothing_is_clickable! = all.forEach { _1[:classList].remove CLICKABLE }
      def self.clickable!(spaces: playable) = spaces.forEach { _1[:classList].add CLICKABLE }
      def self.nothing_is_concluded! = all.forEach { _1[:classList].remove CONCLUSION }
    end
  end
end
