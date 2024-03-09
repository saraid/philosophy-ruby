RSpec.describe Philosophy::Game::History do
  let(:game) { Philosophy::Game.new }

  context 'normally' do
    let(:history) { game.history.notation(delimiter: ';') }

    it 'handles placements' do
      game << 'In+'
      game << 'Te+'
      game << 'In:C5PuNo'
      game << 'Te:C8PuNo'
      expect(history).to eq 'In+;Te+;In:C5PuNo;Te:C8PuNo'
    end

    it 'handles placements with parameters' do
      game << 'In+'
      game << 'Te+'
      game << 'In:C5PuNo'
      game << 'Te:C7ReNe[Ea]'
      expect(game.player_options).to be_empty
      expect(history).to eq 'In+;Te+;In:C5PuNo;Te:C7ReNe[Ea]'
    end

    it 'handles incomplete placements' do
      game << 'In+'
      game << 'Te+'
      game << 'In:C5PuNo'
      game << 'Te:C7ReNe'
      expect(game.player_options).to eq %i[ Ea No So We ]
      expect(history).to eq 'In+;Te+;In:C5PuNo;Te:C7ReNe(EaNoSoWe)'
    end

    it 'handles partially complete placements' do
      game << 'In+'
      game << 'Te+'
      game << 'In:C2ReSw'
      game << 'Te:C8PuSo'
      game << 'In:C6DeSw[C4'
      expect(game.player_options).to eq %i[ Ea No So We ]
      expect(history).to eq 'In+;Te+;In:C2ReSw;Te:C8PuSo;In:C6DeSw[C4(EaNoSoWe)'
    end
  end
end
