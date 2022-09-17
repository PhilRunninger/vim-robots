" vim: foldmethod=marker

command! Robots :call <SID>InitAndStartRobots()   "{{{1

function! s:InitAndStartRobots()   "{{{1
    let g:robots_empty     = get(g:, 'robots_empty', '·')
    let g:robots_robot     = get(g:, 'robots_robot', '■')
    let g:robots_junk_pile = get(g:, 'robots_junk_pile', '▲')
    let g:robots_player    = get(g:, 'robots_player', '●')
    let g:robots_portal    = get(g:, 'robots_portal', '○')
    let g:robots_portal_intro = 'Portals along the edge will transport you to the opposite side.'
    let g:robots_portal_warning =  'Oh no! The robots found the shortcuts. Watch out!'
    let g:robots_game_over =  'You were terminated! Another game?'

    tabnew
    let s:playerShortcutRound = 5
    let s:robotsShortcutRound = s:playerShortcutRound + 4
    let s:transportRate = 5
    let s:width = getwininfo(win_getid())[0]['width']
    let s:height = getwininfo(win_getid())[0]['height']
    let s:cols = 2*float2nr((s:width+2)/6)
    let s:rows = 2*float2nr(s:height/2) - 2

    setlocal filetype=robotsgame buftype=nofile bufhidden=wipe
    setlocal nonumber signcolumn=no nolist nocursorline nocursorcolumn nohlsearch
    execute 'setlocal statusline='.g:robots_player.':you\ '.g:robots_robot.':robot\ '.g:robots_junk_pile.':junk\ pile\ \ yujkbn:Move\ \ w:Wait\ \ t:Transport\ \ F:Finish'

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
    nnoremap <buffer> <silent> F :call <SID>FinishRound()<CR>
    nnoremap <buffer> <silent> <Esc> :tabprevious<CR>

    call s:StartNewGame()
endfunction

function! s:StartNewGame()   "{{{1
    let s:score = 0
    let s:round = 0
    let s:safeTransports = 0
    call s:StartNewRound()
endfunction

function! s:StartNewRound()   "{{{1
    let s:round += 1
    let s:finishingRound = v:false
    let l:startPt = exists('s:playerPos') ? s:ToScreenPosition(s:playerPos) : [s:height/2, s:width/2]

    call s:CreateRobotsAndPlayer()
    call s:DrawGrid()
    call s:Bezier(l:startPt, s:ToScreenPosition(s:playerPos))
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✹'], g:robots_player, ['✴✶✦',' '])
    call s:DrawAll(s:robotsPos, g:robots_robot, 10)
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)

    if s:round == s:playerShortcutRound
        call s:DrawAt([2,1], printf('%*s', (s:width+strchars(g:robots_portal_intro))/2, g:robots_portal_intro))
    elseif s:round == s:robotsShortcutRound
        call s:DrawAt([2,1], printf('%*s', (s:width+strchars(g:robots_portal_warning))/2, g:robots_portal_warning))
    endif
endfunction

function! s:RobotCount()   "{{{1
    let l:cells = (s:rows * s:cols / 2)  " # of cells on the board
    return float2nr(l:cells * tanh((s:round) / pow(l:cells, 0.66)))
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
        call append(0, (r%2 ? '':'   ').trim(repeat(g:robots_empty.'     ',s:cols/2)).(r%2 ? '   ':''))
    endfor
    execute 'g/^$/d'
    if s:VerticalPortalsAreOpen()
        execute 'silent 1s/'.g:robots_empty.'/'.g:robots_portal.'/ge'
        execute 'silent $s/'.g:robots_empty.'/'.g:robots_portal.'/ge'
    endif
    if s:HorizontalPortalsAreOpen()
        execute 'silent 1,$s/^'.g:robots_empty.'/'.g:robots_portal.'/e'
        execute 'silent 1,$s/^.\{'.3*(s:cols-1).'}\zs'.g:robots_empty.'/'.g:robots_portal.'/e'
    endif
    call append(0, ['',''])
    call s:UpdateScore(0)
    normal! 2gg
    setlocal nomodifiable
