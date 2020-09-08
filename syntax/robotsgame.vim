execute 'syntax match RobotsRobot /'.g:robots_robot.'/'
execute 'syntax match RobotsPlayer /'.g:robots_player.'/'
execute 'syntax match RobotsJunkPile /'.g:robots_junk_pile.'/'
execute 'syntax match RobotsSafeTransport /'.g:robots_safe.'\+/'
execute 'syntax match RobotsRiskyTransport /'.g:robots_risky.'\+/'
syntax match RobotsTeleportTarget1 /✦/
syntax match RobotsTeleportTarget2 /★/
syntax match RobotsTeleportTarget3 /✶/
syntax match RobotsPlayerDeath1 /×/
syntax match RobotsPlayerDeath2 /x/
syntax match RobotsPlayerDeath3 /X/
syntax match RobotsTitle /ROBOTS/
syntax match RobotsNumbers /\d\+/
syntax match RobotsGameOver /You've been.*/

highlight RobotsRobot cterm=bold ctermfg=165
highlight RobotsPlayer cterm=bold ctermfg=40
highlight RobotsJunkPile cterm=bold ctermfg=208
highlight RobotsTeleportTarget1 cterm=bold ctermfg=220
highlight RobotsTeleportTarget2 cterm=bold ctermfg=228
highlight RobotsTeleportTarget3 cterm=bold ctermfg=231
highlight RobotsPlayerDeath1 cterm=bold ctermfg=124
highlight RobotsPlayerDeath2 cterm=bold ctermfg=160
highlight RobotsPlayerDeath3 cterm=bold ctermfg=196
highlight RobotsSafeTransport cterm=bold ctermfg=40
highlight RobotsRiskyTransport cterm=bold ctermfg=196
highlight RobotsTitle cterm=bold ctermfg=214
highlight RobotsNumbers cterm=bold ctermfg=220
highlight RobotsGameOver cterm=bold ctermfg=196
