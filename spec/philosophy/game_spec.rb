RSpec.describe Philosophy::Game do
  context 'simple play' do
    it 'triggers activations properly' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C4PuNo'
      expect(game.board_state).to eq 'C4:InPuNo'
      expect(game.current_player.color.name).to eq :teal
      game << 'Te:C7PuNo'
      expect(game.board_state).to eq 'C1:InPuNo/C7:TePuNo'
      expect(game.current_player.color.name).to eq :indigo
      expect(game.history.notation(delimiter: ';')).to eq 'In+;Te+;In:C4PuNo;Te:C7PuNo'
    end
  end

  context 'on the next turn' do
    it 'can activate the same tile' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C6PuNo'
      game << 'Te:C3PuSo'
      expect(game.board_state).to eq 'C3:TePuSo/C9:InPuNo'
      expect(game.player_options).to be_empty
      expect(game.board.spaces[:C3].tile).not_to be_already_activated
      game << 'In:C1CpNe'
      expect(game.board_state).to eq 'C1:InCpNe/C3:TePuSo/C9:InPuNo'
      game << 'Te:C7SlEa'
      expect(game.board_state).to eq 'C1:InCpNe/C3:TePuSo/C7:TeSlEa/C9:InPuNo'
    end
  end

  context 'handles a decision' do
    it 'handles player choice' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C3PuNo'
      expect(game.board_state).to eq 'C3:InPuNo'
      expect(game.current_player.color.name).to eq :teal
      game << 'Te:C5DeNe'
      expect(game.player_options).to eq %i[ E3 N5 ]
      expect(game.current_player.color.name).to eq :teal
      game << 'E3'
      expect(game.board_state).to eq 'C5:TeDeNe/E3:InPuNo'
      expect(game.player_options).to be_empty
      expect(game.current_player.color.name).to eq :indigo
    end

    it 'handles notational parameters' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C3PuNo'
      expect(game.board_state).to eq 'C3:InPuNo'
      expect(game.current_player.color.name).to eq :teal
      game << 'Te:C5DeNe[E3]'
      expect(game.player_options).to be_empty
      expect(game.board_state).to eq 'C5:TeDeNe/E3:InPuNo'
      expect(game.current_player.color.name).to eq :indigo
    end

    it 'handles a decision that pushes the piece off the board' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Sa+:sage'
      game << 'In:C3DeNw'
      game << 'Sa:C2SlNo'
      expect(game.players[:sage].has_idea?(:Sl)).to eq false
      game << 'In:C5SrNo'
      expect(game.board_state).to eq 'C3:SaSlNo/C5:InSrNo/E1:InDeNw'
      game << 'Sa:C8PuNo'
      game << 'In:C6PuNo'
      expect(game.player_options).to eq %i[ C2 OO ]
      game << 'OO'
      expect(game.players[:sage].has_idea?(:Sl)).to eq true
    end
  end

  context 'handles a rephrase' do
    it 'handles player choice' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C6PuNo'
      expect(game.board_state).to eq 'C6:InPuNo'
      expect(game.current_player.color.name).to eq :teal
      game << 'Te:C8ReNe'
      expect(game.player_options).to eq %i[ Ea No So We ]
      expect(game.current_player.color.name).to eq :teal
      game << 'We'
      expect(game.board_state).to eq 'C6:InPuWe/C8:TeReNe'
      expect(game.current_player.color.name).to eq :indigo
    end

    it 'handles notational parameters' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C6PuNo'
      expect(game.board_state).to eq 'C6:InPuNo'
      expect(game.current_player.color.name).to eq :teal
      game << 'Te:C8ReNe[We]'
      expect(game.board_state).to eq 'C6:InPuWe/C8:TeReNe'
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
      ].each { game << _1 }

      expect(game.board_state).to eq 'C1:InPuNo/C2:InSlNo/C3:InSrNo/C7:TePuSo/C8:TeSlSo'
      expect(game).to be_concluded
      conclusion = Set.new([:C1, :C2, :C3])
      expect(game.conclusions).to eq({ conclusion => game.players[:indigo] })
      expect(game.winner).to eq game.players[:indigo]
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
      ].each { game << _1 }

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
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C4PuNo'
      game << 'R:In'
      expect(game.holding_respect_token).to eq :In
    end

    it 'should be passable to player from another player' do
      game = Philosophy::Game.new
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C4PuNo'
      game << 'R:In'
      expect(game.holding_respect_token).to eq :In
      game << 'Te:C8PuNo'
      game << 'R:Te'
      expect(game.holding_respect_token).to eq :Te
    end
  end

  context 'raises errors' do
    let(:game) do
      Philosophy::Game.new.tap do
        _1 << 'In+:indigo'
        _1 << 'Te+:teal'
      end
    end

    it 'should not allow placement with less than 2 players' do
      game2 = Philosophy::Game.new
      expect { game2 << 'In:C5XxNo' }
        .to raise_error(Philosophy::Game::InsufficientPlayers)
    end

    it 'should not allow player joining with the same color code' do
      game2 = Philosophy::Game.new
      game2 << 'In+'
      expect { game2 << 'In+' }
        .to raise_error(Philosophy::Game::PlayerChange::PlayerCodeAlreadyUsed)
    end

    it 'should not allow placement by a different player' do
      expect { game << 'Sa:C4PuNo' }
        .to raise_error(Philosophy::Game::Placement::IncorrectPlayer)
    end

    it 'should not allow invalid tile types' do
      expect { game << 'In:C4XxNo' }
        .to raise_error(Philosophy::Game::Placement::InvalidTileType)
    end

    it 'should not allow invalid tile locations' do
      expect { game << 'In:N9PuNo' }
        .to raise_error(Philosophy::Game::Placement::InvalidLocation)
    end

    it 'should not allow playing outside of the center' do
      expect { game << 'In:N1PuNo' }
        .to raise_error(Philosophy::Game::Placement::LocationOutsidePlacementSpace)
    end

    it 'should not allow orienting somewhere invalid' do
      expect { game << 'In:C4PuNw' }
        .to raise_error(Philosophy::Game::Placement::CannotOrientInTargetDirection)
    end

    it 'should not allow an unavailable choice with parameter notation' do
      game << 'In:C4SrSo'
      expect { game << 'Te:C7DeNe[C8]' }
        .to raise_error(Philosophy::Game::Choice::Error)
    end

    it 'should not allow an unavailable choice with manual choice' do
      game << 'In:C4SrSo'
      game << 'Te:C7DeNe'
      expect { game << 'No' }
        .to raise_error(Philosophy::Game::Choice::Error)
    end

    it 'should not allow unavailable tiles' do
      game << 'In:C4SrNo'
      game << 'Te:C2SlNo'
      expect { game << 'In:C8SrNo' }
        .to raise_error(Philosophy::Game::Placement::UnavailableTile)
    end

    it 'should not allow stacking tiles' do
      game << 'In:C4SrNo'
      expect { game << 'Te:C4SrNo' }
        .to raise_error(Philosophy::Game::Placement::CannotPlaceAtopExistingTile)
    end
  end

  describe '.from_pgn' do
    let(:fixture) { pgn(:sample) }
    let(:game) { Philosophy::Game.from_pgn fixture }

    it 'should set rules' do
      # One of the moves turns on a custom join rule.
      expect { game }.not_to raise_error
    end

    it 'should set color names' do
      expect(game.players).to have_key('Indiana Jones')
      expect(game.players[:In].color.name).to eq 'Indiana Jones'
    end
  end
end
