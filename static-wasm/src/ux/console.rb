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

    COPY_TO_CLIPBOARD = '📋'
    SUCCESS = '✔'

    def self.pgn = document.querySelector('#pgn')
    def self.copy_div = document.querySelector('#copy-to-clipboard')
    def self.clipboard_available? = clipboard.is_a? JS::Object # No idea if this is correct.
    def self.update_pgn
      pgn[:innerHTML] = current_game.to_pgn
      copy_div[:style] = 'display:block;' if clipboard_available?
    end
    def self.copy_pgn
      current_game.to_pgn.then do
        clipboard.writeText _1
        puts "copied to clipboard:#{$/}#{_1}"
      end
      copy_div[:innerHTML] = SUCCESS
      Ux.wait_then(timeout: 150.milliseconds) do
        copy_div[:innerHTML] = COPY_TO_CLIPBOARD
      end

      # TODO rescue somehow if clipboard API not implemented in browser
      # No idea how to check that
      nil
    end

    def self.build_pgn
      wrapper = Ux.build_element(element: :pre, id: :'pgn-wrapper')
      Ux.build_element(element: :pre, id: :pgn)
        .then { wrapper.appendChild _1 }
      Ux.build_element(
        element: :div, id: :'copy-to-clipboard', innerHTML: COPY_TO_CLIPBOARD, title: 'Copy to Clipboard'
      )
        .tap { _1.addEventListener('click') { copy_pgn } }
        .then { wrapper.appendChild _1 }
      wrapper
    end

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
        build_pgn
          .then { console.appendChild _1 }
      end

      Ux.main.appendChild console
    end
  end
end
