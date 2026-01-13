module Ux
  module Console
    module Rules
      def self.open
        document.querySelector('#rules')[:open] = true
        @rules_closed_once = false
      end

      def self.close_once
        document.querySelector('#rules').removeAttribute('open') unless @rules_closed_once
        @rules_closed_once = true
      end

      def self.build
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
    end
  end
end
