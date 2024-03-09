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
        iter = @events.each
        loop do
          event = iter.next
          break if event.nil?
          case event
          when Placement
            last_choice = nil
            choices = []
            begin
              choices << (last_choice = iter.next).choice while Choice === iter.peek
            rescue StopIteration
              # ignore when peek raises StopIteration
            end
            result << event.notation(
              parameters: event.parameters + choices,
              options: (last_choice&.options || event.options).to_h
            )
          else result << event.notation
          end
        end
        result.join(delimiter)
      end
    end
  end
end
