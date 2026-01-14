require 'js'
require 'philosophy'
require 'philosophy/shims/svg'
require_relative './src/ux'

class Numeric
  def seconds = self
  def milliseconds = self / 1000
  def as_milliseconds = self / 1000
end

class JS::Object
  def then(&) = yield(self)
  def tap(&)
    yield(self)
    self
  end
end

class Philosophy::Game
  def self.current = @current_game
  def self.set_current!(g = new) = @current_game = g
end

module Ux
  module State
    VALUES = %i[
      choose_tile_for_move
      choose_space_for_move
      choose_space_for_choice
      choose_direction_for_move
      choose_direction_for_choice
    ].each { |s| define_singleton_method(s) { s } }
    #.map { [_1, _1] }.to_h

    def self.current = @current
    def self.set_to(state)
      puts "Setting state to #{state}"
      @current = state
    end
    set_to choose_tile_for_move
  end
end

def document = JS.global[:document]
def navigator = JS.global[:navigator]
def clipboard = navigator[:clipboard]

def current_game = Philosophy::Game.current
Philosophy::Game.set_current!
current_game.rules.can_join.between_turns!
current_game.rules.can_leave.anytime!
current_game.rules.upon_leaving.rollback_placement!

Ux.setup
Ux::Console::PlayerAdd.render

nil
