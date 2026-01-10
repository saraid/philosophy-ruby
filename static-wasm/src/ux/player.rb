module Ux
  class Player
    DEFAULTS = {
      Am: {
        color: '#FFBF00',
        default_name: 'Ambrose Pierce',
      },
      In: {
        color: '#4B0082',
        default_name: 'Indiana Jones',
      },
      Sa: {
        color: '#B2AC88',
        default_name: 'Sarah Connor',
      },
      Te: {
        color: '#008080',
        default_name: 'Teotihual Batan',
      },
    }

    def self.available
      @available ||= Set.new(
        DEFAULTS.map do |code, kwargs|
          new(code:, **kwargs)
        end
      )
    end

    def self.render_available
      wrapper = document.querySelector('#player-add #available')
      if wrapper == JS::Null
        wrapper = Ux.build_element(element: :div, id: :available)
        Ux::Console.player_add.appendChild wrapper
      end

      wrapper[:innerHTML] = ''

      available.each do |player|
        Ux.build_element(element: :button, innerHTML: player.code)
          .tap { _1.addEventListener('click') { add_player player } }
          .then { wrapper.appendChild _1 }
      end
    end

    def self.add_player(player)
      input = document.querySelector('#player-add input')
      chosen_name = input[:value].to_s
      chosen_name = player.default_name if chosen_name.empty?
      current_game << Philosophy::Game::PlayerChange.new(code: player.code, type: :joined, name: chosen_name)

      input[:value] = nil
      available.delete player
      render_available

      if !current_game.started? && current_game.player_order.size >= 2 && !current_game.concluded?
        Ux::Console.player_hand(current_game.player_order.first)[:classList]
          .remove Ux::Console::PlayerHand::CANNOT_PLAY
      end

      render_joined
      Ux::Console.update_pgn
    end

    def self.render_joined
      Ux::Console.clear_player_hands
      current_game.player_order.each do |player|
        render_player_hand player
      end
    end

    def self.render_player_hand(player_code)
      player = current_game.players.fetch(player_code)
      hand = Ux::Console.player_hand player.color.code
      if hand == JS::Null
        classes = %W[ player-hand bgcolor-#{player.color.code} ]
        if current_game.current_player != player || current_game.player_order.size < 2 || current_game.concluded?
          classes << Ux::Console::PlayerHand::CANNOT_PLAY
        end
        hand = Ux.build_element(
          id: "player-#{player.color.code}",
          classes:,
        )
        Ux::Console.player_hands.appendChild hand
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
            Ux::Console.player_hand(player.color.code).tap do |new_hand|
              new_hand[:classList].add Ux::Console::PlayerHand::CANNOT_PLAY
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

    def initialize(code:, color:, default_name:)
      @code, @color, @default_name = code, color, default_name
    end
    attr_reader :code, :color, :default_name
  end
end
