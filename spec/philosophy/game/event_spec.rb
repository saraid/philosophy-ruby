RSpec.describe Philosophy::Game::Event do
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

      it 'handles having a color name that has whitespace' do
        event = Philosophy::Game::PlayerChange.from_notation('In+:Charlie Brown')
        expect(event.code).to eq :In
        expect(event.type).to eq :joined
        expect(event.name).to eq :"Charlie Brown"
      end

      it 'handles having a color name that has unicode' do
        event = Philosophy::Game::PlayerChange.from_notation('In+:老子')
        expect(event.code).to eq :In
        expect(event.type).to eq :joined
        expect(event.name).to eq :"老子"
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
        expect(event.conclusions).to eq 0
      end

      it 'supports an incomplete parameter list' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo[No')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to eq %i[ No ]
        expect(event.conclusions).to eq 0
      end

      it 'supports an complete parameter list' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo[No]')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to eq %i[ No ]
        expect(event.conclusions).to eq 0
      end

      it 'supports a conclusion' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo.')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to be_empty
        expect(event.conclusions).to eq 1
      end

      it 'supports many conclusions' do
        event = Philosophy::Game::Placement.from_notation('In:C4PuNo...')
        expect(event.player).to eq :In
        expect(event.location).to eq :C4
        expect(event.tile).to eq :Pu
        expect(event.direction).to eq :No
        expect(event.parameters).to be_empty
        expect(event.conclusions).to eq 3
      end
    end
  end
end
