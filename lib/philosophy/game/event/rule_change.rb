module Philosophy
  class Game
    class Event
      class RuleChange < Event
        REGEXES = {
          rule: "(?<rule>join|leave)",
          variable: "(?<variable>permitted|where|what)",
          value: "(?<value>\\w+)",
        }
        NOTATION_REGEX = REGEXES
          .values_at(:rule, :variable, :value)
          .prepend(:rule)
          .join(':')
          .then { Regexp.new _1 }

        def self.from_notation(notation)
          md = notation.match(NOTATION_REGEX)
          new(
            rule: md[:rule].to_sym,
            variable: md[:variable].to_sym,
            value: md[:value].to_sym
          )
        end

        def initialize(rule:, variable:, value:)
          @rule, @variable, @value = rule, variable, value
        end
        attr_reader :rule, :variable, :value

        def execute(game) = game.rule_change(rule: rule, variable: variable, value: value)
        def notation = [:rule, rule, variable, value].join(':')
      end
    end
  end
end
