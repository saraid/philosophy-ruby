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

    it 'handles placements with multiple parameters' do
      game << 'In+'
      game << 'Te+'
      game << 'In:C2ReSw'
      game << 'Te:C8PuSo'
      game << 'In:C6DeSw[C4So]'
      expect(game.player_options).to be_empty
      expect(history).to eq 'In+;Te+;In:C2ReSw;Te:C8PuSo;In:C6DeSw[C4So]'
    end

    it 'rolls up choices into placements' do
      game << 'In+'
      game << 'Te+'
      game << 'In:C2ReSw'
      game << 'Te:C8PuSo'
      game << 'In:C6DeSw'
      game << 'C4'
      game << 'So'
      expect(game.player_options).to be_empty
      expect(history).to eq 'In+;Te+;In:C2ReSw;Te:C8PuSo;In:C6DeSw[C4So]'
    end

    it 'notices conclusions' do
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C1PuNo'
      game << 'Te:C7PuSo'
      game << 'In:C2SlNo'
      game << 'Te:C8SlSo'
      game << 'In:C3SrNo'
      expect(game).to be_concluded
      expect(history).to eq 'In+;Te+;In:C1PuNo;Te:C7PuSo;In:C2SlNo;Te:C8SlSo;In:C3SrNo.'
    end

    it 'notices multiple conclusions' do
      game << 'In+:indigo'
      game << 'Te+:teal'
      game << 'In:C4PuSo'
      game << 'Te:C1PuNo'
      game << 'In:C5SlSo'
      game << 'Te:C2SlNo'
      game << 'In:C9SrNo'
      game << 'Te:C6PeSo'
      expect(game).not_to be_concluded # because there are multiple conclusions
      expect(history).to eq 'In+;Te+;In:C4PuSo;Te:C1PuNo;In:C5SlSo;Te:C2SlNo;In:C9SrNo;Te:C6PeSo..'
    end
  end
end
