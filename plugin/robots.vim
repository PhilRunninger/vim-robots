" vim: foldmethod=marker

command! Robots :call <SID>InitAndStartRobots()   "{{{1

function! s:InitAndStartRobots()   "{{{1
    let g:robots_empty     = get(g:, 'robots_empty',     '·')
    let g:robots_robot     = get(g:, 'robots_robot',     '■')
    let g:robots_junk_pile = get(g:, 'robots_junk_pile', '▲')
    let g:robots_player    = get(g:, 'robots_player',    '●')
    let g:robots_portal    = get(g:, 'robots_portal',    '⊙')
    let g:robots_animation = get(g:, 'robots_animation', 1)

    tabnew
    let s:levelPortalsOn = 6
    let s:levelPortalsAllowRobots = 11
    let s:shieldFull = 5
    let s:width = getwininfo(win_getid())[0]['width']
    let s:height = getwininfo(win_getid())[0]['height']
    let s:cols = 2*float2nr((s:width+2)/6)
    let s:rows = 2*float2nr(s:height/2)
    let s:TOP = 1
    let s:RIGHT = 2
    let s:BOTTOM = 4
    let s:LEFT = 8

    setlocal filetype=robotsgame buftype=nofile bufhidden=wipe
    setlocal nonumber norelativenumber signcolumn=no nolist nocursorline nocursorcolumn
    let s:hlsearch = &hlsearch  " Remember the setting so it can be restored.
    set nohlsearch              " 'hlsearch' is a global setting
    call s:SetStatusline(v:true)

    for [keys, deltaRow, deltaCol] in [ [['1','b'],1,-1], [['2','j'],2,0], [['3','n'],1,1], [['7','y'],-1,-1], [['8','k'],-2,0], [['9','u'],-1,1] ]
        for key in keys
            call execute('nnoremap <buffer> <nowait> <silent> '.key.' :call <SID>MovePlayer('.deltaRow.','.deltaCol.')<CR>')
        endfor
    endfor
    nnoremap <buffer> <silent> 4 <nop>
    nnoremap <buffer> <silent> 5 <nop>
    nnoremap <buffer> <silent> 6 <nop>
    nnoremap <buffer> <silent> w :call <SID>WaitOneTurn()<CR>
    nnoremap <buffer> <silent> t :call <SID>Transport()<CR>
    nnoremap <buffer> <silent> F :call <SID>FinishLevel()<CR>
    nnoremap <buffer> <silent> ? :call <SID>SetStatusline(v:true)<CR>
    nnoremap <buffer> <silent> <Esc> :tabprevious<CR>

    call s:StartNewGame()
endfunction

function! s:SetStatusline(showKeys = v:false) " or refresh it on demand  {{{1
    let s:showKeys = a:showKeys
    setlocal statusline=%{%RobotsStatusline()%}
endfunction

function! RobotsStatusline()   "{{{1
    if s:showKeys
        let s:showKeys = v:false
        return printf('%%=%%#RobotsPlayer#%s%%#Normal#:you ' .
                    \ '%%#RobotsRobot#%s%%#Normal#:robot ' .
                    \ '%%#RobotsJunkPile#%s%%#Normal#:junk pile '.
                    \ '%%#RobotsPortals1#%s%%#Normal#:portal  ' .
                    \ '%%#RobotsHighlight#yujkbn%%#Normal#:Move ' .
                    \ '%%#RobotsHighlight#w%%#Normal#:Wait ' .
                    \ '%%#RobotsHighlight#t%%#Normal#:Transport ' .
                    \ '%%#RobotsHighlight#F%%#Normal#:Finish%%=',
                    \ g:robots_player,
                    \ g:robots_robot,
                    \ g:robots_junk_pile,
                    \ g:robots_portal)
    endif
    return printf('%%=%%#Normal#Score:%%#RobotsHighlight#%d ' .
                \ '%%#Normal#Robots:%%#RobotsHighlight#%d%%#Normal#/%%#RobotsHighlight#%d ' .
                \ '%%#Normal#Shield:%s%d%%%% ' .
                \ '%%#Normal#Level:%%#RobotsHighlight#%d  ' .
                \ '%s%s' .
                \ '%%=%%#RobotsHighlight#?%%#Normal#:Help',
                \ s:score,
                \ len(s:robotsPos), s:RobotCount(),
                \ (s:shield<s:shieldFull?'%#RobotsRiskyTransport#':'%#RobotsSafeTransport#'),
                \ 100*s:shield/s:shieldFull, s:level,
                \ s:level < s:levelPortalsAllowRobots ? '%#RobotsPortals2#' : '%#RobotsPortals3#',
                \ s:level < s:levelPortalsOn ? '' :
                    \ s:level < s:levelPortalsAllowRobots ? 'Portals are active.' : 'Watch out! Robots can use portals now.')
