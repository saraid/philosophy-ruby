puts "loaded #{__FILE__} #{JS.global[:Date].new}"
module Ux
  module Console
    module Pgn
      COPY_TO_CLIPBOARD = '📑'
      SUCCESS = '✔'

      def self.element = document.querySelector('#history')
      def self.copy_div = document.querySelector('#copy-to-clipboard')
      def self.clipboard_available? = clipboard.is_a? JS::Object # No idea if this is correct.
      def self.copy_pgn
        current_game.to_pgn.then do |pgn_text|
          puts "copying to clipboard:#{$/}#{pgn_text}"
          clipboard.writeText pgn_text

          # JS.global[:ClipboardItem].new({
          #   ['text/plain'] => JS.global[:Blob].new([pgn_text], { 'type' => 'text/plain' }),
          #   ['text/html'] => element[:textContent], #JS.global[:Blob].new(["<pre>#{pgn_text}</pre>"], { 'type' => 'text/html' }),
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

      def self.show_historical_event(event)
        Ux::Board.render(event.context, event.operations)
        if event == current_game.history.last
          puts "Showing current game state."
        else
          puts "Showing previous game state."
        end
      end

      def self.restore_to_current
        Ux::Board.render
      end

      def self.build_placement_event(event, parameters: [], options: {})
        text =
          case event
          when Philosophy::Game::Placement
            "#{current_game.players[event.player].color.name} " \
              "placed #{Philosophy::IdeaTile.registry[event.tile]} " \
              "on #{event.location} pointing #{Philosophy::Board::Direction[event.direction].long}"
          end
        Ux.build_element(element: :li, innerHTML: event.notation(parameters:, options:), title: text)
          .tap { _1.addEventListener('click') { show_historical_event event } }
          .tap { _1.addEventListener('mouseover') { show_historical_event event } }
          .tap { _1.addEventListener('mouseout') { restore_to_current } }
      end

      def self.update
        copy_div[:style] = 'display:block;' if clipboard_available?
        list = document.querySelector('#history')
        list[:innerHTML] = ''

        skipped_events = []
        iter = current_game.history.each
        loop do
          event = iter.next
          break if event.nil?
          case event
          when Philosophy::Game::Placement
            last_choice = nil
            choices = []
            begin
              loop do
                case iter.peek
                when Philosophy::Game::Choice
                  choices << (last_choice = iter.next).choice
                when Philosophy::Game::Placement
                  break
                else
                  skipped_events << iter.next
                end
              end
            rescue StopIteration
              # ignore when it's from #peek
            end
            build_placement_event(
              event, parameters: event.parameters + choices,
              options: (last_choice&.options || event.options).to_h
            ).then { list.appendChild _1 }
          else
            [*skipped_events, event].each do
              text =
                case _1
                when Philosophy::Game::PlayerChange
                  "#{current_game.players[_1.code].color.name} #{_1.type} as #{_1.code}"
                when Philosophy::Game::RuleChange
                  case _1.rule
                  when :join
                    case _1.variable
                    when :permitted then "Change rule for when a new player is allowed to join to: #{_1.value}"
                    when :where then "Change rule for where in the turn order a player joins to: #{_1.value}"
                    end
                  when :leave
                    case _1.variable
                    when :permitted then "Change rule for when a new player is allowed to leave to: #{_1.value}"
                    when :effect then "Change rule for what happens when a player leaves to: #{_1.value}"
                    end
                  end
                when Philosophy::Game::Respect
                  "Respect given to #{current_game.players[_1.player]}" # TODO Test after Respect token implemented.
                end
              list.appendChild(Ux.build_element(element: :li, innerHTML: _1.notation, title: text))
            end
          end
        end
        list
      end

      def self.build
        wrapper = Ux.build_element(element: :div, id: :'pgn-wrapper')
        Ux.build_element(element: :ol, id: :history)
          .then { wrapper.appendChild _1 }
        Ux.build_element(
          element: :div, id: :'copy-to-clipboard', innerHTML: COPY_TO_CLIPBOARD, title: 'Copy to Clipboard'
        )
          .tap { _1.addEventListener('click') { copy_pgn } }
          .then { wrapper.appendChild _1 }
        wrapper
      end
    end
  end
end
