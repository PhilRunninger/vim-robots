# Vim Robots

## Introduction
This is a Vim plugin implementation of the classic game. Check out the [Wikipedia article](https://en.wikipedia.org/wiki/Chase_(video_game)) about the game to learn its history.

There is one key difference between the classic game and this modern Vim update. The original version is based on a Cartesian grid, with movement in the usual 8 directions,...

![Cartesian Robots screenshot](https://upload.wikimedia.org/wikipedia/commons/b/bf/Robots_text_screenshot.png)

but this rendition is based on a hexagonal grid, with movement in only 6 directions. *The hexagons are overlayed for illustration only. Kudos to anyone who modifies their terminal background to be tiled hexagons.*

![Hex Robots screenshot](https://github.com/PhilRunninger/vim-robots/raw/master/HexRobots.png)

## Playing the game

Start a game with the `:Robots` command.

Move your player around the screen with these keys (the number keypad works best):

Key | Direction
---|---
7 | Up left
8 | Up
9 | Up right
1 | Down left
2 | Down
3 | Down right

Other keys that can be used:

Key | Function
---|---
5 | Rest for one move, and let the robots advance
Enter | Teleport to another location

## ToDo
Lots of stuff. This is still a work in progress.
- Bug fixes
- Key mapping to rest until a win or death
- Safe Teleports
- Non-keypad mappings (useful on laptop keyboards)
- Refactoring
