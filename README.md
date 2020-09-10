# Vim Robots

## Introduction
This is a Vim plugin implementation of the classic game. Check out the [Wikipedia article](https://en.wikipedia.org/wiki/Chase_(video_game)) about the game to learn its history.

There is one key difference between the classic game and this modern Vim update. The original version is based on a Cartesian grid, with movement in the usual 8 directions,...

![Robots on Cartesian grid](https://upload.wikimedia.org/wikipedia/commons/b/bf/Robots_text_screenshot.png)
<br/>**Figure 1:** *Robots on Cartesian grid*

but this reincarnation is based on a hexagonal grid, with movement in only 6 directions. *Note: the hexagons in the picture below are for illustration only, and obviously are not part of the game.*

![Robots on a hexagonal grid](https://github.com/PhilRunninger/vim-robots/raw/master/HexRobots.png)
<br/>**Figure 2:** *Robots on a hexagonal grid*

## Playing the game

Start a game with the `:Robots` command.

Your avatar is the circle. Robots are squares, and the junk piles are triangles. *Your colors will vary, depending on your Vim colorscheme and/or terminal color settings.* Your objective is to get all the robots to walk into a junk pile or another robot, while avoiding capture, so you can advance to the next round.

### Movement
Move your avatar around the screen with these keys.

Main Keyboard | Number Keypad | Direction
---|---|---
`y` | `7` | Up left
`k` | `8` | Up
`u` | `9` | Up right
`b` | `1` | Down left
`j` | `2` | Down
`n` | `3` | Down right

To get out of a bind or to earn a bonus, use these keys.

Key | Function
---|---
`t` | Transport to another location.
`w` | Wait for one move, and let the robots advance.
`F` | Finish the round, waiting until defeat or triumph.

### Safe Transports
A safe transport ensures you won't be killed when transporting. You start out with none, which means you **could** land on a robot, and die immediately. You can earn safe transports though, by using the `F` key to finish a round. Any robots defeated while finishing a round count toward your safe transports. Defeating five robots earns you one safe transport.
