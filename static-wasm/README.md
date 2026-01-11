Purpose of this folder is basically playing with WASM and seeing whether or not I could create a usable browser UX for Philosophy off the gem I'd already built.

- [ ] There should probably be tests or something?
- [x] The static-wasm code is _incredibly_ bad, but it works. Refactor into sanity someday.
- [ ] Several console components should be refactored into their own file.
- [ ] Allow rule changes.
- [ ] Respect token?
- [ ] Cannot leave after game ends.
- [ ] Import PGN.

# Start

Run from toplevel; it will use port 8000:

```
static-wasm/self-host
```

# Demo

It is deployed to https://saraid.github.io/philosophy-ruby/static-wasm/