endfunction

function! s:StartNewGame()   "{{{1
    let s:score = 0
    let s:level = 0
    let s:shield = 0
    call s:StartNewLevel()
    call s:SetStatusline(v:true)
endfunction

function! s:StartNewLevel()   "{{{1
    let s:level += 1

    let s:activePortals = s:level == s:levelPortalsOn ? 15 : Random(16)  " 4-bit number, one per direction.

    let s:finishingLevel = v:false
    let l:startPt = exists('s:playerPos') ? s:ToScreenPosition(s:playerPos) : [s:height/2, s:width/2]

    call s:CreateRobotsAndPlayer()
    call s:DrawGrid()
    call s:Bezier(l:startPt, s:ToScreenPosition(s:playerPos))
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), 1, g:robots_player, 2, 1)
    call s:DrawAll(s:robotsPos, g:robots_robot, 10)
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)
endfunction

function! s:RobotCount()   "{{{1
    let l:cells = (s:rows * s:cols / 2)  " # of cells on the board
    return float2nr(l:cells / 2 * tanh((s:level) / pow(l:cells, 2.0/3.0)))
endfunction

function! s:CreateRobotsAndPlayer()   "{{{1
    let s:junkPilesPos = []
    let s:robotsPos = []
    for i in range(1,s:RobotCount())
        call add(s:robotsPos, s:RandomPosition())
        while count(s:robotsPos, s:robotsPos[-1]) == 2
            let s:robotsPos[-1] = s:RandomPosition()
        endwhile
    endfor

    let s:playerPos = s:RandomPosition()
    while count(s:robotsPos, s:playerPos) == 1
        let s:playerPos = s:RandomPosition()
    endwhile
endfunction

function! s:DrawGrid()   "{{{1
    setlocal modifiable
    normal! ggdG
    for r in range(1,s:rows,1)
        call append(0, (r%2 ? '':'   ').trim(repeat(g:robots_empty.'     ',s:cols/2), ' ').(r%2 ? '   ':''))
    endfor

    execute 'g/^$/d'
    if s:PortalsAreOpen(s:TOP)    | execute 'silent 1,2s/' .g:robots_empty.'/'.g:robots_portal.'/ge'   | endif
    if s:PortalsAreOpen(s:BOTTOM) | execute 'silent $-1,$s/'.g:robots_empty. '/'.g:robots_portal.'/ge' | endif
    if s:PortalsAreOpen(s:LEFT)   | execute 'silent 1,$s/^'.g:robots_empty.'/'.g:robots_portal.'/e'    | endif
    if s:PortalsAreOpen(s:RIGHT)  | execute 'silent 1,$s/'.g:robots_empty.'$/'.g:robots_portal.'/e'    | endif
    call s:DrawBorder()

    call s:UpdateScore(0)
    normal! gg0
    setlocal nomodifiable
endfunction

function! s:DrawBorder()   "{{{1
    if !s:PortalsAreOpen(s:TOP)
        execute "silent 1s/".     g:robots_empty." " ."/".     g:robots_empty."." ."/ge"
        execute "silent 1s/". " ".g:robots_empty     ."/". ".".g:robots_empty     ."/ge"
        execute "silent 2s/".     g:robots_empty." " ."/".     g:robots_empty."'" ."/ge"
        execute "silent 2s/". " ".g:robots_empty     ."/". "'".g:robots_empty     ."/ge"
    endif
    if !s:PortalsAreOpen(s:BOTTOM)
        execute "silent $-1s/".     g:robots_empty." " ."/".     g:robots_empty."." ."/ge"
        execute "silent $-1s/". " ".g:robots_empty     ."/". ".".g:robots_empty     ."/ge"
        execute "silent   $s/".     g:robots_empty." " ."/".     g:robots_empty."'" ."/ge"
        execute "silent   $s/". " ".g:robots_empty     ."/". "'".g:robots_empty     ."/ge"
    endif
    if !s:PortalsAreOpen(s:LEFT)
        execute 'silent 2,$-1s/^ /|/e'
    endif
    if !s:PortalsAreOpen(s:RIGHT)
        execute 'silent 2,$-1s/ $/|/e'
    endif
