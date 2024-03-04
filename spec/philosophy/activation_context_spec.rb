RSpec.describe Philosophy::ActivationContext do
  let(:initial_context) do
    Philosophy::ActivationContext.new(indigo).with_spaces(Philosophy::Board.new.spaces)
  end
  let(:indigo) { Philosophy::Player.new(Philosophy::Player::Color.new(:indigo, :In)) }
  let(:teal) { Philosophy::Player.new(Philosophy::Player::Color.new(:teal, :Te)) }

  describe '#next_context' do
    it 'copies spaces' do
      context = initial_context
        .with_spaces(initial_context.spaces[:C5].with(tile: Philosophy::Tile::Push.new(indigo)))
        .next_context
      expect(context.spaces[:C5]).to be_occupied
    end

    it 'copies removed tiles' do
      removed_tile = Philosophy::Tile::Push.new(indigo)
      context = initial_context
        .removing_tile(removed_tile)
        .next_context
      expect(context.removed_tiles).not_to be_empty
      expect(context.removed_tiles.first).to eq removed_tile
    end

    it 'copies possible activations' do
      context = initial_context
        .can_activate(:C5)
        .next_context

      expect(context.possible_activations.first).to eq :C5
    end

    it 'copies possible activation targets' do
      context = initial_context
        .can_be_activated(:C5)
        .next_context

      expect(context.possible_activation_targets.first).to eq :C5
    end
  end

  context 'when placing a tile' do
    it 'should list exactly 1 possible activations' do
      context = initial_context.place(player: indigo, tile: :push, location: :C5, direction: :north)
      expect(context.possible_activations.size).to eq 1
      expect(context.possible_activations.first).to eq :C5
    end
  end

  context 'when rotating a tile' do
    context 'if the targeted tile exists' do
      context 'if the targeted tile is owned by current player' do
        it do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C5, direction: :north)
            .place(player: indigo, tile: :corner_push, location: :C4, direction: :nw)
            .reset_context
            .rotate(target_location: :C5, target_direction: :west)

          expect(context.possible_activations.size).to eq 1
          expect(context.spaces[context.possible_activations.first].notation).to eq 'C4:InCpNw'
        end
      end

      context 'if the targeted tile is not owned by current player' do
        it do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C5, direction: :north)
            .place(player: teal, tile: :corner_push, location: :C4, direction: :nw)
            .reset_context
            .rotate(target_location: :C5, target_direction: :west)

          expect(context.possible_activations).to be_empty
          expect(context.possible_activation_targets.size).to eq 1
          expect(context.spaces[context.possible_activation_targets.first].notation).to eq 'C4:TeCpNw'
        end
      end
    end

    context 'if targeted tile does not exist' do
      it do
        context = initial_context
          .place(player: indigo, tile: :push, location: :C5, direction: :north)
          .reset_context
          .rotate(target_location: :C5, target_direction: :west)

        expect(context.possible_activations).to be_empty
        expect(context.possible_activation_targets).to be_empty
      end
    end
  end
end
