module Philosophy
  class Game
    class History
      include Enumerable

      def initialize
        @events = []
      end

      def <<(event) = @events << event
      def each(...) = @events.each(...)

      def notation(delimiter: $/)
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
          else
            skipped_events.each { result << _1.notation }
            result << event.notation
          end
        end
        skipped_events.each { result << _1.notation }
        result.join(delimiter)
      end
    end
  end
end
