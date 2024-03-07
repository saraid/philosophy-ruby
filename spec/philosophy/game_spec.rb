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
        game << Philosophy::Game::Event.from_notation('C1')
        expect(game.board_state).to eq 'C1:InPuNo/C7:TeDeNe'
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
        game << Philosophy::Game::Event.from_notation('We')
        expect(game.board_state).to eq 'C5:InPuWe/C7:TeReNe'
      end
    end
  end
end
