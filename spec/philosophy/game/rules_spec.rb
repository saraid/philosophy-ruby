RSpec.describe Philosophy::Game::Rules do
  let(:game) { Philosophy::Game.new(rules: rules) }
  let(:rules) { Philosophy::Game::Rules.new(join: join_rule, leave: leave_rule) }
  let(:join_rule) { Philosophy::Game::Rules::JoinRule.default }
  let(:leave_rule) { Philosophy::Game::Rules::LeaveRule.default }

  describe Philosophy::Game::Rules::JoinRule do
    let(:join_rule) { Philosophy::Game::Rules::JoinRule.new(when_option: when_option, where: where_option) }
    let(:when_option) { :before_any_placement }
    let(:where_option) { :immediately_next }

    context 'before_any_placement' do
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

    context 'after_placement' do
      let(:when_option) { :after_placement }
      it 'should allow player adds after start' do
        game << 'In+'
        game << 'Te+'
        game << 'In:C5PuNo'
        expect { game << 'Sa+' }.not_to raise_error
        expect(game.player_order).to eq %i[ Sa Te In ]
      end
    end

    context 'immediately_next' do
      let(:when_option) { :after_placement }
      let(:what_option) { :immediately_next }

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
      let(:when_option) { :after_placement }
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
    let(:leave_rule) { Philosophy::Game::Rules::LeaveRule.new(when_option: when_option, what: what_option) }
    let(:when_option) { :anytime }
    let(:what_option) { :ends_game }

    context 'never' do
      let(:when_option) { :never }

      it 'should disallow leaving entirely' do
        game << 'In+'
        game << 'Sa+'
        game << 'Am+'
        game << 'Te+'
        expect { game << 'In-' }.to raise_error(Philosophy::Game::DisallowedByRule)
      end
    end

    context 'before_any_placement' do
      let(:when_option) { :before_any_placement }

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
      let(:when_option) { :anytime }
    end

    context 'ends_game' do
      let(:what_option) { :ends_game }

      it 'should disallow leaving after game started' do
        game << 'In+'
        game << 'Sa+'
        game << 'Am+'
        game << 'Te+'
        game << 'In:C5PuNo'
        game << 'In-'
      end
    end

    context 'rollback_placement' do
      let(:what_option) { :rollback_placement }
    end

    context 'remove_their_tiles' do
      let(:what_option) { :remove_their_tiles }

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
