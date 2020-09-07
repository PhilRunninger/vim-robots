execute 'syntax match RobotsRobot /'.g:robots_robot.'/'
execute 'syntax match RobotsPlayer /'.g:robots_player.'/'
execute 'syntax match RobotsJunkPile /'.g:robots_junk_pile.'/'
execute 'syntax match RobotsSafeTransport /'.g:robots_safe.'\+/'
execute 'syntax match RobotsRiskyTransport /'.g:robots_risky.'\+/'
syntax match RobotsTeleportTarget /[✦★✶✷]/
syntax match RobotsPlayerDeath1 /x/
syntax match RobotsPlayerDeath2 /X/
syntax match RobotsTitle /ROBOTS/
syntax match RobotsNumbers /\d\+/

highlight RobotsRobot cterm=bold ctermfg=165
highlight RobotsPlayer cterm=bold ctermfg=40
highlight RobotsJunkPile cterm=bold ctermfg=208
highlight RobotsTeleportTarget cterm=bold ctermfg=220
highlight RobotsPlayerDeath1 cterm=bold ctermfg=124
highlight RobotsPlayerDeath2 cterm=bold ctermfg=160
highlight RobotsSafeTransport cterm=bold ctermfg=40
highlight RobotsRiskyTransport cterm=bold ctermfg=196
highlight RobotsTitle cterm=bold ctermfg=214
highlight RobotsNumbers cterm=bold ctermfg=220
