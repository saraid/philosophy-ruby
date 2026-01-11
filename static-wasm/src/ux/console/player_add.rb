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
      def self.disable
        Ux::Console.player_add[:classList].add(DISABLED)
        Ux::Console.player_add[:title] = # this doesn't actually work
          case current_game.rules.can_join
          when -> { _1.only_before_any_placement? } then 'Can only join before placement.'
          when -> { _1.between_turns? } then 'Cannot join until turn is complete.'
          end
      end
      def self.enable
        Ux::Console.player_add[:classList].remove(DISABLED)
        Ux::Console.player_add[:title] = nil
      end

      def self.render
        build if div == JS::Null
        div[:innerHTML] = ''

        Ux::Player.available.each do |player|
          Ux.build_element(element: :button, innerHTML: player.code)
            .tap { _1.addEventListener('click') { Ux::Console::PlayerHand.add player } }
            .then { div.appendChild _1 }
        end
      end
    end
  end
end
