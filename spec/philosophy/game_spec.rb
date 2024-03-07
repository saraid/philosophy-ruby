RSpec.describe Philosophy::Game do
  describe Philosophy::Game::PlayerChange do
    describe '.from_notation' do
      it 'handles joining' do
        event = Philosophy::Game::PlayerChange.from_notation('In+')
        expect(event.code).to eq :In
        expect(event.type).to eq :joined
      end

      it 'handles having a color name' do
        event = Philosophy::Game::PlayerChange.from_notation('In+:indigo')
        expect(event.code).to eq :In
        expect(event.type).to eq :joined
        expect(event.name).to eq :indigo
      end

      it 'handles leaving' do
        event = Philosophy::Game::PlayerChange.from_notation('In-')
        expect(event.code).to eq :In
        expect(event.type).to eq :left
      end
    end
  end

  describe Philosophy::Game::Placement do
    describe '.from_notation' do
      it 'supports a minimal notation' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to be_empty
        expect(event).not_to be_conclusion
      end

      it 'supports an incomplete parameter list' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo[No')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to eq %i[ No ]
        expect(event).not_to be_conclusion
      end

      it 'supports an complete parameter list' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo[No]')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to eq %i[ No ]
        expect(event).not_to be_conclusion
      end

      it 'supports a conclusion' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo.')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to be_empty
        expect(event).to be_conclusion
      end
    end
  end

  describe Philosophy::Game do
    context 'simple play' do
      it 'triggers activations properly' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        expect(game.board_state).to eq 'C5:InPuNo'
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('Te:C8PuNo')
        expect(game.board_state).to eq 'C2:InPuNo/C8:TePuNo'
        expect(game.current_player.color.name).to eq :indigo
      end
    end

    context 'handles a decision' do
      it 'handles player choice' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        expect(game.board_state).to eq 'C5:InPuNo'
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('Te:C7DeNe')
        expect(game.player_options).to eq %i[ C1 C9 ]
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('C1')
        expect(game.board_state).to eq 'C1:InPuNo/C7:TeDeNe'
        expect(game.player_options).to be_empty
        expect(game.current_player.color.name).to eq :indigo
      end

      it 'handles notational parameters' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        expect(game.board_state).to eq 'C5:InPuNo'
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('Te:C7DeNe[C1]')
        expect(game.player_options).to be_empty
        expect(game.board_state).to eq 'C1:InPuNo/C7:TeDeNe'
        expect(game.current_player.color.name).to eq :indigo
      end

      it 'handles a decision that pushes the piece off the board' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Sa+:sage')
        game << Philosophy::Game::Event.from_notation('In:C3DeNw')
        game << Philosophy::Game::Event.from_notation('Sa:C2SlNo')
        expect(game.players[:sage].has_idea?(:Sl)).to eq false
        game << Philosophy::Game::Event.from_notation('In:C5SrNo')
        expect(game.board_state).to eq 'C3:SaSlNo/C5:InSrNo/E1:InDeNw'
        game << Philosophy::Game::Event.from_notation('Sa:C8PuNo')
        game << Philosophy::Game::Event.from_notation('In:C6PuNo')
        expect(game.player_options).to eq %i[ C2 OO ]
        game << Philosophy::Game::Event.from_notation('OO')
        expect(game.players[:sage].has_idea?(:Sl)).to eq true
      end
    end

    context 'handles a rephrase' do
      it 'handles player choice' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        expect(game.board_state).to eq 'C5:InPuNo'
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('Te:C7ReNe')
        expect(game.player_options).to eq %i[ Ea No So We ]
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('We')
        expect(game.board_state).to eq 'C5:InPuWe/C7:TeReNe'
        expect(game.current_player.color.name).to eq :indigo
      end

      it 'handles notational parameters' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        expect(game.board_state).to eq 'C5:InPuNo'
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('Te:C7ReNe[We]')
        expect(game.board_state).to eq 'C5:InPuWe/C7:TeReNe'
        expect(game.current_player.color.name).to eq :indigo
      end
    end

    context 'detects conclusions' do
      it 'no reaction just conclusion' do
        game = Philosophy::Game.new
        %w[
          In+:indigo
          Te+:teal
          In:C1PuNo
          Te:C7PuSo
          In:C2SlNo
          Te:C8SlSo
          In:C3SrNo
        ].each { game << Philosophy::Game::Event.from_notation(_1) }

        expect(game.board_state).to eq 'C1:InPuNo/C2:InSlNo/C3:InSrNo/C7:TePuSo/C8:TeSlSo'
        expect(game).to be_concluded
        expect(game.conclusions).to eq [Set.new([:C1, :C2, :C3])]
      end

      it 'sees near conclusions' do
        game = Philosophy::Game.new
        %w[
          In+:indigo
          Te+:teal
          In:C1PuNo
          Te:C7PuSo
          In:C2SlNo
          Te:C8SlSo
        ].each { game << Philosophy::Game::Event.from_notation(_1) }

        expect(game.board_state).to eq 'C1:InPuNo/C2:InSlNo/C7:TePuSo/C8:TeSlSo'
        expect(game).to be_nearing_conclusion
      end
    end

    context 'handles the respect token' do
      it 'should start unpossessed' do
        game = Philosophy::Game.new
        expect(game.holding_respect_token).to be_nil
      end

      it 'should be passable to another player from unpossessed' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        game << Philosophy::Game::Event.from_notation('R:In')
        expect(game.holding_respect_token).to eq :In
      end

      it 'should be passable to player from another player' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        game << Philosophy::Game::Event.from_notation('R:In')
        expect(game.holding_respect_token).to eq :In
        game << Philosophy::Game::Event.from_notation('Te:C8PuNo')
        game << Philosophy::Game::Event.from_notation('R:Te')
        expect(game.holding_respect_token).to eq :Te
      end
    end

    context 'raises errors' do
      let(:game) do
        Philosophy::Game.new.tap do
          _1 << Philosophy::Game::Event.from_notation('In+:indigo')
          _1 << Philosophy::Game::Event.from_notation('Te+:teal')
        end
      end

      it 'should not allow invalid tile types' do
        expect { game << Philosophy::Game::Event.from_notation('In:C5XxNo') }
          .to raise_error(Philosophy::Game::Placement::InvalidTileType)
      end

      it 'should not allow invalid tile locations' do
        expect { game << Philosophy::Game::Event.from_notation('In:N9PuNo') }
          .to raise_error(Philosophy::Game::Placement::InvalidLocation)
      end

      it 'should not allow playing outside of the center' do
        expect { game << Philosophy::Game::Event.from_notation('In:N1PuNo') }
          .to raise_error(Philosophy::Game::Placement::LocationOutsidePlacementSpace)
      end

      it 'should not allow orienting somewhere invalid' do
        expect { game << Philosophy::Game::Event.from_notation('In:C5PuNw') }
          .to raise_error(Philosophy::Game::Placement::CannotOrientInTargetDirection)
      end

      it 'should not allow an unavailable choice with parameter notation' do
        game << Philosophy::Game::Event.from_notation('In:C5SrSo')
        expect { game << Philosophy::Game::Event.from_notation('Te:C7DeNe[C8]') }
          .to raise_error(Philosophy::Game::Choice::Error)
      end

      it 'should not allow an unavailable choice with manual choice' do
        game << Philosophy::Game::Event.from_notation('In:C5SrSo')
        game << Philosophy::Game::Event.from_notation('Te:C7DeNe')
        expect { game << Philosophy::Game::Event.from_notation('No') }
          .to raise_error(Philosophy::Game::Choice::Error)
      end

      it 'should not allow unavailable tiles' do
        game << Philosophy::Game::Event.from_notation('In:C5SrNo')
        game << Philosophy::Game::Event.from_notation('Te:C2SlNo')
        expect { game << Philosophy::Game::Event.from_notation('In:C8SrNo') }
          .to raise_error(Philosophy::Game::Placement::UnavailableTile)
      end

      it 'should not allow stacking tiles' do
        game << Philosophy::Game::Event.from_notation('In:C5SrNo')
        expect { game << Philosophy::Game::Event.from_notation('Te:C5SrNo') }
          .to raise_error(Philosophy::Game::Placement::CannotPlaceAtopExistingTile)
      end
    end
  end
end
