module Philosophy
  class Game
    class Rules
      def self.default = { join: JoinRule.default, leave: LeaveRule.default }

      class Rule
        def self.define(variable, *options, default: options.first)
          @variables ||= {}
          @variables[variable] = { options: options, default: default }
        end

        def self.build!
          vars = @variables.keys
          defaults = @variables.transform_values { _1[:default] }
          class_eval <<~RUBY
            def self.default = { #{defaults.map { "#{_1}: :#{_2}" }.join(', ')} }

            def initialize(**kwargs)
              #{vars.map { "@#{_1}" }.join(', ')} = kwargs.values_at(#{vars.map { ":#{_1}" }.join(', ')})
            end
          RUBY
          @variables.each do |variable, definition|
            definition[:options].each do |option|
              eval("def #{option}? = @#{variable} == :#{option}")
              eval("def #{option}! = @#{variable} = :#{option}")
            end
          end
        end
      end

      class JoinRule < Rule
        # At what points during the game may new players join?
        define :permitted, :only_before_any_placement, :after_placement
        # Where in the turn order does the new player go?
        define :where, :immediately_next, :after_a_full_turn

        build!
      end

      class LeaveRule < Rule
        # At what points during the game may a player leave?
        define :permitted, :only_before_any_placement, :never, :anytime

        # What happens when a player leaves in the middle of a placement?
        define :what, :ends_game, :rollback_placement, :remove_their_tiles

        build!
      end

      def initialize(join: JoinRule.default, leave: LeaveRule.default)
        @join = JoinRule.new(**JoinRule.default.merge(join))
        @leave = LeaveRule.new(**LeaveRule.default.merge(leave))
      end

      def can_join = @join
      def can_leave = @leave
      def upon_leaving = @leave
    end
  end
end
