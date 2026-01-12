Purpose of this folder is basically playing with WASM and seeing whether or not I could create a usable browser UX for Philosophy off the gem I'd already built.

- [ ] There should probably be tests or something?
- [x] The static-wasm code is _incredibly_ bad, but it works. Refactor into sanity someday.
  - [ ] Well, we've had one refactor, but what about second refactor? The organization is *much* better now, but I kinda want real classes instead of lots of namespaced subroutines.
- [ ] Several console components should be refactored into their own file.
- [ ] Allow rule changes.
- [ ] Respect token?
- [ ] Cannot leave after game ends.
- [ ] Import PGN.
- [ ] Show consequences of a placement before commit. Also have a commit.
- [ ] Also have an undo? Also maybe a navigable history?
- [ ] It's not obvious enough when the game ends.
  - [ ] New Game button?
- [ ] Display options / customization
  - [ ] Toggle space notations
  - [ ] Change space bgcolor.
  - [ ] Offer custom player colors.

# Start

Run from toplevel; it will use port 8000:

```
static-wasm/self-host
```

# Demo

It is deployed to https://saraid.github.io/philosophy-ruby/static-wasm/
