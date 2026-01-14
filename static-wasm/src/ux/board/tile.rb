module Ux
  module Board
    module Tile
      PERSON = '🧑'
      COMPASS = '🧭'
      ACTIVATED = 'activated'
      SO_ACTIVATED = 'so-activated'

      def self.place(occupied_space, activated: nil)
        tile = occupied_space.tile
        classes = %W[ tile bgcolor-#{tile.owner.color.code} direction-#{tile.target.notation} ]
        classes << ACTIVATED if activated
        classes << SO_ACTIVATED if activated # adding specificity to override .tile.bgcolor

        div = Ux.build_element(element: :div, classes:)#, innerHTML: text
        "#{tile.class} (#{tile.class.notation})"
          .then { Ux.build_element(element: :div, innerHTML: _1, title: _1, classes: %w[ tile-name ]) }
          .then { div.appendChild _1 }

        footer = Ux.build_element(element: :div, classes: %w[ tile-footer ])
          .tap { div.appendChild _1 }

        Ux.build_element(element: :div, innerHTML: PERSON, title: tile.owner.color.name)
          .then { footer.appendChild _1 }
        Ux.build_element(element: :div, innerHTML: COMPASS, title: "#{tile.target.long} (#{tile.target.notation})")
          .then { footer.appendChild _1 }

        div[:style] = Ux::Board.grid_position(occupied_space.name.to_sym)
        div.addEventListener('mouseover') { Ux::Console::TileHelp.set_tile tile.class.notation }

        Ux::Board.tiles.appendChild div
      end
    end
  end
end
