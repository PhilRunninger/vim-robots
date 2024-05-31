execute printf('syntax match RobotsRobot /%s/',         g:robots_robot)
execute printf('syntax match RobotsPlayer /%s/',        g:robots_player)
execute printf('syntax match RobotsPlayerCapture /%s/', g:robots_capture)
execute printf('syntax match RobotsJunkPile /%s/',      g:robots_junk_pile)
execute printf('syntax match RobotsEmpty /%s/',         g:robots_empty)
execute printf('syntax match RobotsSafePortals /%s/',   g:robots_safe_portals)
execute printf('syntax match RobotsRiskyPortals /%s/',  g:robots_risky_portals)
execute printf('syntax match RobotsGameOver /\(GAME OVER\|Play Again?\)/')

let s:color_count = 40
for i in range(strchars(g:robots_sparkles))
    execute printf('syntax match RobotsTeleport%d /%s/', i%s:color_count, strcharpart(g:robots_sparkles, i, 1))
endfor
for i in range(s:color_count)
    let g = 96 + Random(160)
    let r = Random(g)
    let b = Random(g)
    execute printf('highlight RobotsTeleport%d cterm=bold ctermfg=%d gui=bold guifg=#%02x%02x%02x', i, [40,76,118][Random(3)], r, g, b)
endfor

highlight RobotsRobot           cterm=bold ctermfg=165 gui=bold guifg=#d700ff
highlight RobotsPlayer          cterm=bold ctermfg=40  gui=bold guifg=#00df00
highlight RobotsJunkPile        cterm=bold ctermfg=208 gui=bold guifg=#ff8700
highlight RobotsPlayerCapture   cterm=bold ctermfg=196 gui=bold guifg=#ff0000
highlight RobotsGameOver        cterm=bold ctermfg=196 gui=bold guifg=#ff0000
highlight RobotsSafePortals                ctermfg=25           guifg=#005fff
highlight RobotsSafePortalsMsg             ctermfg=25           guifg=#0087ff
highlight RobotsRiskyPortals               ctermfg=196          guifg=#af0000
highlight RobotsRiskyPortalsMsg            ctermfg=196          guifg=#ff0000
highlight RobotsSafeTransport   cterm=bold ctermfg=34  gui=bold guifg=#00af00
highlight RobotsRiskyTransport  cterm=bold ctermfg=160 gui=bold guifg=#df0000
highlight RobotsHighlight       cterm=bold ctermfg=172 gui=bold guifg=#df8700
highlight RobotsEmpty                      ctermfg=243          guifg=#949494
