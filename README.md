# Vim Robots

## Introduction
This is a Vim plugin implementation of the game Robots. Check out this [Wikipedia article](https://en.wikipedia.org/wiki/Chase_(video_game)) to learn its history.

There is one key difference between the classic game and this modern Vim update. The original version is based on a Cartesian grid, with movement in the usual 8 directions,...

![Robots on Cartesian grid](https://upload.wikimedia.org/wikipedia/commons/b/bf/Robots_text_screenshot.png)
<br/>**Figure 1:** *Robots on Cartesian grid*

but this reincarnation is based on a hexagonal grid, with movement in only 6 directions. *Disclaimer: the hexagonal tiling and letters (<kbd>y</kbd>, <kbd>k</kbd>, <kbd>u</kbd>, <kbd>n</kbd>, <kbd>j</kbd>, and <kbd>b</kbd>) in the image below are for illustrative purposes only, and are not generated during gameplay.*

![Robots on a hexagonal grid](HexRobots.png)
<br/>**Figure 2:** *Vim-Robots on a hexagonal grid*

## Installation

Use your favorite plugin manager. If you don't have one, try one of these: [vim-pathogen](https://github.com/tpope/vim-pathogen), [vim-plug](https://github.com/junegunn/vim-plug), [Packer.nvim](https://github.com/wbthomason/packer.nvim) or [lazy.nvim](https://github.com/folke/lazy.nvim). Alternatively, you can use packages and submodules, as Greg Hurrell ([@wincent](https://github.com/wincent)) describes in his excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Playing the game

Start a game with the `:Robots` command.

You are the green solid circle. Robots are purple squares, and the junk piles are orange triangles. *Your colors may vary, depending on your Vim colorscheme and/or terminal color settings.*

The robots are programmed to pursue you at all costs, and will choose the shortest path to do so. They move in a straight line diagonally or vertically, but horizontal movement requires them to zig-zag randomly toward you. Fortunately, the robots are oblivious to each other, and will collide, leaving a flaming pile of junk. To survive to the next level, you must lure all the robots to walk into a junk pile or another robot, while avoiding being captured.

In later levels, you can take advantage of portals to travel instantly from one edge of the field to the opposite side. Eventually, the robots will catch on, and track you down through those portals too, so be careful.

### Movement Keys

Main Keyboard | Number Keypad | Direction
:-:|:-:|---
<kbd>y</kbd> | <kbd>7</kbd> | Up left
<kbd>k</kbd> | <kbd>8</kbd> | Up
<kbd>u</kbd> | <kbd>9</kbd> | Up right
<kbd>b</kbd> | <kbd>1</kbd> | Down left
<kbd>j</kbd> | <kbd>2</kbd> | Down
<kbd>n</kbd> | <kbd>3</kbd> | Down right

### Other Commands

Key | | Function
:-:|---|---
<kbd>t</kbd>   | Transport | If you become trapped, you can transport to another location.
<kbd>d</kbd>   | Decoy     | Place a decoy down at your current location.
<kbd>w</kbd>   | Wait      | Sometimes the only winning move is not to play, but to wait and let the robots advance one step.
<kbd>F</kbd>   | Finish    | Finishing the level means waiting in place until defeat or triumph. Earn double the points and recharge your shield.
<kbd>?</kbd>   | Help      | Toggles the statusline to show the symbol legend and key mappings. The next move resets the statusline.
<kbd>Esc</kbd> | Boss Key  | What? You've never heard of this?

### Transporter and Shield
Your transporter and shield are closely linked. The transporter is used to whisk you away from imminent capture, but using it comes at a cost. Each transport reduces the shield's strength by 100%. If the shield is below 100%, you **could** transport onto a robot or junk pile, and be captured immediately. Using the <kbd>F</kbd> key to finish a level will recharge your shield at the rate of 20% for each defeated robot. There is no maximum shield strength.

### Decoy
Once per level, you can deploy a decoy with the <kbd>d</kbd> key, which can help you escape encroaching robots. They will move toward the decoy, allowing you to briefly move without being followed. The duration of the decoy is a function of your shield strength, and doesn't drain your shield. It is always better to use the decoy as a first option.

## Customization
The symbols representing various items can be changed to your liking. The statements below recreate the retro look, and the default values are shown in the comments.

```vim
let g:robots_empty = "\u00a0"    " Default: ·  An unoccupied cell on the board
let g:robots_robot = '+'         " Default: ■  A robot bent on capturing you
let g:robots_junk_pile = '*'     " Default: ▲  A junk pile
let g:robots_player = '@'        " Default: ●  You
" The following settings have no counterpart in the original game.
let g:robots_safe_portals  = 'o' " Default: ⬡ A portal only you can use
let g:robots_risky_portals = '#' " Default: ⬢ A portal you and robots can use
```

When transporting, a meandering path is drawn from the starting location to the final destination. It's just a bit of hi-res eye candy, and it can be slow on some computers. To turn it off, use this statement:

```vim
let g:robots_animation = 0
```