endfunction

function! s:PortalsAreOpen(direction, forWhom = 'player')   "{{{1
    return and(s:activePortals, a:direction) != 0 &&
          \ ((a:forWhom == 'player' && s:level >= s:levelPortalsOn) ||
          \  (a:forWhom == 'robot' && s:level >= s:levelPortalsAllowRobots))
endfunction

function! s:Empty(position)   "{{{1
    let [r,c] = a:position
    if (r < 2 && s:PortalsAreOpen(s:TOP)) ||
     \ (r >= s:rows-2 && s:PortalsAreOpen(s:BOTTOM)) ||
     \ (c == 0 && s:PortalsAreOpen(s:LEFT)) ||
     \ (c == s:cols-1 && s:PortalsAreOpen(s:RIGHT))
        return g:robots_portal
    endif

    return g:robots_empty
endfunction

function! s:UpdateScore(deltaScore)   "{{{1
    let s:score += (a:deltaScore * (s:finishingLevel ? 2 : 1))
    let l:shield = trim(trim(printf('%.3f', 1.0*s:shield/s:shieldFull), '0', 2), '.', 2)
endfunction

function! s:DrawAt(position, text)   "{{{1
    let [r,c] = a:position
    let ln = getline(r)
    let leftStr = strcharpart(ln, 0, c-1)
    let rightStr = strcharpart(ln, c - 1 + strchars(a:text))
    let ln = leftStr . a:text . rightStr
    setlocal modifiable
    call setline(r, ln)
    setlocal nomodifiable
endfunction

function! s:DrawAll(positions, character, delay=0)   "{{{1
    for position in a:positions
        call s:DrawAt(s:ToScreenPosition(position), a:character)
        if a:delay > 0
            redraw
            execute 'sleep '.a:delay.'m'
        endif
    endfor
endfunction

function! s:RandomPosition()   "{{{1
    let r = Random(s:rows)
    let c = 2 * Random(s:cols/2) + (r%2 ? 0:1)
    return [r,c]
endfunction

function! s:RandomChar()   "{{{1
    return strcharpart('αβγδεζηθικλμνξοπρστυφχψωΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ', Random(48), 1)
endfunction

function! s:ToScreenPosition(position)   "{{{1
    let [r,c] = a:position
    return [r+1, 3*c+1]
endfunction

function! s:NewPosition(position, deltaRow, deltaCol, forWhom)   "{{{1
    let [r,c] = a:position
    let r += a:deltaRow
    let c += a:deltaCol
    if (r < 0 && s:PortalsAreOpen(s:TOP, a:forWhom)) ||
     \ (r >= s:rows && s:PortalsAreOpen(s:BOTTOM, a:forWhom))
        let r = (r + s:rows) % s:rows
    elseif r < 0 || r >= s:rows
        return a:position
    endif

    if (c < 0 && s:PortalsAreOpen(s:LEFT, a:forWhom)) ||
     \ (c >= s:cols && s:PortalsAreOpen(s:RIGHT, a:forWhom))
        let c = (c + s:cols) % s:cols
    elseif c < 0 || c >= s:cols
        return a:position
    endif

    return [r,c]
endfunction

function! s:WaitOneTurn()   "{{{1
    call s:MoveRobots()
    call s:Continue()
endfunction

