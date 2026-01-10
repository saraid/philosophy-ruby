require 'js'

# Patch require_relative to load from remote
require 'js/require_remote'

module Kernel
  alias original_require_relative require_relative

  # The require_relative may be used in the embedded Gem.
  # First try to load from the built-in filesystem, and if that fails,
  # load from the URL.
  def require_relative(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    dir = File.dirname(caller_path)
    file = File.absolute_path(path, dir)

    original_require_relative(file)
  rescue LoadError
    JS::RequireRemote.instance.load(path)
  end
end

require_relative '../lib/philosophy'
require_relative '../lib/philosophy/shims/svg'
require_relative './src2/ux'

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
def current_game = Philosophy::Game.current
Philosophy::Game.set_current!

Ux.setup

Ux::Player.render_available
nil
