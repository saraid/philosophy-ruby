module Enumerable
  def as_notation(context) = map { context.spaces[_1].notation }.sort
end

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

  describe '#place' do
    it 'should list exactly 1 possible activations' do
      context = initial_context.place(player: indigo, tile: :push, location: :C5, direction: :north)
      expect(context.possible_activations.size).to eq 1
      expect(context.possible_activations.first).to eq :C5
      expect(context.possible_activation_targets).to be_empty
    end
  end

  describe '#move' do
    it 'should handle a single tile' do
      context = initial_context
        .place(player: teal, tile: :push, location: :C5, direction: :north)
        .reset_context
        .move(from_location: :C5, impact_direction: :north)

      expect(context.possible_activations).to be_empty
      expect(context.possible_activation_targets).not_to be_empty
      expect(context.possible_activation_targets.as_notation(context)).to eq ['C2:TePuNo']
    end

    it 'should handle multiple tiles' do
      context = initial_context
        .place(player: teal, tile: :push, location: :C5, direction: :north)
        .place(player: teal, tile: :corner_push, location: :C6, direction: :nw)
        .reset_context
        .move(from_location: :C5, impact_direction: :east)

      expect(context.possible_activations).to be_empty
      expect(context.possible_activation_targets).not_to be_empty
      expect(context.possible_activation_targets.as_notation(context)).to eq %w[C6:TePuNo E3:TeCpNw]
    end

    it 'should handle multiple tiles with mixed ownership' do
      context = initial_context
        .place(player: indigo, tile: :push, location: :C5, direction: :north)
        .place(player: teal, tile: :corner_push, location: :C6, direction: :nw)
        .reset_context
        .move(from_location: :C5, impact_direction: :east)

      expect(context.possible_activations).not_to be_empty
      expect(context.possible_activations.as_notation(context)).to eq %w[C6:InPuNo]
      expect(context.possible_activation_targets).not_to be_empty
      expect(context.possible_activation_targets.as_notation(context)).to eq %w[E3:TeCpNw]
    end
  end

  describe '#rotate' do
    context 'if the targeted tile exists' do
      context 'if the targeted tile is owned by current player' do
        it do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C5, direction: :north)
            .place(player: indigo, tile: :corner_push, location: :C4, direction: :nw)
            .reset_context
            .rotate(target_location: :C5, target_direction: :west)

          expect(context.possible_activations.size).to eq 1
          expect(context.possible_activations.as_notation(context)).to eq ['C4:InCpNw']
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
          expect(context.possible_activation_targets.as_notation(context)).to eq ['C4:TeCpNw']
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

  describe '#activation_candidates' do
    context '#place' do
      it 'should only have 1 activation candidate' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :west)
          .reset_context
          .place(player: indigo, tile: :push, location: :C5, direction: :north)
        candidates = context.activation_candidates

        expect(candidates.size).to eq 1
        expect(candidates.as_notation(context)).to eq %w[C5:InPuNo]
      end
    end

    context '#move' do
      context 'when an opponent tile moves into a targeted space of an existing idea' do
        it 'is targetable' do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C6, direction: :north)
            .place(player: teal, tile: :push, location: :C5, direction: :north)
            .place(player: indigo, tile: :corner_push, location: :C7, direction: :ne)
            .reset_context
            .move(from_location: :C5, impact_direction: :ne)
          candidates = context.activation_candidates

          expect(candidates.size).to eq 1
          expect(candidates.as_notation(context)).to eq %w[C6:InPuNo]
        end
      end

      context 'when your existing idea moves and now targets an opponent tile' do
        it 'is activatable' do
          context = initial_context
            .place(player: indigo, tile: :push, location: :C5, direction: :north)
            .place(player: teal, tile: :push, location: :C6, direction: :north)
            .place(player: teal, tile: :corner_push, location: :C1, direction: :se)
            .reset_context
            .move(from_location: :C5, impact_direction: :se)
          candidates = context.activation_candidates

          expect(candidates.size).to eq 1
          expect(candidates.as_notation(context)).to eq %w[C9:InPuNo]
        end
      end

      context 'when both tiles move together' do
        it 'is activatable' do
          context = initial_context
            .place(player: indigo, tile: :pull_right, location: :C2, direction: :east)
            .place(player: teal, tile: :pull_right, location: :C3, direction: :north)
            .place(player: indigo, tile: :slide_left, location: :C6, direction: :north)
            .reset_context
            .move(from_location: :C3, impact_direction: :west)
          candidates = context.activation_candidates

          expect(candidates.size).to eq 1
          expect(candidates.as_notation(context)).to eq %w[C1:InPrEa]
        end
      end

      it 'does not activate a tile twice' do
        context = initial_context
          .place(player: indigo, tile: :long_shot, location: :E4, direction: :west)
          .place(player: teal, tile: :push, location: :C5, direction: :north)
          .reset_context
          .place(player: indigo, tile: :push, location: :C4, direction: :east)
          .activate(:C4)
          .tap { expect(_1.activation_candidates.to_a).to eq %i[ E4 ] }
          .activate(:E4)

        expect(context.activation_candidates).to be_empty
      end

      it 'may generate multiple candidates' do
        context = initial_context
          .place(player: indigo, tile: :push, location: :C6, direction: :north)
          .place(player: indigo, tile: :corner_push, location: :C5, direction: :ne)
          .place(player: teal, tile: :push, location: :C2, direction: :north)
          .reset_context
          .move(from_location: :C2, impact_direction: :east)

        expect(context.activation_candidates.to_a.sort).to eq %i[ C5 C6 ]
      end
    end
  end

  describe '#activate' do
    context 'Push' do
      it 'does the thing' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :push, location: :C5, direction: :north)
          .activate(:C5)

        expect(context[:C5].notation).to eq 'C5:InPuNo'
        expect(context[:C2]).not_to be_occupied
        expect(context[:N5].notation).to eq 'N5:TePuEa'
      end
    end

    context 'LongShot' do
      it 'does the thing' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :long_shot, location: :C8, direction: :north)
          .activate(:C8)

        expect(context[:C8].notation).to eq 'C8:InLsNo'
        expect(context[:C2]).not_to be_occupied
        expect(context[:N5].notation).to eq 'N5:TePuEa'
      end
    end

    context 'Toss' do
      it 'does the thing' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :toss, location: :C5, direction: :north)
          .activate(:C5)

        expect(context[:C5].notation).to eq 'C5:InToNo'
        expect(context[:C2]).not_to be_occupied
        expect(context[:C8].notation).to eq 'C8:TePuEa'
      end
    end

    context 'Persuade' do
      it 'does the thing' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :persuade, location: :C5, direction: :north)
          .activate(:C5)

        expect(context[:C2]).not_to be_occupied
        expect(context[:C5].notation).to eq 'C5:TePuEa'
        expect(context[:C8].notation).to eq 'C8:InPeNo'
      end
    end

    context 'Decision' do
      it 'builds options' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :decision, location: :C4, direction: :ne)
          .activate(:C4)

        expect(context.player_options).not_to be_empty
        expect(context.player_options.keys.sort).to eq %i[ C6 N4 ]
      end

      it 'can be completed left' do
        context_with_choices = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :decision, location: :C4, direction: :ne)
          .activate(:C4)

        context = context_with_choices.choose(:N4)

        expect(context[:N4].notation).to eq 'N4:TePuEa'
        expect(context[:C2]).not_to be_occupied
        expect(context[:C6]).not_to be_occupied
      end

      it 'can be completed right' do
        context_with_choices = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :decision, location: :C4, direction: :ne)
          .activate(:C4)

        context = context_with_choices.choose(:C6)

        expect(context[:C6].notation).to eq 'C6:TePuEa'
        expect(context[:C2]).not_to be_occupied
        expect(context[:N4]).not_to be_occupied
      end
    end

    context 'Rephrase' do
      it 'builds options for cardinal tiles' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :rephrase, location: :C4, direction: :ne)
          .activate(:C4)

        expect(context.player_options).not_to be_empty
        expect(context.player_options.keys.sort).to eq %i[ Ea No So We ]
      end

      it 'builds options for diagonal tiles' do
        context = initial_context
          .place(player: teal, tile: :corner_push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :rephrase, location: :C4, direction: :ne)
          .activate(:C4)

        expect(context.player_options).not_to be_empty
        expect(context.player_options.keys.sort).to eq %i[ Ne Nw Se Sw ]
      end

      it 'can be completed' do
        context = initial_context
          .place(player: teal, tile: :push, location: :C2, direction: :east)
          .reset_context
          .place(player: indigo, tile: :rephrase, location: :C4, direction: :ne)
          .activate(:C4)
          .choose(:No)

        expect(context[:C2].tile.target.value).to eq :north
      end
    end
  end
end
