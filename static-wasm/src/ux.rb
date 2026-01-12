puts "loaded #{__FILE__}"
require_relative 'ux/board'
require_relative 'ux/console'
require_relative 'ux/move'
require_relative 'ux/player'

module Ux
  def self.build_text(text) = document.createTextNode(text)
  def self.build_element(element: :div, id: nil, classes: [], innerHTML: '', **kwargs)
    elem = document.createElement(element.to_s)
    elem[:id] = id.to_s if id
    classes.each { elem[:classList].add _1 }
    kwargs.each do |property, value|
      case value
      when Symbol, String, TrueClass, FalseClass
        elem[property] = value.to_s
      else
        puts "element creation: unhandled property #{property}=#{value.inspect} (#{value.class})"
      end
    end
    elem[:innerHTML] = innerHTML.to_s
    elem
  end

  def self.body = document.querySelector('body')
  def self.main
    return @main if @main
    @main = document.querySelector('main')
    if @main == JS::Null
      @main = build_element element: :main
    end
    @main
  end

  def self.debounce(id: caller.first, timeout: 300.milliseconds, &)
    @debouncers ||= {}
    if @debouncers[id]
      if Time.now - @debouncers[id] > timeout
        @debouncers.delete(id)
        yield
      end
    else
      @debouncers[id] = Time.now
      yield
    end
    nil
  end

  def self.wait_then(timeout: 3000.milliseconds, &block)
    JS.global.setTimeout(block, timeout)
  end

  def self.can_add_new_players?
    current_game.then do |g|
      next false if g.concluded?
      case g.rules.can_join
      when -> { _1.only_before_any_placement? } then !g.started?
      when -> { _1.between_turns? } then true
      end && g.player_order.size < Ux::Player::DEFAULTS.size
    end
  end

  def self.build_header
    header = Ux.build_element element: :Header, id: :header
    Ux.build_element(element: :div, innerHTML: <<~HTML).then { header.appendChild _1 }
      <a href="https://github.com/saraid/philosophy-ruby">GitHub</a>
    HTML
    Ux.build_element(element: :div, innerHTML: <<~HTML).then { header.appendChild _1 }
      <a href="https://boardgamegeek.com/boardgame/263236/philosophy">BoardGameGeek</a>
    HTML
    Ux.build_text('782e0394c9a261b6c2bab566f07f26daa7f79e83').then { header.appendChild _1 }
    body.appendChild header
  end

  def self.render
    Console::PlayerAdd.disable unless can_add_new_players?

    Board.render
    Console.render
    nil
  end

  def self.setup
    build_header
    Board.setup
    Console.setup
    body[:childNodes].forEach { body.removeChild _1 }
    body.appendChild main
  end
end
