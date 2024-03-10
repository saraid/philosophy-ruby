module Philosophy
  class Game
    class History
      include Enumerable

      def initialize
        @events = []
      end

      def <<(event) = @events << event
      def each(...) = @events.each(...)

      def notation(delimiter: $/, with_ordinals: false, with_player_change: true, with_rule_change: true)
        last_placement = nil
        result = []
        skipped_events = []
        iter = @events.each
        loop do
          event = iter.next
          break if event.nil?
          case event
          when Placement
            last_choice = nil
            choices = []
            begin
              loop do
                case iter.peek
                when Choice
                  choices << (last_choice = iter.next).choice
                when Placement
                  break
                when PlayerChange
                  skipped_events << iter.next if with_player_change
                when RuleChange
                  skipped_events << iter.next if with_rule_change
                else
                  skipped_events << iter.next
                end
              end
            rescue StopIteration
              # ignore when peek raises StopIteration
            end
            result << event.notation(
              parameters: event.parameters + choices,
              options: (last_choice&.options || event.options).to_h
            )
          when PlayerChange
            next unless with_player_change
            skipped_events.each { result << _1.notation }
            result << event.notation
          when RuleChange
            next unless with_rule_change
            skipped_events.each { result << _1.notation }
            result << event.notation
          else
            skipped_events.each { result << _1.notation }
            result << event.notation
          end
        end
        skipped_events.each { result << _1.notation }
        
        result.map!.with_index { "#{"%#{Math.log10(result.size).floor+1}d" % (_2+1)}. #{_1}" } if with_ordinals
        result.join(delimiter)
      end
    end
  end
end
