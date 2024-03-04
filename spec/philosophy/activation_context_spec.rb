RSpec.describe Philosophy::ActivationContext do
  let(:empty_board) { Philosophy::ActivationContext.new(indigo).with_spaces(Philosophy::Board.new.spaces) }
  let(:indigo) { Philosophy::Player.new(Philosophy::Player::Color.new(:indigo, :In)) }
  let(:teal) { Philosophy::Player.new(Philosophy::Player::Color.new(:teal, :Te)) }

  context 'when placing a tile' do
    it 'should list exactly 1 possible activations' do
      context = empty_board.place(player: indigo, tile: :push, location: :C5, direction: :north)
      expect(context.possible_activations.size).to eq 1
      expect(context.possible_activations[0].notation).to eq 'C5:InPuNo'
    end
  end

  context 'when rotating a tile' do
    it 'should list no possible activations if the tile is not owned by current player' do
    end
  end
end
