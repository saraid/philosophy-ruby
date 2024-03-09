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
            choices = []
            begin
              choices << iter.next.choice while Choice === iter.peek
            rescue StopIteration
              # ignore when peek raises StopIteration
            end
            result << event.notation(parameters: event.parameters + choices)
          else result << event.notation
          end
        end
        result.join(delimiter)
      end
    end
  end
end
