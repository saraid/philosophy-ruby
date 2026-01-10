module Ux
  module Move
    def self.current
      @current ||= {
        player: nil,
        location: nil,
        tile: nil,
        direction: nil,
      }
    end

    def self.submit!
      current_game << Philosophy::Game::Placement.new(**current)
      check_for_parameters!
    end

    def self.choose!(choice)
      current_game << Philosophy::Game::Choice.new(choice:)
      check_for_parameters!
    end

    REPHRASE_OPTIONS = Philosophy::IdeaTile::VALID_TARGETS.values
      .map { |dir| dir.map { Philosophy::Board::TWO_CHAR_DIRECTIONS[_1] }.sort } 
    def self.check_for_parameters!
      return complete! if current_game.player_options.empty?

      case current_game.player_options
      when *REPHRASE_OPTIONS # rephrase
        Ux::State.set_to Ux::State.choose_direction_for_choice
        location = current_game.board[current_move[:location]].coordinate
          .translate(Philosophy::Board::Direction[current_move[:direction]])
          .then { current_game.board[_1] }
        Ux::Board::Compass.activate! location:, options: current_game.player_options
      else
        Ux::State.set_to Ux::State.choose_space_for_choice
      end
    end

    def self.complete!
      @current = nil
      Ux::State.set_to Ux::State.choose_tile_for_move
      Ux.render
    end
  end
end
