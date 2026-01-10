require_relative 'console/movetext'
require_relative 'console/player_add'
require_relative 'console/player_hand'
require_relative 'console/tests'

module Ux
  module Console

    def self.player_add = document.querySelector('#player-add')
    private_class_method def self.build_player_add
      wrapper = Ux.build_element element: :div, id: :'player-add'

      Ux.build_element(element: :span, innerHTML: 'Add Player:')
        .then { wrapper.appendChild _1 }
      Ux.build_element(element: :input, type: :text, placeholder: 'Player Name')
        .then { wrapper.appendChild _1 }

      wrapper
    end

    def self.pgn = document.querySelector('#pgn')
    def self.update_pgn = pgn[:innerHTML] = current_game.to_pgn

    def self.render
      update_pgn
      PlayerHand.render_joined
    end

    def self.setup(raw_mode: false)
      console = Ux.build_element element: :div, id: :console

      if raw_mode
      else
        build_player_add
          .then { console.appendChild _1 }
        Ux.build_element(element: :div, id: :'player-hands')
          .then { console.appendChild _1 }
        Ux.build_element(element: :pre, id: :pgn)
          .then { console.appendChild _1 }
      end

      Ux.main.appendChild console
    end
  end
end
