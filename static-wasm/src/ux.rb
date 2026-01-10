require_relative 'ux/board'
require_relative 'ux/console'
require_relative 'ux/move'
require_relative 'ux/player'

module Ux
  def self.build_element(element: :div, id: nil, classes: [], innerHTML: '', **kwargs)
    elem = document.createElement(element.to_s)
    elem[:id] = id.to_s if id
    classes.each { elem[:classList].add _1 }
    kwargs.each do |property, value|
      case value
      when Symbol, String
        elem[property] = value.to_s
      else
        puts "element creation: unhandled property #{property}=#{value.inspect}"
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

  def self.debounce(id: caller.first, timeout: 0.3, &)
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

  def self.render
    Board.render
    Console.render
    nil
  end

  def self.setup
    Board.setup
    Console.setup
    body[:childNodes].forEach { body.removeChild _1 }
    body.appendChild main
  end
end
