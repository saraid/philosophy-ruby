module Philosophy
  class Game
    class History
      include Enumerable

      def initialize
        @events = []
      end

      def <<(event) = @events << event
      def each(...) = @events.each(...)
    end
  end
end

