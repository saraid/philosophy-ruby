puts "loaded #{__FILE__}"
require_relative 'console/movetext'
require_relative 'console/player_add'
require_relative 'console/player_hand'
require_relative 'console/tests'

module Ux
  module Console
    def self.wrapper = document.querySelector('#console')

    def self.player_add = document.querySelector('#player-add')

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
      current_game.to_pgn.then do |pgn_text|
        puts "copying to clipboard:#{$/}#{pgn_text}"
        clipboard.writeText pgn_text

        # JS.global[:ClipboardItem].new({
        #   ['text/plain'] => JS.global[:Blob].new([pgn_text], { 'type' => 'text/plain' }),
        #   ['text/html'] => pgn[:textContent], #JS.global[:Blob].new(["<pre>#{pgn_text}</pre>"], { 'type' => 'text/html' }),
        # }).then { clipboard.write [_1] }
      end
      copy_div[:innerHTML] = SUCCESS
      Ux.wait_then(timeout: 150.milliseconds) do
        copy_div[:innerHTML] = COPY_TO_CLIPBOARD
      end

      # TODO rescue somehow if clipboard API not implemented in browser
      # No idea how to check that
      nil
    end
    def self.partial_copy(event)
      selection = document.getSelection
      event[:clipboardData].setData('text/plain', selection)
      event[:clipboardData].setData('text/plain', "<pre>#{selection}</pre>")
    end

    def self.build_pgn
      wrapper = Ux.build_element(element: :pre, id: :'pgn-wrapper')
      Ux.build_element(element: :pre, id: :pgn)
        .tap { _1.addEventListener('copy') { |event| partial_copy event } }
        .then { wrapper.appendChild _1 }
      Ux.build_element(
        element: :div, id: :'copy-to-clipboard', innerHTML: COPY_TO_CLIPBOARD, title: 'Copy to Clipboard'
      )
        .tap { _1.addEventListener('click') { copy_pgn } }
        .then { wrapper.appendChild _1 }
      wrapper
    end

    def self.open_rules
      document.querySelector('#rules')[:open] = true
      @rules_closed_once = false
    end
    def self.close_rules_once
      document.querySelector('#rules').removeAttribute('open') unless @rules_closed_once
      @rules_closed_once = true
    end
    def self.build_rules
      details = Ux.build_element element: :details, id: :rules, open: true
      summary = Ux.build_element element: :summary, innerHTML: 'Player Change Rules'
      list = Ux.build_element element: :ul
      current_game.rules.then do |rules|
        case rules.can_join.permitted
        when :only_before_any_placement then "New players can only join before any tile is placed."
        when :between_turns then  "New players can only join between turns."
        end
          .then { Ux.build_element element: :li, innerHTML:  _1 }
          .then { list.appendChild _1 }

        case rules.can_join.where
        when :immediately_next then "New playesr will join as the next player."
        when :after_a_full_turn then "New playesr will join after the last player has gone."
        end
          .then { Ux.build_element element: :li, innerHTML:  _1 }
          .then { list.appendChild _1 }

        case rules.can_leave.permitted
        when :only_before_any_placement then "Players cannot leave after the game starts."
        when :never then "Players may not leave once joined."
        when :anytime then "Players may leave at any time."
        end
          .then { Ux.build_element element: :li, innerHTML:  _1 }
          .then { list.appendChild _1 }

        case rules.can_leave.effect
        when :ends_game then "The game will end upon a player leaving."
        when :rollback_placement then "If a player leaves mid-placement, their tile will be removed."
        when :remove_their_tiles then "All of a player's tiles will be removed from the board upon leaving."
        end
          .then { Ux.build_element element: :li, innerHTML:  _1 }
          .then { list.appendChild _1 }
      end
      details.appendChild summary
      details.appendChild list
      details
    end

    def self.build_tile_help = Ux.build_element element: :aside, id: :'tile-help'

    HELP_TEXT = {
      Pu: <<~HTML,
        <header>Push (Pu)</header>
        <p>The <i>Push</i> targets
        an opponent tile
        1 space away,
        and pushes it
        1 space <b>forward</b>.</p>
      HTML
      Cp: <<~HTML,
        <header>Corner Push (Cp)</header>
        <p>The <i>Corner Push</i>
        targets an
        opponent tile 1
        space away
        diagonally, and pushes it 1 space
        <b>forward diagonally</b>.</p>
      HTML
      Sl: <<~HTML,
        <header>Slide Left (Sl)</header>
        <p>The <i>Slide Left</i>
        targets an opponent tile 1 space away,
        and slides it 1 space to the <b>left</b>.</p>
      HTML
      Sr: <<~HTML,
        <header>Slide Right (Sr)</header>
        <p>The <i>Slide Right</i>
        targets an opponent tile 1 space away,
        and slides it 1 space to the <b>right</b>.</p>
      HTML
      Pl: <<~HTML,
        <header>Pull Left (Pl)</header>
        <p>The <i>Pull Left</i> targets an opponent
        tile 1 space away, and pulls
        it 1 space backwards to the <b>left</b>.</p>
      HTML
      Pr: <<~HTML,
        <header>Pull Right (Pr)</header>
        <p>The <i>Pull Right</i>
        targets an opponent tile 1 space
        away, and pulls it 1 space backwards to the <b>right</b>.</p>
      HTML
      Ls: <<~HTML,
        <header>Long Shot (Ls)</header>
        <p>The <i>Long Shot</i>
        targets an opponent tile exactly <b>2 spaces</b>
        away, and pushes it 1 space <b>forward</b>.</p>
      HTML
      Cl: <<~HTML,
        <header>Corner Long Shot (Cl)</header>
        <p>The <i>Corner Long Shot</i> targets an
        opponent tile exactly <b>2 spaces</b> away diagonally, and pushes it
        1 space <b>forward diagonally</b>.</p>
      HTML
      De: <<~HTML,
        <header>Decision (De)</header>
        <p>The <i>Decision</i> targets an
        opponent tile 1 space away diagonally, and
        slides it 1 space to the <b>left or right diagonally</b>.
        You choose which way it slides.</p>
      HTML
      Re: <<~HTML,
        <header>Rephrase (Re)</header>
        <p>The <i>Rephrase</i> targets <b>any tile</b>a
        1 space away diagonally. Pick up the targeted tile,
        <b>optionally rotate</b> it any way you wish, and
        place it back down onto the <b>same space</b>.</p>
      HTML
      To: <<~HTML,
        <header>Toss (To)</header>
        <p>The <i>Toss</i> targets
        an opponent tile 1 space away, and
        moves that tile 2 spaces backwards
        <b>over the top</b> of itself.</p>
      HTML
      Pe: <<~HTML,
        <header>Persuade (Pe)</header>
        <p>The <i>Persuade</i> targets an opponent
        tile 1 space away, and pulls it 1 space
        <b>backwards</b>, moving <b>both</b> the opponent
        tile and the Persuade together.</p>
      HTML
    }

    def self.tile_help = document.querySelector('#tile-help')
    def self.set_tile_help(tile)
      HELP_TEXT.fetch(tile, '').then do |text|
        tile_help[:style] = if text.empty? then 'display:none;' else 'display:block;' end
        tile_help[:innerHTML] = text
      end
    end

    def self.render
      update_pgn
      PlayerHand.render_joined
    end

    def self.setup(raw_mode: false)
      console = Ux.build_element element: :div, id: :console

      if raw_mode
      else
        build_rules
          .then { console.appendChild _1 }
        PlayerAdd.build
          .then { console.appendChild _1 }
        Ux.build_element(element: :div, id: :'player-hands')
          .then { console.appendChild _1 }
        build_pgn
          .then { console.appendChild _1 }
        build_tile_help
          .then { console.appendChild _1 }
      end

      Ux.main.appendChild console
    end
  end
end
