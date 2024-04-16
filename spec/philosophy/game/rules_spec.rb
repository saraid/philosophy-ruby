RSpec.describe Philosophy::Game::Rules do
  let(:game) { Philosophy::Game.new(rules: rules) }
  let(:rules) { { join: join_rule, leave: leave_rule } }
  let(:join_rule) { Philosophy::Game::Rules::JoinRule.default }
  let(:leave_rule) { Philosophy::Game::Rules::LeaveRule.default }

  describe Philosophy::Game::Rules::JoinRule do
    let(:join_rule) { { permitted: permitted_option, where: where_option } }
    let(:permitted_option) { :only_before_any_placement }
    let(:where_option) { :immediately_next }

    context 'only_before_any_placement' do
      it 'should allow player adds at start' do
        expect do
          game << 'In+'
          game << 'Sa+'
          game << 'Am+'
          game << 'Te+'
        end.not_to raise_error
        expect(game.player_order).to eq %i[ In Sa Am Te ]
      end

      it 'should not allow player adds after start' do
        game << 'In+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect { game << 'Sa+' }.to raise_error(Philosophy::Game::DisallowedByRule)
        expect(game.player_order).to eq %i[ Te In ]
      end
    end

    context 'between_turns' do
      let(:permitted_option) { :between_turns }

      it 'should allow player adds after start' do
        game << 'In+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect { game << 'Sa+' }.not_to raise_error
        expect(game.player_order).to eq %i[ Sa Te In ]
      end

      it 'should does not interrupt an incomplete placement' do
        game << 'In+'
        game << 'Te+'
        game << 'In:C2ReSw'
        game << 'Te:C8PuSo'
        game << 'In:C6DeSw[C4'
        game << 'Sa+'
        expect(game.player_order).to eq %i[ In Sa Te ]
        expect(game.current_player.color.code).to eq :In
        expect(game.player_options).not_to be_empty
      end
    end

    context 'immediately_next' do
      let(:permitted_option) { :between_turns }
      let(:effect_option) { :immediately_next }

      it 'should maintain the player order *before* game start' do
        game << 'In+'
        game << 'Te+'
        expect(game.current_player.color.code).to eq :In
        expect(game.player_order).to eq %i[ In Te ]
      end

      it 'should set the current player to the player who just joined' do
        game << 'In+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect { game << 'Sa+' }.not_to raise_error
        expect(game.current_player.color.code).to eq :Sa
        expect(game.player_order).to eq %i[ Sa Te In ]
      end
    end

    context 'after_a_full_turn' do
      let(:permitted_option) { :between_turns }
      let(:where_option) { :after_a_full_turn }

      it 'should set the current player to the player who just joined' do
        game << 'In+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect { game << 'Sa+' }.not_to raise_error
        expect(game.player_order).to eq %i[ Te In Sa ]
      end
    end
  end

  describe Philosophy::Game::Rules::LeaveRule do
    let(:leave_rule) { { permitted: permitted_option, effect: effect_option } }
    let(:permitted_option) { :anytime }
    let(:effect_option) { :ends_game }

    context 'never' do
      let(:permitted_option) { :never }

      it 'should disallow leaving entirely' do
        game << 'In+'
        game << 'Sa+'
        game << 'Am+'
        game << 'Te+'
        expect { game << 'In-' }.to raise_error(Philosophy::Game::DisallowedByRule)
      end
    end

    context 'only_before_any_placement' do
      let(:permitted_option) { :only_before_any_placement }

      it 'should allow leaving before game started' do
        game << 'In+'
        game << 'Sa+'
        game << 'Am+'
        game << 'Te+'
        expect(game).not_to be_started
        expect { game << 'In-' }.not_to raise_error
        expect(game.player_order).to eq %i[ Sa Am Te ]
        expect(game.current_player.color.code).to eq :Sa
      end

      it 'should disallow leaving after game started' do
        game << 'In+'
        game << 'Sa+'
        game << 'Am+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect { game << 'In-' }.to raise_error(Philosophy::Game::DisallowedByRule)
      end
    end

    context 'anytime' do
      let(:permitted_option) { :anytime }

      # not sure there's a point to testing this.
    end

    context 'ends_game' do
      let(:effect_option) { :ends_game }

      it 'should disallow leaving after game started' do
        game << 'In+'
        game << 'Sa+'
        game << 'Am+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect(game).not_to be_concluded
        game << 'In-'
        expect(game).to be_concluded
      end
    end

    context 'rollback_placement' do
      let(:effect_option) { :rollback_placement }

      it 'should do nothing if the last placement is complete' do
        game << 'In+'
        game << 'Te+'
        game << 'Sa+'
        game << 'In:C2ReSw'
        game << 'Te:C8PuSo'
        game << 'Sa:C5PuEa'
        game << 'In:C6DeSw[C4So]'
        game << 'In-'
        expect(game.board_state).to eq 'C2:InReSw/C5:SaPuEa/C8:TePuSo'
        expect(game.current_player.color.code).to eq :Te
        game << 'Te:C3SrNo'
        expect(game.board_state).to eq 'C2:InReSw/C3:TeSrNo/C5:SaPuEa/C8:TePuSo'
      end

      it 'should do nothing if the last choice completed a placement' do
        game << 'In+'
        game << 'Te+'
        game << 'Sa+'
        game << 'In:C2ReSw'
        game << 'Te:C8PuSo'
        game << 'Sa:C5PuEa'
        game << 'In:C6DeSw[C4'
        game << 'So'
        game << 'In-'
        expect(game.board_state).to eq 'C2:InReSw/C5:SaPuEa/C8:TePuSo'
        expect(game.current_player.color.code).to eq :Te
        game << 'Te:C3SrNo'
        expect(game.board_state).to eq 'C2:InReSw/C3:TeSrNo/C5:SaPuEa/C8:TePuSo'
      end

      it 'should rollback if the placement is in progress' do
        game << 'In+'
        game << 'Te+'
        game << 'Sa+'
        game << 'In:C2ReSw'
        game << 'Te:C8PuSo'
        game << 'Sa:C5PuEa'
        game << 'In:C6DeSw[C4'
        game << 'In-'
        expect(game.board_state).to eq 'C2:InReSw/C5:SaPuEa/C8:TePuSo'
        expect(game.current_player.color.code).to eq :Te
        game << 'Te:C3SrNo'
        expect(game.board_state).to eq 'C2:InReSw/C3:TeSrNo/C5:SaPuEa/C8:TePuSo'
      end

      it 'should rollback if the last choice did not complete a placement' do
        game << 'In+'
        game << 'Te+'
        game << 'Sa+'
        game << 'In:C2ReSw'
        game << 'Te:C8PuSo'
        game << 'Sa:C5PuEa'
        game << 'In:C6DeSw'
        game << 'C4'
        game << 'In-'
        expect(game.board_state).to eq 'C2:InReSw/C5:SaPuEa/C8:TePuSo'
        expect(game.current_player.color.code).to eq :Te
        game << 'Te:C3SrNo'
        expect(game.board_state).to eq 'C2:InReSw/C3:TeSrNo/C5:SaPuEa/C8:TePuSo'
      end
    end

    context 'remove_their_tiles' do
      let(:effect_option) { :remove_their_tiles }

      it 'removes their tiles' do
        game << 'In+'
        game << 'Am+'
        game << 'In:C5PuNo'
        game << 'Am:C4PuNo'
        game << 'In:C6LsNo'
        game << 'In-'
        expect(game.board_state).to eq 'C4:AmPuNo'
      end
    end
  end
end
