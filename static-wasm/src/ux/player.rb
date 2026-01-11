puts "loaded #{__FILE__}"
module Ux
  Player = Data.define(:code, :color, :default_name)

  class Player
    DEFAULTS = {
      Am: {
        color: '#FFBF00',
        default_name: 'Ambrose Pierce',
      },
      In: {
        color: '#4B0082',
        default_name: 'Indiana Jones',
      },
      Sa: {
        color: '#B2AC88',
        default_name: 'Sarah Connor',
      },
      Te: {
        color: '#008080',
        default_name: 'Teotihual Batan',
      },
    }

    def self.available
      @available ||= Set.new(
        DEFAULTS.map do |code, kwargs|
          new(code:, **kwargs)
        end
      )
    end

    def self.add_available(player_code)
      DEFAULTS.fetch(player_code)
        .then { new(code: player_code, **_1) }
        .then { available << _1 }
    end
  end
end
