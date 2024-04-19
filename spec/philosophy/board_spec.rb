RSpec.describe Philosophy::Board do
  let(:initial_context) do
    Philosophy::ActivationContext.new(indigo).with_spaces(Philosophy::Board.new.spaces)
  end
  let(:indigo) { Philosophy::Player.new(Philosophy::Player::Color.new(:indigo, :In)) }
  let(:teal) { Philosophy::Player.new(Philosophy::Player::Color.new(:teal, :Te)) }

  it 'should have W2 directly west of C1' do
    board = initial_context.to_board
    expect(board[:C1].neighbors[:west]).to eq board[:W2]
  end

  describe '#concluded?' do
    it 'should notice a conclusion' do
      board = initial_context
        .place(player: indigo, tile: :push, location: :C4, direction: :north)
        .place(player: indigo, tile: :long_shot, location: :C5, direction: :north)
        .place(player: indigo, tile: :slide_right, location: :C6, direction: :north)
        .to_board

      expect(board).to be_concluded
    end

    it 'should not mark a conclusion with multiple owners' do
      board = initial_context
        .place(player: indigo, tile: :push, location: :C4, direction: :north)
        .place(player: teal, tile: :long_shot, location: :C5, direction: :north)
        .place(player: indigo, tile: :slide_right, location: :C6, direction: :north)
        .to_board

      expect(board).not_to be_concluded
    end

    it 'should not mark a conclusion without three tiles' do
      board = initial_context
        .place(player: indigo, tile: :push, location: :C4, direction: :north)
        .place(player: indigo, tile: :slide_right, location: :C6, direction: :north)
        .to_board

      expect(board).not_to be_concluded
    end
  end

  describe '#nearing_conclusion?' do
    it 'should notice a conclusion is near' do
      board = initial_context
        .place(player: indigo, tile: :push, location: :C4, direction: :north)
        .place(player: indigo, tile: :slide_right, location: :C6, direction: :north)
        .to_board

      expect(board).to be_nearing_conclusion
    end

    it 'should not mark a conclusion with unplayable third space' do
      board = initial_context
        .place(player: indigo, tile: :push, location: :C2, direction: :north)
        .place(player: indigo, tile: :slide_right, location: :C6, direction: :north)
        .to_board

      expect(board).not_to be_concluded
    end
  end
end
