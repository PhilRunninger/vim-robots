execute 'syntax match RobotsRobot /'.g:robots_robot.'/'
execute 'syntax match RobotsPlayer /'.g:robots_player.'/'
execute 'syntax match RobotsJunkPile /'.g:robots_junk_pile.'/'
execute 'syntax match RobotsEmpty /'.g:robots_empty.'/'
execute 'syntax match RobotsPortals /'.g:robots_portal.'/'
syntax match RobotsTeleportTarget1 /✹/
syntax match RobotsTeleportTarget2 /✵/
syntax match RobotsTeleportTarget3 /✶/
syntax match RobotsPlayerDeath1 /×/
syntax match RobotsPlayerDeath2 /x/
syntax match RobotsPlayerDeath3 /X/
syntax match RobotsTitle /ROBOTS/
syntax match RobotsNumbers /\d\+/
syntax match RobotsSafeTransport /Safe Transports:\s*[1-9].*$/
syntax match RobotsRiskyTransport /Safe Transports:\s*0.*$/
execute 'syntax match RobotsGameOver /'.g:robots_game_over.'/'
execute 'syntax match RobotsPortals /'.g:robots_portal_intro.'/'
execute 'syntax match RobotsPortals /'.g:robots_portal_warning.'/'

highlight RobotsRobot        cterm=bold ctermfg=165 guifg=#df00ff
highlight RobotsPlayer       cterm=bold ctermfg=40  guifg=#00df00
highlight RobotsJunkPile     cterm=bold ctermfg=208 guifg=#ff8700
highlight RobotsPlayerDeath1 cterm=bold ctermfg=124 guifg=#af0000
highlight RobotsPlayerDeath2 cterm=bold ctermfg=160 guifg=#df0000
highlight RobotsPlayerDeath3 cterm=bold ctermfg=196 guifg=#ff0000
highlight RobotsGameOver     cterm=bold ctermfg=196 guifg=#ff0000

if &background == 'dark'
    highlight RobotsPortals         cterm=bold ctermfg=39  guifg=#00afff
    highlight RobotsEmpty           cterm=bold ctermfg=242 guifg=#666666
    highlight RobotsTeleportTarget1 cterm=bold ctermfg=220 guifg=#ffd700
    highlight RobotsTeleportTarget2 cterm=bold ctermfg=226 guifg=#ffff00
    highlight RobotsTeleportTarget3 cterm=bold ctermfg=228 guifg=#ffff87
    highlight RobotsSafeTransport   cterm=bold ctermfg=40  guifg=#00df00
    highlight RobotsRiskyTransport  cterm=bold ctermfg=160 guifg=#df0000
    highlight RobotsTitle           cterm=bold ctermfg=214 guifg=#ffaf00
    highlight RobotsNumbers         cterm=bold ctermfg=220 guifg=#ffdf00
else
    highlight RobotsPortals         cterm=bold ctermfg=127 guifg=#af00af
    highlight RobotsEmpty           cterm=bold ctermfg=250 guifg=#bcbcbc
    highlight RobotsTeleportTarget1 cterm=bold ctermfg=26  guifg=#005fd7
    highlight RobotsTeleportTarget2 cterm=bold ctermfg=32  guifg=#0087d7
    highlight RobotsTeleportTarget3 cterm=bold ctermfg=38  guifg=#00afdf
    highlight RobotsSafeTransport   cterm=bold ctermfg=34  guifg=#00af00
    highlight RobotsRiskyTransport  cterm=bold ctermfg=160 guifg=#df0000
    highlight RobotsTitle           cterm=bold ctermfg=172 guifg=#df8700
    highlight RobotsNumbers         cterm=bold ctermfg=172 guifg=#df8700
endif
