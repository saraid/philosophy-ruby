module Ux
  module Board
    module Space
      CLICKABLE = 'clickable'
      CONCLUSION = 'conclusion'

      def self.for(location) = document.querySelector("#space-#{location}")

      def self.build_elements
        spaces = Ux.build_element element: :div, id: :spaces
        current_game.board.each do |space|
          classes = %w[ space ]
          classes << 'playable' if space.playable?
          Ux.build_element(element: :div, id: "space-#{space.name}", classes:, innerHTML: space.name)
            .tap { _1.addEventListener('click') { select space.name } }
            .then { spaces.appendChild _1 }
        end
        spaces
      end

      def self.select(location)
        puts "handling click on #{location}"
        case Ux::State.current
        when Ux::State.choose_space_for_choice
          puts "chose #{location}"
          #submit_choice(location) TODO
          nothing_is_clickable!
        when Ux::State.choose_space_for_move
          puts "place at #{location}"
          Ux::Move.current.store(:location, location)
          nothing_is_clickable!
          Ux::State.set_to Ux::State.choose_direction_for_move
          options = Philosophy::IdeaTile::VALID_TARGETS[Philosophy::IdeaTile.registry[Ux::Move.current[:tile]].target]
          Compass.activate!(location:, options:)
        else
          puts "Invalid state for selecting space: #{Ux::State.current}"
        end
        nil
      end

      def self.all = document.querySelectorAll(".space")
      def self.playable = document.querySelectorAll('.space.playable')
      def self.nothing_is_clickable! = all.forEach { _1[:classList].remove CLICKABLE }
      def self.clickable!(spaces: playable) = spaces.forEach { _1[:classList].add CLICKABLE }
      def self.nothing_is_concluded! = all.forEach { _1[:classList].remove CONCLUSION }
    end
  end
end
