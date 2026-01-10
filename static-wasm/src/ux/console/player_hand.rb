module Ux
  module Console
    module PlayerHand
      CANNOT_PLAY = 'cannot-play'

      def self.wrapper = document.querySelector('#player-hands')
      def self.clear_all = wrapper[:innerHTML] = ''
      def self.for(code) = document.querySelector("#player-#{code}")

      def self.add(player)
        chosen_name = PlayerAdd.chosen_name
        chosen_name = player.default_name if chosen_name.empty?
        current_game << Philosophy::Game::PlayerChange.new(code: player.code, type: :joined, name: chosen_name)

        PlayerAdd.input[:value] = nil
        Player.available.delete player
        PlayerAdd.render

        if !current_game.started? && current_game.player_order.size >= 2 && !current_game.concluded?
          self.for(current_game.player_order.first)[:classList].remove CANNOT_PLAY
        end

        render_joined
        Ux::Console.update_pgn
      end

      def self.render_joined
        clear_all
        current_game.player_order.each { render _1 }
      end

      def self.render(player_code)
        player = current_game.players.fetch(player_code)
        hand = self.for player.color.code
        if hand == JS::Null
          classes = %W[ player-hand bgcolor-#{player.color.code} ]
          if current_game.current_player != player || current_game.player_order.size < 2 || current_game.concluded?
            classes << CANNOT_PLAY
          end
          hand = Ux.build_element(
            id: "player-#{player.color.code}",
            classes:,
          )
          wrapper.appendChild hand
        end

        hand[:innerHTML] = ''

        Ux.build_element(element: :span, innerHTML: player.color.name.to_s)
          .then { hand.appendChild _1}

        player.tiles.each do
          type = Philosophy::IdeaTile.registry[_1]
          tile = Ux.build_element(element: :button, title: type.to_s, innerHTML: type.notation.to_s)
          tile.addEventListener('click') do
            case Ux::State.current
            when :choose_tile_for_move
              Ux::Move.current.store(:player, player.color.code)
              Ux::Move.current.store(:tile, type.notation)
              self.for(player.color.code).tap do |new_hand|
                new_hand[:classList].add CANNOT_PLAY
                new_hand.removeChild tile
              end
              Ux::Board::Space.clickable!
              Ux::State.set_to Ux::State.choose_space_for_move
            else
            end
          end
          hand.appendChild tile
        end

        nil
      end
    end
  end
end
