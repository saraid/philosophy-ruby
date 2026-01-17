Purpose of this folder is basically playing with WASM and seeing whether or not I could create a usable browser UX for Philosophy off the gem I'd already built.

# Start

Run from toplevel; it will use port 8000:

```
static-wasm/self-host
```

# Demo

It is deployed to https://saraid.github.io/philosophy-ruby/static-wasm/

# TODO

- [ ] Changes to lib/ created in this branch need to be merged back into main at some point...
  - I need to make a decision about whether or not the static-wasm/ directory should go into main.
  - I think it should, but maybe it's too far from the core purpose of the gem.
  - On the other hand, building something like static-wasm/ _is_ the core purpose of the gem, so it's a good example.

Big Projects: Stuff that might require major changes to the base library, or otherwise just hard or require I learn stuff.
- [ ] Come up with a better way to display version.
  - [ ] Come up with a deploy pattern overall.
  - [ ] Package this properly as a WASI interface. Maybe learn WASM for realsies instead of just faking it.
- [ ] Support connecting to a multiplayer room via WebSocket.
  - [ ] Room should support unlimited number of chatters, and also let people claim player slots.
  - [ ] Probably disallow non-players from changing rules? This might be a whole-ass separate mode.
- [ ] There should probably be tests or something?
- [ ] Show consequences of a placement before commit. Also have a commit.
- [ ] Also have an undo?

Core Functionality: Stuff that is reaosnably expected to just be a basic feature.
- [x] The static-wasm code is _incredibly_ bad, but it works. Refactor into sanity someday.
  - [ ] Well, we've had one refactor, but what about second refactor? The organization is *much* better now, but I kinda want real classes instead of lots of namespaced subroutines.
- [x] Several console components should be refactored into their own file.
- [x] Allow rule changes.
- [ ] Respect token?
- [x] Cannot leave after game ends.
- [ ] Import PGN.
- [x] Also maybe a navigable history?
  - [x] The PGN should be a lot nicer. Ideally, it would have hovers showing exactly what each bit means.
- [x] It's not obvious enough when the game ends.
  - [ ] New Game button?

Nice to Have: Improvements worth having, but non-critical to being usable.
- [ ] Learn how to SVG better and make decent looking tiles and operation visuals.
- [ ] Display options / customization
  - [ ] Toggle space notations
  - [ ] Change space bgcolor.
  - [ ] Offer custom player colors.
- [x] Player and Direction should be reduced to unicode characters, and then make the tile name fit on the tile.
