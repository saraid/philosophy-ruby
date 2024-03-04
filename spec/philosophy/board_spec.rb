RSpec.describe Philosophy::Board do
  let(:empty_board) { Philosophy::Board.new }
  let(:indigo) { Philosophy::Player.new(Philosophy::Player::Color.new(:indigo, :In)) }
  let(:teal) { Philosophy::Player.new(Philosophy::Player::Color.new(:teal, :Te)) }

  describe '#move' do
    it 'should move a tile' do
      board = empty_board.place(player: indigo, tile: :push, location: :C5, direction: :north).to_board
      result = board.move(from_location: :C5, impact_direction: :east).to_board

      expect(result[:C5]).not_to be_occupied
      expect(result[:C6]).to be_occupied
    end

    it 'should handle collisions' do
      board = empty_board
        .place(player: indigo, tile: :push, location: :C4, direction: :north).to_board
        .place(player: teal, tile: :push, location: :C5, direction: :north).to_board
      result = board.move(from_location: :C4, impact_direction: :east).to_board

      expect(result[:C4]).not_to be_occupied
      expect(result[:C5]).to be_occupied
      expect(result[:C5].notation).to eq 'C5:InPuNo'
      expect(result[:C6]).to be_occupied
      expect(result[:C6].notation).to eq 'C6:TePuNo'
    end

    it 'should handle lots of collisions' do
      board = empty_board
        .place(player: indigo, tile: :push, location: :C4, direction: :north).to_board
        .place(player: teal, tile: :push, location: :C5, direction: :north).to_board
        .place(player: indigo, tile: :slide_left, location: :C6, direction: :north).to_board
        .place(player: teal, tile: :slide_left, location: :E3, direction: :north).to_board
      result = board.move(from_location: :C4, impact_direction: :east).to_board

      expect(result[:C4]).not_to be_occupied
      expect(result[:C5]).to be_occupied
      expect(result[:C5].notation).to eq 'C5:InPuNo'
      expect(result[:C6]).to be_occupied
      expect(result[:C6].notation).to eq 'C6:TePuNo'
      expect(result[:E3]).to be_occupied
      expect(result[:E3].notation).to eq 'E3:InSlNo'
      expect(result[:E4]).to be_occupied
      expect(result[:E4].notation).to eq 'E4:TeSlNo'
    end

    it 'should remove tiles when they fall off the board' do
      board = empty_board
        .place(player: indigo, tile: :push, location: :NW, direction: :north).to_board
      context = board.move(from_location: :NW, impact_direction: :nw)

      expect(context.to_board[:NW]).not_to be_occupied
      expect(context.removed_tiles.size).to eq 1
      expect(context.removed_tiles[0].notation).to eq 'InPuNo'
    end
  end

  describe '#rotate' do
    it 'should rotate the tile' do
      board = empty_board
        .place(player: indigo, tile: :push, location: :C5, direction: :north).to_board
      context = board.rotate(target_location: :C5, target_direction: :west)

      expect(context.to_board[:C5]).to be_occupied
      expect(context.to_board[:C5].notation).to eq 'C5:InPuWe'
    end
  end

  describe '#place' do
    it 'should place a tile' do
      context = empty_board.place(player: indigo, tile: :push, location: :C5, direction: :north)
      expect(context.spaces[:C5].tile).not_to be_nil
    end

    it 'should not place a tile in an occupied space' do
      context = empty_board.place(player: indigo, tile: :push, location: :C5, direction: :north)
      expect do
        context.to_board.place(player: teal, tile: :push, location: :C5, direction: :north)
      end.to raise_error(Philosophy::Board::PlacementError)
    end
  end
end
