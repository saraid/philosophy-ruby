module Ux
  module Console
    module Rules
      def self.element = document.querySelector('#rules')

      RULE_TEXT = {
        join: {
          permitted: {
            only_before_any_placement: "New players can only join before any tile is placed.",
            between_turns: "New players can only join between turns.",
          },
          where: {
            immediately_next: "New players will join as the next player.",
            after_a_full_turn: "New players will join after the last player has gone.",
          },
        },
        leave: {
          permitted: {
            only_before_any_placement: "Players cannot leave after the game starts.",
            never: "Players may not leave once joined.",
            anytime: "Players may leave at any time.",
          },
          effect: {
            ends_game: "The game will end upon a player leaving.",
            rollback_placement: "If a player leaves mid-placement, their partially-placed tile will be removed.",
            remove_their_tiles: "All of that player's tiles will be removed from the board upon leaving.",
          },
        },
      }

      def self.open
        element[:open] = true
        @rules_closed_once = false
      end

      def self.close_once
        element.removeAttribute('open') unless @rules_closed_once
        @rules_closed_once = true
      end

      def self.change(rule_name, variable, value)
        current_game << Philosophy::Game::RuleChange.new(rule: rule_name, variable:, value:)
        Ux::Console.update_pgn
        nil
      end

      def self.build_select_element(rule_name, variable, selected_value)
        wrapper = Ux.build_element element: :select, name: "rule-#{rule_name}-#{variable}"
        RULE_TEXT.dig(rule_name, variable).each do |value, text|
          option = Ux.build_element element: :option, value:, selected: value == selected_value, innerHTML: text
          wrapper.appendChild option
        end
        wrapper.addEventListener('change') do |event|
          value = event[:target][:value].to_s.to_sym
          puts value.inspect
          change(rule_name, variable, value.to_sym)
        end
        wrapper
      end

      def self.build
        details = Ux.build_element element: :details, id: :rules, open: true
        summary = Ux.build_element element: :summary, innerHTML: 'Player Change Rules'
        list = Ux.build_element element: :ul
        current_game.rules.then do |rules|
          build_select_element(:join, :permitted, rules.can_join.permitted)
            .then { list.appendChild _1 }
          build_select_element(:join, :where, rules.can_join.where)
            .then { list.appendChild _1 }
          build_select_element(:leave, :permitted, rules.can_leave.permitted)
            .then { list.appendChild _1 }
          build_select_element(:leave, :effect, rules.can_leave.effect)
            .then { list.appendChild _1 }
        end
        details.appendChild summary
        details.appendChild list
        details
      end
    end
  end
end
