execute "syntax match RobotsRobot /".g:robots_robot."/"
execute "syntax match RobotsPlayer /\\(^\\| \\)[1-5".g:robots_player."]\\( \\|$\\)/"
execute "syntax match RobotsJunkPile /".g:robots_junk_pile."/"
syntax match RobotsTeleportTarget /x/

highlight RobotsRobot cterm=bold ctermfg=1
highlight RobotsPlayer cterm=bold ctermfg=10
highlight RobotsJunkPile cterm=bold ctermfg=208
highlight RobotsTeleportTarget cterm=bold ctermfg=220
