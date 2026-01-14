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
      }
      JS.global[:philosophy] = {
        TESTS:,
        loadPgn: lambda do |pgn|
          pgn
            .to_a
            .map(&:to_s)
            .each.with_object(Philosophy::Game.new) { _2 << _1 }
            .then { Philosophy::Game.set_current! _1 }
            .then { Ux.render }
        end
      }

      def self.div = document.querySelector('#tests')

      def self.render
        if [JS::Null, JS::Undefined].include? div
        else
          TESTS.each do |name, moves|
            button = JS.global[:document].createElement("button")
            button[:innerHTML] = name
            button.addEventListener('click') do |event|
              moves
                .each.with_object(Philosophy::Game.new) { _2 << _1 }
                .then { Philosophy::Game.set_current _1 }
              Ux.render
            end
            div.appendChild(button)
          end
        end
      end

      def self.build
        details = Ux.build_element element: :details, id: :tests, open: true
        summary = Ux.build_element element: :summary, innerHTML: 'Prebuilt Games: '
        details.appendChild summary
        details
      end
    end
  end
end
