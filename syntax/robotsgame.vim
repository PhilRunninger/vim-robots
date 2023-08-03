execute 'syntax match RobotsRobot /'.g:robots_robot.'/'
execute 'syntax match RobotsTrails /'.g:robots_trails.'/'
execute 'syntax match RobotsPlayer /'.g:robots_player.'/'
execute 'syntax match RobotsJunkPile /'.g:robots_junk_pile.'/'
execute 'syntax match RobotsEmpty /'.g:robots_empty.'/'
execute 'syntax match RobotsPortals1 /'.g:robots_portal.'/'
execute 'syntax match RobotsPortals2 /[│⎺⎽]/'
execute 'syntax match RobotsGameOver /'.g:robots_game_over.'/'
syntax match RobotsTeleportTarget1 /✹/
syntax match RobotsTeleportTarget2 /✵/
syntax match RobotsTeleportTarget3 /✶/
syntax match RobotsPlayerDeath1 /×/
syntax match RobotsPlayerDeath2 /x/
syntax match RobotsPlayerDeath3 /X/

highlight RobotsRobot           cterm=bold ctermfg=165 guifg=#d700ff
highlight RobotsTrails          cterm=bold ctermfg=165 guifg=#ff87ff
highlight RobotsPlayer          cterm=bold ctermfg=40  guifg=#00df00
highlight RobotsJunkPile        cterm=bold ctermfg=208 guifg=#ff8700
highlight RobotsPlayerDeath1    cterm=bold ctermfg=124 guifg=#af0000
highlight RobotsPlayerDeath2    cterm=bold ctermfg=160 guifg=#df0000
highlight RobotsPlayerDeath3    cterm=bold ctermfg=196 guifg=#ff0000
highlight RobotsGameOver        cterm=bold ctermfg=196 guifg=#ff0000
highlight RobotsPortals1        cterm=bold ctermfg=25  guifg=#0087ff
highlight RobotsPortals2        cterm=bold ctermfg=45  guifg=#00d7ff
highlight RobotsPortals3        cterm=bold ctermfg=39  guifg=#00afff
highlight RobotsTeleportTarget1 cterm=bold ctermfg=214 guifg=#ffaf00
highlight RobotsTeleportTarget2 cterm=bold ctermfg=209 guifg=#ff875f
highlight RobotsTeleportTarget3 cterm=bold ctermfg=221 guifg=#ffd75f
highlight RobotsSafeTransport   cterm=bold ctermfg=34  guifg=#00af00
highlight RobotsRiskyTransport  cterm=bold ctermfg=160 guifg=#df0000
highlight RobotsTitle           cterm=bold ctermfg=214 guifg=#ffaf00
highlight RobotsHighlight       cterm=bold ctermfg=172 guifg=#df8700

if &background == 'dark'
    highlight RobotsEmpty       cterm=bold ctermfg=242 guifg=#666666
else
    highlight RobotsEmpty       cterm=bold ctermfg=250 guifg=#bcbcbc
endif