endfunction

function! s:PortalsAreOpen(open, forWhom)   "{{{1
    return a:open && ( a:forWhom == 'any' ||
                   \  (a:forWhom == 'player' && s:round >= s:playerShortcutRound) ||
                   \  (a:forWhom == 'robot' && s:round >= s:robotsShortcutRound))
endfunction

function! s:VerticalPortalsAreOpen(forWhom = 'any')
    return s:PortalsAreOpen(((s:round-s:playerShortcutRound) / 2) % 2 == 1, a:forWhom)
endfunction

function! s:HorizontalPortalsAreOpen(forWhom = 'any')
    return s:PortalsAreOpen((s:round-s:playerShortcutRound) % 2 == 1, a:forWhom)
endfunction

function! s:Empty(position)   "{{{1
    let [r,c] = a:position
    if (r == 0 || r == s:rows-1) && s:VerticalPortalsAreOpen()
        return g:robots_portal
    endif
    if (c == 0 || c == s:cols-1) && s:HorizontalPortalsAreOpen()
        return g:robots_portal
    endif

    return g:robots_empty
endfunction

function! s:UpdateScore(deltaScore)   "{{{1
    let s:score += (a:deltaScore * (s:finishingRound ? 2 : 1))
    setlocal modifiable
    let l:safeTransports = trim(trim(printf('%.3f', 1.0*s:safeTransports/s:transportRate), '0', 2), '.', 2)
    call setline(1, printf('ROBOTS  Round: %-3d  Score: %-3d  Robots Remaining: %-3d  Safe Transports: %s',
                         \ s:round, s:score, len(s:robotsPos), l:safeTransports))
    setlocal nomodifiable
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

function! s:ToScreenPosition(position)   "{{{1
    let [r,c] = a:position
    return [r+3, 3*c+1]
endfunction

function! s:NewPosition(position, deltaRow, deltaCol, forWhom)   "{{{1
    let [r,c] = a:position
    let r += a:deltaRow
    let c += a:deltaCol
    if s:VerticalPortalsAreOpen(a:forWhom)
        let r = (r + s:rows) % s:rows
    elseif r < 0 || r >= s:rows
        return a:position
    endif

    if s:HorizontalPortalsAreOpen(a:forWhom)
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
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✴✶✦'], g:robots_empty, [' '])
    let s:playerPos = s:RandomPosition()
    if s:safeTransports >= s:transportRate
        while count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
            let s:playerPos = s:RandomPosition()
        endwhile
        let s:safeTransports -= s:transportRate
    else
        let s:safeTransports = 0
    endif
    let l:endPt = s:ToScreenPosition(s:playerPos)
    call s:Bezier(l:startPt, l:endPt)

    if s:GameOver()
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), [], 'X', ['×x'])
    else
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✶'], g:robots_player, ['✴✶✦',' '])
    endif
    call s:UpdateScore(0)
    call s:Continue()
endfunction

function! s:Bezier(startPt, endPt)   "{{{1
    let l:count = 50
    let l:ctl = [a:startPt, [1+Random(s:height), 1+Random(s:width)], [1+Random(s:height), 1+Random(s:width)], a:endPt]
    let l:bezier = []
    for t in range(0,l:count)
        let t = 1.0*t/l:count
        call add(l:bezier,
                    \ [float2nr(round(pow(1-t,3.0)*l:ctl[0][0] + 3.0*pow(1-t,2.0)*t*l:ctl[1][0] + 3.0*(1-t)*pow(t,2.0)*l:ctl[2][0] + pow(t,3.0)*l:ctl[3][0])),
                    \  float2nr(round(pow(1-t,3.0)*l:ctl[0][1] + 3.0*pow(1-t,2.0)*t*l:ctl[1][1] + 3.0*(1-t)*pow(t,2.0)*l:ctl[2][1] + pow(t,3.0)*l:ctl[3][1]))])
        if t>0 && l:bezier[-1] == l:bezier[-2]  " Remove consecutive duplicates.
            call remove(l:bezier,-1)
        endif
    endfor

    let old_chars = map(copy(l:bezier), {_,v -> strcharpart(getline(v[0]), v[1]-1, 1)})
    let i = 0
    let j = -len(l:bezier)/2
    while i < len(l:bezier) || j < len(l:bezier)
        if i >= 0 && i < len(l:bezier)
            call s:DrawAt(l:bezier[i], strcharpart('✦★✶',Random(3),1))
        endif
        if j >= 0 && j < len(l:bezier)
            call s:DrawAt(l:bezier[j], old_chars[j])
        endif
        redraw
        sleep 1m
        let i += 1
        let j += 1
    endwhile
    redraw
