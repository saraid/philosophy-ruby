module Ux
  module Console
    module PlayerHand
      CANNOT_PLAY = 'cannot-play'
      CHOSEN = 'chosen'
      DISABLED = 'disabled'

      def self.wrapper = document.querySelector('#player-hands')
      def self.clear_all = wrapper[:innerHTML] = ''
      def self.element_for(code) = document.querySelector("#player-#{code}")
      def self.tiles_for(code) = document.querySelectorAll("#player-#{code} button")

      def self.add(player)
        chosen_name = PlayerAdd.chosen_name
        chosen_name = player.default_name if chosen_name.empty?
        current_game << Philosophy::Game::PlayerChange.new(code: player.code, type: :joined, name: chosen_name)

        PlayerAdd.input[:value] = nil
        Player.available.delete player
        PlayerAdd.update

        Ux::Console.close_rules_once
      end

      def self.remove(player_code)
        current_game << Philosophy::Game::PlayerChange.new(code: player_code, type: :left)
        Ux::Player.add_available player_code
        PlayerAdd.update
      end

      def self.render_joined
        clear_all
        current_game.player_order.each { render _1 }
      end

      def self.build(player)
        classes = %W[ player-hand bgcolor-#{player.color.code} ]
        if current_game.current_player != player
          || current_game.player_order.size < 2
          || current_game.concluded?
          classes << CANNOT_PLAY
        end
        Ux.build_element(id: "player-#{player.color.code}", classes:,)
          .tap { wrapper.appendChild _1 }
      end

      def self.allowed_to_leave?(player)
        current_game.then do |g|
          next true unless g.started?
          case g.rules.can_leave
          when -> { _1.never? } then false
          when -> { _1.only_before_any_placement? } then false # started?=true implicit
          when -> { _1.anytime? } then true
          end
        end
      end

      def self.render(player_code)
        player = current_game.players.fetch(player_code)
        hand = element_for player.color.code
        hand = build(player) if hand == JS::Null

        hand[:innerHTML] = ''

        classes = %w[ player-leave ]
        classes << DISABLED unless allowed_to_leave? player
        Ux.build_element(element: :button, classes:, innerHTML: 'X')
          .tap { _1.addEventListener('click') { remove player_code } }
          .then { hand.appendChild _1 }

        Ux.build_element(element: :span, innerHTML: player.color.name.to_s)
          .then { hand.appendChild _1}

        player.tiles.each do
          type = Philosophy::IdeaTile.registry[_1]
          classes = [ "tile-#{type.notation}" ]
          tile = Ux.build_element(element: :button, classes:, title: type.to_s, innerHTML: type.notation.to_s)
          tile.addEventListener('click') do
            case Ux::State.current
            when Ux::State.choose_tile_for_move, Ux::State.choose_space_for_move
              Ux::Console::PlayerHand.tiles_for(player.color.code)
                .forEach { |node| node[:classList].remove CHOSEN }
              tile[:classList].add CHOSEN

              Ux::Move.current.store(:player, player.color.code)
              Ux::Move.current.store(:tile, type.notation)
              Ux::Move.current.store(:location, nil)
              Ux::Move.current.store(:direction, nil)

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
