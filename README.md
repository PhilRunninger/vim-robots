# Vim Robots

## Introduction
This is a Vim plugin implementation of the classic game Robots. Check out this [Wikipedia article](https://en.wikipedia.org/wiki/Chase_(video_game)) to learn its history.

There is one key difference between the classic game and this modern Vim update. The original version is based on a Cartesian grid, with movement in the usual 8 directions,...

![Robots on Cartesian grid](https://upload.wikimedia.org/wikipedia/commons/b/bf/Robots_text_screenshot.png)
<br/>**Figure 1:** *Robots on Cartesian grid*

but this reincarnation is based on a hexagonal grid, with movement in only 6 directions. *Note: the hexagons in the picture below are for illustration only, and obviously are not part of the game.*

![Robots on a hexagonal grid](https://github.com/PhilRunninger/vim-robots/raw/master/HexRobots.png)
<br/>**Figure 2:** *Robots on a hexagonal grid*

## Playing the game

Start a game with the `:Robots` command.

Your avatar is the circle. Robots are squares, and the junk piles are triangles. *Your colors may vary, depending on your Vim colorscheme and/or terminal color settings.* The robots are programmed to pursue you at all costs. They will choose the shortest path diagonally or vertically. Horizontal movement requires them to randomly choose a diagonally up or down direction. Fortunately, they are oblivious to each other, and will collide, leaving a flaming pile of junk. Your objective is to lure all the robots to walk into a junk heap or another robot, while avoiding capture, so you can advance to the next round. In later rounds, you can take advantage of portals to travel instantl from one edge of the field to the opposite side. Eventually, the robots will catch on, and follow you through those portals too, so be careful.

### Movement
Move your avatar around the screen with these keys.

Main Keyboard | Number Keypad | Direction
:-:|:-:|---
<kbd>y</kbd> | <kbd>7</kbd> | Up left
<kbd>k</kbd> | <kbd>8</kbd> | Up
<kbd>u</kbd> | <kbd>9</kbd> | Up right
<kbd>b</kbd> | <kbd>1</kbd> | Down left
<kbd>j</kbd> | <kbd>2</kbd> | Down
<kbd>n</kbd> | <kbd>3</kbd> | Down right

To get out of a bind or to earn a bonus, use these keys.

Key | Function
:-:|---
<kbd>t</kbd> | Transport to another location.
<kbd>w</kbd> | Wait for one move, and let the robots advance.
<kbd>F</kbd> | Finish the round, waiting until defeat or triumph.

### Safe Transports
A safe transport ensures you won't be killed when transporting. You start out with none, which means you **could** land on a robot or junk pile, and die immediately. You can earn safe transports though, by using the <kbd>F</kbd> key to finish a round. Any robots defeated while finishing a round count toward your safe transports. Defeating five robots in this manner earns you one safe transport.

## Customization
The characters used to represent various items can be changed to your liking. Just set one or more of these variables in your `.vimrc`:

Variable | Default | Example (for the retro look.)
---|:-:|---
`g:robots_empty`     | · | `let g:robots_empty = ' '`
`g:robots_robot`     | ■ | `let g:robots_robot = '+'`
`g:robots_junk_pile` | ▲ | `let g:robots_junk_pile = '*'`
`g:robots_player`    | ● | `let g:robots_player = '@'`
`g:robots_portal`    | ○ | No equivalent
