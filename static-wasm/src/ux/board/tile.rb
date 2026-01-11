module Ux
  module Board
    module Tile
      def self.place(occupied_space)
        tile = occupied_space.tile
        classes = %W[ tile bgcolor-#{tile.owner.color.code} direction-#{tile.target.notation} ]

        div = Ux.build_element(element: :div, classes:)#, innerHTML: text
        tile.owner.color.name
          .then { Ux.build_element(element: :span, innerHTML: _1, title: _1) }
          .then { div.appendChild _1 }
        "#{tile.class} (#{tile.class.notation})"
          .then { Ux.build_element(element: :code, innerHTML: _1, title: _1) }
          .then { div.appendChild _1 }
        "#{tile.target.long} (#{tile.target.notation})"
          .then { Ux.build_element(element: :code, innerHTML: _1, title: _1) }
          .then { div.appendChild _1 }
        div[:style] = Ux::Board.grid_position(occupied_space.name.to_sym)

        Ux::Board.tiles.appendChild div
      end
    end
  end
end
