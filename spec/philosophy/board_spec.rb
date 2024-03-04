
RSpec.describe Philosophy::Board do
  let(:empty_board) { Philosophy::Board.new }
  let(:indigo) { Philosophy::Player.new(Philosophy::Player::Color.new(:indigo, :In)) }
  let(:teal) { Philosophy::Player.new(Philosophy::Player::Color.new(:teal, :Te)) }

  describe '#move' do
  end

  describe '#rotate' do
  end

  describe '#place' do
    it 'should place a tile' do
      context = empty_board.place(player: indigo, tile: :push, location: :C5, direction: :No)
      expect(context.spaces[:C5].tile).not_to be_nil
    end

    it 'should not place a tile in an occupied space' do
      context = empty_board.place(player: indigo, tile: :push, location: :C5, direction: :No)
      expect do
        context.to_board.place(player: teal, tile: :push, location: :C5, direction: :No)
      end.to raise_error(Philosophy::Board::PlacementError)
    end
  end
end
