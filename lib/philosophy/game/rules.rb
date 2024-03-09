module Philosophy
  class Game
    class Rules
      def self.default = new

      class JoinRule
        # At what points during the game may new players join?
        WHEN = %i[ only_before_any_placement after_placement ]

        # Where in the turn order does the new player go?
        WHERE = %i[ immediately_next after_a_full_turn ]

        { when: WHEN, where: WHERE }.each do |preposition, options|
          options.each do |option|
            eval(<<~RUBY)
              def #{option}? = @#{preposition} == :#{option}
            RUBY
          end
        end

        def self.default = {
          when_option: :only_before_any_placement,
          where: :immediately_next
        }

        def initialize(when_option:, where:)
          @when, @where = when_option, where
        end
      end

      class LeaveRule
        # At what points during the game may a player leave?
        WHEN = %i[ only_before_any_placement never anytime ]

        # What happens when a player leaves in the middle of a placement?
        WHAT = %i[ ends_game rollback_placement remove_their_tiles ]

        { when: WHEN, what: WHAT }.each do |preposition, options|
          options.each do |option|
            eval(<<~RUBY)
              def #{option}? = @#{preposition} == :#{option}
            RUBY
          end
        end

        def self.default = {
          when_option: :only_before_any_placement,
          what: :ends_game
        }

        def initialize(when_option:, what:)
          @when, @what = when_option, what
        end
      end

      def initialize(join: JoinRule.default, leave: LeaveRule.default)
        @join, @leave = JoinRule.new(**join), LeaveRule.new(**leave)
      end

      def can_join = @join
      def can_leave = @leave
      def upon_leaving = @leave
    end
  end
end
