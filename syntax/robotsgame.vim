execute "syntax match RobotsRobot /".g:robots_robot."/"
execute "syntax match RobotsPlayer /".g:robots_player."/"
execute "syntax match RobotsJunkPile /".g:robots_junk_pile."/"
syntax match RobotsTeleportTarget /[✦★✶✷]/
syntax match RobotsPlayerDeath1 /x/
syntax match RobotsPlayerDeath2 /X/


highlight RobotsRobot cterm=bold ctermfg=165
highlight RobotsPlayer cterm=bold ctermfg=40
highlight RobotsJunkPile cterm=bold ctermfg=208
highlight RobotsTeleportTarget cterm=bold ctermfg=220
highlight RobotsPlayerDeath1 cterm=bold ctermfg=124
highlight RobotsPlayerDeath2 cterm=bold ctermfg=160
