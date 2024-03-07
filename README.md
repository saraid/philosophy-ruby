# Philosophy

Philosophy is a board game, the details of which can be found here:
- [Board Game Geek](https://boardgamegeek.com/boardgame/263236/philosophy)
- [Official Rulebook](https://philrulebook.qualitybeast.com/)

Please buy their game; it's a very nice little abstract.

## Notation

I based my notation design off what I was able to find on the [Quality Beast Discord](https://discord.qualitybeast.com). Each region of the board is named after the cardinal directions, the center is `C`, and the diagonal directions have specific notation, with the numbers ascending as you move left-to-right, then top-to-bottom. The exception is the West region, which goes right-to-left.

(In the code itself, this is abstracted away into a coordinate system for the 9x9 grid, but those coordinates aren't exposed.)

Everything is notated as two-character letter codes, abbreviating their purpose.

Each space on the board has a two-character notation.

Player colors (extensible if you really want):
- Indigo (`In`)
- Teal (`Te`)
- Amber (`Am`)
- Sage (`Sa`)

Tiles:
- Push (`Pu`)
- Corner Push (`Cp`)
- Slide Left (`Sl`)
- Slide Right (`Sr`)
- Pull Left (`Pl`)
- Pull Right (`Pr`)
- Long Shot (`Ls`)
- Corner Long Shot (`Cl`)
- Decision (`De`)
- Rephrase (`Re`)
- Toss (`To`)
- Persuade (`Pe`)

Directions: `No`, `Ea`, `So`, `We`, `Nw`, `Ne`, `Se`, `Sw`.

### A Move
Here's an example move: `Te:C7ReNe[We]`

What it means:
- The Player **Teal**
- Placed on the space **C7** (the southwestern corner of the playable region).
- The type of the tile placed is a **Rephrase**.
- The direction it is _targeting_ is **Northeast**.
- The player chooses to set the targeted tile to face **West**.

If the parameter is a decision moving a tile off the board, then the parameter is `OO`. This should be the only circumstance where that is possible.

If a move is incomplete, we leave the right-bracket off, and instead list the options in parentheses:
- E.g., `Am:C2ReNw[(EaNoSoWe)` when a Rephrase tile is pointing at a Push tile, but has not decided where the tile should be oriented.
- E.g., `Sa:C9PuNo[E1(C5NE)`

If a move concludes the game, then we notate that with a trailing `.`.

### Player Change
When a player joins or leaves, we can notate that with `In+` or `In-`.

We can optionally specify the full name of the color with `In+:indigo`.

### The Board
The board is notated as a description of every occupied space, ordered from C, NW, N, NE, E, SE, S, SW, W, delimited by `/`.

For example, in `C3:SaSlNo/C5:InSrNo/E1:InDeNw`, there are 3 occupied spaces: C3, C5, and E1.

### The Respect Token
Notated simply with `R:In` to pass it to the Indigo player.
