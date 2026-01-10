PLAYERS = {
  Am: {
    color: '#FFBF00',
    default_name: 'Ambrose Pierce',
  },
  In: {
    color: '#4B0082',
    default_name: 'Indiana Jones',
  },
  Sa: {
    color: '#B2AC88',
    default_name: 'Sarah Connor',
  },
  Te: {
    color: '#008080',
    default_name: 'Teotihual Batan',
  },
}

playerAdd = JS.global[:document].querySelector('#player-add')
if [JS::Null, JS::Undefined].include? playerAdd
else
  playerName = JS.global[:document].querySelector('#player-add input')
  PLAYERS.each_key do |color_code|
    button = JS.global[:document].createElement('button')
    button[:innerHTML] = color_code.to_s
    button[:value] = color_code.to_s
    button.addEventListener('click') do
      name =
        if playerName[:value].to_s != '' then playerName[:value]
        else PLAYERS[color_code][:default_name]
        end
      current_game << "#{color_code}+:#{name}"
      update_pgn
      render_player current_game.players.fetch(color_code)
      playerName[:value] = nil
      playerAdd.removeChild(button)
      update_playable
    end
    playerAdd.appendChild(button)
  end
end

def render_player(player)
  player_hand = JS.global[:document].querySelector("#player-hands #player-#{player.color.code}")

  if player_hand == JS::Null
    hands = JS.global[:document].querySelector("#player-hands")
    hand = document.createElement('div')
    hand[:id] = "player-#{player.color.code}"
    hand[:classList].add "player-hand"
    hand[:classList].add "bgcolor-#{player.color.code}"
    hand[:classList].add "cannot-play"
    hands.appendChild(hand)

    player_hand = hand
  end

  player_hand[:childNodes].forEach { |node| player_hand.removeChild(node) }

  player_name = document.createElement('span')
  player_name[:innerHTML] = player.color.name.to_s
  player_hand.appendChild(player_name)

  player.tiles.each do
    type = Philosophy::IdeaTile.registry[_1]
    tile = document.createElement('button')
    tile[:innerHTML] = type.notation.to_s
    tile[:title] = type.to_s
    tile.addEventListener('click') do
      set_current_move_player(player.color.code)
      set_current_move_tile(type.notation)
      player_hand[:classList].add 'cannot-play'
      player_hand.removeChild(tile)
      puts "Current Move: #{current_move.inspect}"
      add_listeners_to_playable_area!
    end
    player_hand.appendChild(tile)
  end
end

def render_all_players
  current_game.players.each_value.uniq { render_player _1 }
  update_playable
end

def update_playable
  if current_game.players.each_value.uniq.size >= 2
    document.querySelectorAll("#player-#{current_game.current_player.color.code}").forEach do |node|
      puts node[:id]
      puts "before: #{node[:classList]}"
      if node[:id] == "player-#{current_game.current_player.color.code}"
        node[:classList].remove 'cannot-play'
      else
        node[:classList].add 'cannot-play'
      end
      puts "after: #{node[:classList]}"
    end
  end
end
