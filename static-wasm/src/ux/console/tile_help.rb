module Ux
  module Console
    module TileHelp
      def self.build = Ux.build_element element: :aside, id: :'tile-help'

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

      def self.element = document.querySelector('#tile-help')

      def self.set_tile(tile)
        HELP_TEXT.fetch(tile, '').then do |text|
          element[:style] = if text.empty? then 'display:none;' else 'display:block;' end
          element[:innerHTML] = text
        end
      end
    end
  end
end
