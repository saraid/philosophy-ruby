module Ux
  module Console
    module Tests
      TESTS = {
        'pushNo' => %w[
          In+:indigo
          Te+:teal
          In:C4PuNo
          Te:C7PuNo
        ],
        'tossSo' => %w[
          In+:indigo
          Te+:teal
          In:C4PuNo
          Te:C1ToSo
        ],
        'tossNo' => %w[
          In+:indigo
          Te+:teal
          In:C4PuNo
          Te:C7ToNo
        ],
        'two conclusions' => %w[
          Am+
          In+
          Am:C1PuWe
          In:C3CpNe
          Am:C4CpNw
          In:C6SlEa
          Am:C8PlNo
          In:C9PuWe..
          Am:C2SlEa.
        ],
        'rephrase' => %w[
          In+:indigo
          Te+:teal
          In:C4PuNo
          Te:C2ReSw[Ea]
        ],
        'chain reaction' => %w[
          In+:Indiana
          Sa+:Samar
          In:C9CpNe
          Sa:C6PuSo
          In:C5SrEa
          Sa:C4SlEa
          In:C8PuEa
        ]
      }

      def self.div = document.querySelector('#tests')

      def self.load_pgn(moves)
        new_game = Philosophy::Game.new
        new_game.set_rules Philosophy::Game.current.rules
        moves
          .each.with_object(new_game) { _2 << _1 }
          .then { Philosophy::Game.set_current! _1 }
        Ux.render
      end

      def self.render
        if [JS::Null, JS::Undefined].include? div
        else
          TESTS.each do |name, moves|
            button = JS.global[:document].createElement("button")
            button[:innerHTML] = name
            button.addEventListener('click') { load_pgn moves }
            div.appendChild(button)
          end
        end
      end

      def self.build
        JS.global[:philosophy][:TESTS] = TESTS
        JS.global[:philosophy][:loadPgn] = -> { load_pgn _1.to_a.map(&:to_s) } # convert from JS to Ruby

        details = Ux.build_element element: :details, id: :tests, open: true
        summary = Ux.build_element element: :summary, innerHTML: 'Prebuilt Games: '
        details.appendChild summary
        details
      end
    end
  end
end
