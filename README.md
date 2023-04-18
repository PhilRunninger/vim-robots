# Vim Robots

## Introduction
This is a Vim plugin implementation of the classic game Robots. Check out this [Wikipedia article](https://en.wikipedia.org/wiki/Chase_(video_game)) to learn its history.

There is one key difference between the classic game and this modern Vim update. The original version is based on a Cartesian grid, with movement in the usual 8 directions,...

![Robots on Cartesian grid](https://upload.wikimedia.org/wikipedia/commons/b/bf/Robots_text_screenshot.png)
<br/>**Figure 1:** *Robots on Cartesian grid*

but this reincarnation is based on a hexagonal grid, with movement in only 6 directions. *Note: the hexagonal tiling and letters <kbd>y</kbd>, <kbd>k</kbd>, <kbd>u</kbd>, <kbd>n</kbd>, <kbd>j</kbd>, and <kbd>b</kbd> in the image below are for instructional purposes only, and are not generated during gameplay.*

![Robots on a hexagonal grid](https://github.com/PhilRunninger/vim-robots/raw/master/HexRobots.png)
<br/>**Figure 2:** *Robots on a hexagonal grid*

## Installation

Use your favorite plugin manager to install this plugin. [vim-pathogen](https://github.com/tpope/vim-pathogen), [Vundle.vim](https://github.com/VundleVim/Vundle.vim), [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim), and [Packer.nvim](https://github.com/wbthomason/packer.nvim) are some of the more popular ones. A lengthy discussion of these and other managers can be found on [vi.stackexchange.com](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).

If you have no favorite, or want to manage your plugins without 3rd-party dependencies, I recommend using packages, as described in Greg Hurrell's excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Playing the game

Start a game with the `:Robots` command.

Your avatar is the circle. Robots are squares, and the junk piles are triangles. *Your colors may vary, depending on your Vim colorscheme and/or terminal color settings.*

The robots are programmed to pursue you at all costs. They will choose the shortest path diagonally or vertically. Horizontal movement requires them to randomly choose a diagonally up or down direction. Fortunately, they are oblivious to each other, and will collide, leaving a flaming pile of junk. Your objective is to lure all the robots to walk into a junk heap or another robot, while avoiding capture, so you can advance to the next round.

In later rounds, you can take advantage of portals to travel instantly from one edge of the field to the opposite side. Eventually, the robots will catch on, and track you down through those portals too, so be careful.

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
<kbd>F</kbd> | Finish the round, waiting until defeat or triumph. Earn double the points and credits toward Safe Transports.

### Safe Transports
A safe transport ensures you won't be killed when transporting. You start out with none, which means you **could** land on a robot or junk pile, and die immediately. You can earn safe transports though, by using the <kbd>F</kbd> key to finish a round. Any robots defeated while finishing a round count toward your safe transports. Defeating five robots in this manner earns you one safe transport.

## Customization
The characters used to represent various items can be changed to your liking. Robot poo is left by the robots when you finish the round by pressing <kbd>F</kbd>. When portals are drawn on the edge of the window, Unicode characters are used to approximate a connected edge between them. The statements shown here are what you'd use to get the retro look or to prevent using Unicode characters. The default values are in the comments following each statment.

```vim
let g:robots_empty = "\u00a0"            " Default: ·  An unoccupied cell on the board
let g:robots_robot = '+'                 " Default: ■  A bad guy
let g:robots_robot_poo = g:robots_empty  " Default: •  The trail taken by robots after pressing F
let g:robots_junk_pile = '*'             " Default: ▲  A junk pile
let g:robots_player = '@'                " Default: ●  The good guy
let`g:robots_portal = 'o'                " Default: ○  A portal you can use to escape danger
let g:robots_border = 0                  " Default: 1  Draw (or not) lines between portals
```