endfunction

function! s:FinishRound()   "{{{1
    let s:finishingRound = v:true
    while !s:PlayerWinsRound() && !s:GameOver()
        call s:MoveRobots()
        redraw
        sleep 100m
    endwhile
    call s:Continue()
endfunction

function! s:DrawTransporterBeam(cell, beamOn, transportee, beamOff)   "{{{1
    let cells = map([[-1,-1],[-1,0],[-1,1],[0,2],[1,1],[1,0],[1,-1],[0,-2]], {_,val -> [val[0]+a:cell[0], val[1]+a:cell[1]]})
    for sparkles in [a:beamOn, a:beamOff]
        for sparkle in sparkles
            let random = map(range(8*strchars(sparkle)), {_ -> Random(1000000)})
            for i in range(8*strchars(sparkle))
                let max = index(random, max(random))
                let [r,c] = cells[max % 8]
                let random[max] = -1
                if r > 2 && r <= line('$') && c > 0 && c <= strchars(getline(r))
                    call s:DrawAt([r,c], strcharpart(sparkle,max/8,1))
                endif
                redraw
                sleep 25m
            endfor
        endfor
        call s:DrawAt(a:cell, a:transportee)
        redraw
        sleep 100m
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

        if s:VerticalPortalsAreOpen('robot')
            let deltaRow = abs(deltaRow) > s:rows/2 ? -s:Sign(deltaRow) : s:Sign(deltaRow)
        elseif robot[0]>0 && robot[0]<s:rows
            let deltaRow = s:Sign(deltaRow)
        else
            let deltaRow = robot[0]==0 ? 1 : -1
        endif
        let deltaRow *= (deltaCol == 0 ? 2 : 1)

        if s:HorizontalPortalsAreOpen('robot')
            let deltaCol = abs(deltaCol) > s:cols/2 ? -s:Sign(deltaCol) : s:Sign(deltaCol)
        else
            let deltaCol = s:Sign(deltaCol)
        endif

        let newPos = s:NewPosition(robot, deltaRow, deltaCol, 'robot')
        if count(s:junkPilesPos, newPos) == 0
            call add(newRobotPos, newPos)
        else
            if s:finishingRound
                let s:safeTransports += 1
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
    let s:safeTransports += (s:finishingRound ? kills : 0)
    call s:UpdateScore(kills)
endfunction

function! s:GameOver()   "{{{1
    return count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
endfunction

function! s:PlayerWinsRound()   "{{{1
    return len(s:robotsPos) == 0
endfunction

function! s:Continue()   "{{{1
    if s:GameOver()
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), [], 'X', ['×x'])
        call s:PlayAnother()
    elseif s:PlayerWinsRound()
        call s:DrawAll(s:junkPilesPos, g:robots_empty, 25)
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✴✶✦'], g:robots_empty, [' '])
        call s:StartNewRound()
    endif
endfunction

function! s:PlayAnother()   "{{{1
    setlocal modifiable
    call setline(2,'')
    call s:DrawAt([2,1], printf('%*s', (s:width+strchars(g:robots_game_over))/2, g:robots_game_over))
    setlocal nomodifiable
    redraw!
    if nr2char(getchar()) ==? 'y'
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✴✶✦'], g:robots_empty, [' '])
        call s:StartNewGame()
    else
        bwipeout
    endif
endfunction
