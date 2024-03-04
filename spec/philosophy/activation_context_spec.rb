RSpec.describe Philosophy::ActivationContext do
  let(:initial_context) do
    Philosophy::ActivationContext.new(indigo).with_spaces(Philosophy::Board.new.spaces)
  end
  let(:indigo) { Philosophy::Player.new(Philosophy::Player::Color.new(:indigo, :In)) }
  let(:teal) { Philosophy::Player.new(Philosophy::Player::Color.new(:teal, :Te)) }

  context 'when placing a tile' do
    it 'should list exactly 1 possible activations' do
      context = initial_context.place(player: indigo, tile: :push, location: :C5, direction: :north)
      expect(context.possible_activations.size).to eq 1
      expect(context.possible_activations[0].notation).to eq 'C5:InPuNo'
    end
  end

  context 'when rotating a tile' do
    context 'if the targeted tile exists' do
      context 'if the targeted tile is owned by current player' do
        it do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C5, direction: :north)
            .place(player: indigo, tile: :corner_push, location: :C4, direction: :nw)
            .rotate(target_location: :C5, target_direction: :west)

          expect(context.possible_activations.size).to eq 1
          expect(context.possible_activations[0].notation).to eq 'C4:InCpNw'
        end
      end

      context 'if the targeted tile is not owned by current player' do
        it do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C5, direction: :north)
            .place(player: teal, tile: :corner_push, location: :C4, direction: :nw)
            .rotate(target_location: :C5, target_direction: :west)

          expect(context.possible_activations).to be_empty
          expect(context.possible_activation_targets.size).to eq 1
          expect(context.possible_activation_targets[0].notation).to eq 'C4:TeCpNw'
        end
      end
    end

    context 'if targeted tile does not exist' do
      it do
        context = initial_context
          .place(player: indigo, tile: :push, location: :C5, direction: :north)
          .rotate(target_location: :C5, target_direction: :west)

        expect(context.possible_activations).to be_empty
        expect(context.possible_activation_targets).to be_empty
      end
    end
  end
end
