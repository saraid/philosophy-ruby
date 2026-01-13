puts "loaded #{__FILE__}"
require_relative 'console/movetext'
require_relative 'console/pgn'
require_relative 'console/player_add'
require_relative 'console/player_hand'
require_relative 'console/rules'
require_relative 'console/tests'
require_relative 'console/tile_help'

module Ux
  module Console
    def self.wrapper = document.querySelector('#console')

    def self.player_add = document.querySelector('#player-add')

    def self.update_pgn = Pgn.update
    def self.set_tile_help(...) = TileHelp.set_tile(...)
    def self.close_rules_once = Rules.close_once

    def self.render
      update_pgn
      PlayerHand.render_joined
    end

    def self.setup(raw_mode: false)
      console = Ux.build_element element: :div, id: :console

      if raw_mode
      else
        Rules.build
          .then { console.appendChild _1 }
        PlayerAdd.build
          .then { console.appendChild _1 }
        Ux.build_element(element: :div, id: :'player-hands')
          .then { console.appendChild _1 }
        Pgn.build
          .then { console.appendChild _1 }
        TileHelp.build
          .then { console.appendChild _1 }
      end

      Ux.main.appendChild console
    end
  end
end
