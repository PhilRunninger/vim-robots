# Vim Robots

## Introduction
This is a Vim plugin implementation of the classic game. Check out the [Wikipedia article](https://en.wikipedia.org/wiki/Chase_(video_game)) about the game to learn its history.

There is one key difference between the classic game and this modern Vim update. The original version is based on a Cartesian grid, with movement in the usual 8 directions,...

![Cartesian Robots screenshot](https://upload.wikimedia.org/wikipedia/commons/b/bf/Robots_text_screenshot.png)

but this rendition is based on a hexagonal grid, with movement in only 6 directions. *The hexagons in the picture below are for illustration only, and not part of the game. Kudos to anyone who modifies their terminal background to be tiled hexagons.*

![Hex Robots screenshot](https://github.com/PhilRunninger/vim-robots/raw/master/HexRobots.png)

## Playing the game

Start a game with the `:Robots` command.

Move your player around the screen with these keys:

Main Keyboard | Number Keypad | Direction
---|---|---
`y` | `7` | Up left
`k` | `8` | Up
`u` | `9` | Up right
`b` | `1` | Down left
`j` | `2` | Down
`n` | `3` | Down right

Other keys that can be used:

Key | Function
---|---
`w` | Wait for one move, and let the robots advance
`t` | Transport to another location
`f` | Finish the round. Wait until defeat or triumph.

## Safe Transports
A safe transport ensures you won't be killed when transporting. You start out with none, which means you **could** land on a robot, and die immediately. You can earn safe transports though, by using the `f` key to finish a round. Any robots defeated while finishing a round count toward your safe transports. Defeating ten robots earns you one safe transport.
