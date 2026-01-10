module Ux
  module Console
    module PlayerAdd
      def self.input = document.querySelector('#player-add input')
      def self.chosen_name = input[:value].to_s
      def self.div = document.querySelector('#player-add #available')

      def self.build
        Ux.build_element(element: :div, id: :available)
          .then { Ux::Console.player_add.appendChild _1 }
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