function! s:Transport()   "{{{1
    let l:startPt = s:ToScreenPosition(s:playerPos)
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), 2, s:Empty(s:playerPos), 1, 1)
    let s:playerPos = s:RandomPosition()
    if s:shield >= s:shieldFull
        while count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
            let s:playerPos = s:RandomPosition()
        endwhile
        let s:shield -= s:shieldFull
    else
        let s:shield = 0
    endif
    let l:endPt = s:ToScreenPosition(s:playerPos)
    call s:Bezier(l:startPt, l:endPt)

    if !s:GameOver()
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), 1, g:robots_player, 2, 1)
    endif
    call s:UpdateScore(0)
    call s:Continue()
endfunction

function! s:Bezier(startPt, endPt)   "{{{1
    if !g:robots_animation
        return
    endif

    let n = Random(10)+3    " number of control points
    let pascal = [1.0]      " (n-1)th row of Pascal's triangle
    for i in range(n-1)
        call add(pascal, pascal[i] * 1.0 * (n-1-i)/(i+1))
    endfor
    let ctlPts = [a:startPt] + map(range(n-2), {_ -> [1+Random(s:height), 1+Random(s:width)]}) + [a:endPt]

    let m = 50              " number of Bezier points
    let bezier = []         " list of generated points
    for t in range(0,m)
        let t = 1.0*t/m     " percent of the way along the path
        let [r,c] = [0,0]
        for i in range(n)   " Bezier points are weighted average of control points (requires pow(0,0)=1)
            let weight = pascal[i] * pow(t,i) * pow(1-t, n-1-i)
            let [r,c] = [r + weight * ctlPts[i][0], c + weight * ctlPts[i][1]]
        endfor
        call add(bezier, [float2nr(round(r)), float2nr(round(c))])
        if t>0 && bezier[-1] == bezier[-2]  " Remove consecutive duplicates.
            call remove(bezier,-1)
        endif
    endfor

    let old_chars = map(copy(bezier), {_,v -> strcharpart(getline(v[0]), v[1]-1, 1)})
    let i = 0
    let j = -len(bezier)/2
    while i < len(bezier) || j < len(bezier)
        if i >= 0 && i < len(bezier)
            call s:DrawAt(bezier[i], s:RandomChar())
        endif
        if j >= 0 && j < len(bezier)
            call s:DrawAt(bezier[j], old_chars[j])
        endif
        redraw
        sleep 1m
        let i += 1
        let j += 1
    endwhile
    redraw
endfunction

function! s:FinishLevel()   "{{{1
    let s:finishingLevel = v:true
    while !s:PlayerWinsLevel() && !s:GameOver()
        call s:MoveRobots()
        redraw
        call s:SetStatusline()
        sleep 25m
    endwhile
    call s:Continue()
endfunction

function! s:DrawTransporterBeam(cell, beamOn, transportee, beamOff, clear)   "{{{1
    let cells = map([[-1,-1],[-1,0],[-1,1],[0,2],[1,1],[1,0],[1,-1],[0,-2]], {_,val -> [val[0]+a:cell[0], val[1]+a:cell[1]]})
    let old_chars = map(copy(cells), {_,v -> strcharpart(getline(v[0]), v[1]-1, 1)})
    call map(range(a:beamOn), {_ -> s:DrawSparkles(cells)})
    call s:DrawAt(a:cell, a:transportee)
    call map(range(a:beamOff), {_ -> s:DrawSparkles(cells)})
    if a:clear
        call s:DrawSparkles(cells, old_chars)
    endif
endfunction

function! s:DrawSparkles(cells, sparkles=[])
    let random = map(range(8), {_ -> Random(1000000)})
    for _ in random
        let i = index(random, max(random))
        let [r,c] = a:cells[i]
        if r > 0 && r <= line('$') && c > 0 && c <= strchars(getline(r))
            call s:DrawAt([r,c], empty(a:sparkles) ? s:RandomChar(): a:sparkles[i] )
        endif
        let random[i] = -1
        redraw
        sleep 1m
    endfor
endfunction

function! s:MovePlayer(deltaRow, deltaCol)   "{{{1
    let newPos = s:NewPosition(s:playerPos, a:deltaRow, a:deltaCol, 'player')
    if count(s:robotsPos, newPos) > 0 || count(s:junkPilesPos, newPos) > 0 || newPos == s:playerPos
        return
    endif
    call s:DrawAt(s:ToScreenPosition(s:playerPos), s:Empty(s:playerPos))
    let s:playerPos = newPos
    call s:DrawAt(s:ToScreenPosition(s:playerPos), g:robots_player)
    call s:MoveRobots()
    call s:Continue()
