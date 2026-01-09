TESTS = {
  'pushNo' => %w[
    In+:indigo
    Te+:teal
    In:C4PuNo
    Te:C7PuNo
  ],
  'tossSo' => %w[
    In+:indigo
    Te+:teal
    In:C4PuNo
    Te:C1ToSo
  ],
  'tossNo' => %w[
    In+:indigo
    Te+:teal
    In:C4PuNo
    Te:C7ToNo
  ],
  'rephrase' => %w[
    In+:indigo
    Te+:teal
    In:C4PuNo
    Te:C2ReSw[Ea]
  ],
}

testDiv = JS.global[:document].querySelector('#tests')
if [JS::Null, JS::Undefined].include? testDiv
else
  TESTS.each do |name, moves|
    button = JS.global[:document].createElement("button")
    button[:innerHTML] = name
    button.addEventListener('click') do |event|
      @current_game = moves.each.with_object(Philosophy::Game.new) { _2 << _1 }
      render_game
    end
    testDiv.appendChild(button)
  end
end
