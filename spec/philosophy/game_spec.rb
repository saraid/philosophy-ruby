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
    context 'simple game' do
      it 'plays' do
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
      it 'plays' do
        game = Philosophy::Game.new
        game << Philosophy::Game::Event.from_notation('In+:indigo')
        game << Philosophy::Game::Event.from_notation('Te+:teal')
        game << Philosophy::Game::Event.from_notation('In:C5PuNo')
        expect(game.board_state).to eq 'C5:InPuNo'
        expect(game.current_player.color.name).to eq :teal
        game << Philosophy::Game::Event.from_notation('Te:C7DeNe')
        expect(game.current_context.player_options).not_to be_empty
      end
    end
  end
end