endfunction

function! s:Sign(num)   "{{{1
    return a:num == 0 ? 0 : (a:num < 0 ? -1 : 1)
endfunction

function! s:MoveRobots()   "{{{1
    let newRobotPos = []
    for robot in s:robotsPos
        let deltaRow = s:playerPos[0] == robot[0] ? 2*Random(2)-1 : s:playerPos[0] - robot[0]
        let deltaCol = s:playerPos[1] - robot[1]

        if s:PortalsAreOpen(s:TOP, 'robot') && abs(deltaRow-s:rows) < abs(deltaRow) " wrap-around going up
            let deltaRow = -1
        elseif s:PortalsAreOpen(s:BOTTOM, 'robot') && abs(deltaRow+s:rows) < abs(deltaRow) " wrap-around going down
            let deltaRow = 1
        elseif robot[0]>0 && robot[0]<s:rows - 1 " middle of the field
            let deltaRow = s:Sign(deltaRow)
        else
            let deltaRow = robot[0]==0 ? 1 : -1 " on the edge, no wrap-around
        endif
        let deltaRow *= (deltaCol == 0 ? 2 : 1) " going straight up or down is two rows, not one.

        if s:PortalsAreOpen(s:LEFT, 'robot') && abs(deltaCol-s:cols) < abs(deltaCol) " wrap-around going left
            let deltaCol = -1
        elseif s:PortalsAreOpen(s:RIGHT, 'robot') && abs(deltaCol+s:cols) < abs(deltaCol) "wrap-around going right
            let deltaCol = 1
        else
            let deltaCol = s:Sign(deltaCol) " no wrap-around
        endif

        let newPos = s:NewPosition(robot, deltaRow, deltaCol, 'robot')
        if count(s:junkPilesPos, newPos) == 0
            call add(newRobotPos, newPos)
        else
            if s:finishingLevel
                let s:shield += 1
            endif
            call s:UpdateScore(1)
        endif
    endfor

    for position in s:robotsPos
        call s:DrawAt(s:ToScreenPosition(position), s:Empty(position))
    endfor
    let s:robotsPos = newRobotPos
    call s:DrawAll(s:robotsPos, g:robots_robot)
    call s:CreateJunkPiles()
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)
endfunction

function! s:CreateJunkPiles()   "{{{1
    let kills = 0
    let collisions = map(copy(s:robotsPos), {_,v -> count(s:robotsPos, v)})
    for i in range(len(collisions)-1, 0, -1)
        if collisions[i] > 1
            call add(s:junkPilesPos, s:robotsPos[i])
            call remove(s:robotsPos, i)
            let kills += 1
        endif
    endfor
    let s:junkPilesPos = uniq(sort(s:junkPilesPos))
    let s:shield += (s:finishingLevel ? kills : 0)
    call s:UpdateScore(kills)
endfunction

function! s:GameOver()   "{{{1
    return count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
endfunction

function! s:PlayerWinsLevel()   "{{{1
    return len(s:robotsPos) == 0
endfunction

function! s:Continue()   "{{{1
    if s:GameOver()
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), 0, '╳', 0, 0)
        call s:PlayAnother()
    elseif s:PlayerWinsLevel()
        call s:DrawAll(s:junkPilesPos, g:robots_empty, 25)
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), 2, s:Empty(s:playerPos), 0, 1)
        call s:StartNewLevel()
    endif
endfunction

function! s:PlayAnother()   "{{{1
    setlocal modifiable
    call s:DrawAt([s:rows/2-1,(s:width-strchars('GAME OVER'))/2], 'GAME OVER')
    call s:DrawAt([s:rows/2+1,(s:width-strchars('Play Again?'))/2], 'Play Again?')
    setlocal nomodifiable
    redraw!
    if nr2char(getchar()) ==? 'y'
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), 2, s:Empty(s:playerPos), 1, 1)
        call s:StartNewGame()
    else
        let &hlsearch = s:hlsearch
        bwipeout
    endif
endfunction
