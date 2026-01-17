puts "loaded #{__FILE__}"
module Ux
  module Console
    module PlayerAdd
      def self.input = document.querySelector('#player-add input')
      def self.chosen_name = input[:value].to_s
      def self.div = document.querySelector('#player-add #available')

      def self.build
        wrapper = Ux.build_element element: :div, id: :'player-add'

        Ux.build_element(element: :span, innerHTML: 'Add Player:')
          .then { wrapper.appendChild _1 }
        Ux.build_element(element: :input, type: :text, placeholder: 'Player Name')
          .then { wrapper.appendChild _1 }
        Ux.build_element(element: :div, id: :available)
          .then { wrapper.appendChild _1 }

        wrapper
      end

      DISABLED = 'disabled'
      def self.disable = Ux::Console.player_add[:classList].add(DISABLED)
      def self.enable = Ux::Console.player_add[:classList].remove(DISABLED)

      def self.update
        render

        if !current_game.started? \
          && current_game.player_order.size >= 2 \
          && !current_game.concluded?
          PlayerHand.element_for(current_game.player_order.first)[:classList].remove PlayerHand::CANNOT_PLAY
        end

        PlayerHand.render_joined
        Ux::Console.update_pgn
      end

      def self.render
        build if div == JS::Null
        div[:innerHTML] = ''

        Ux::Player.available.sort_by(&:code).each do |player|
          Ux.build_element(element: :button, innerHTML: player.code)
            .tap { _1.addEventListener('click') { Ux::Console::PlayerHand.add player } }
            .then { div.appendChild _1 }
        end
      end
    end
  end
end
