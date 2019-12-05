" vim: foldmethod=marker

command! Robots :call <SID>InitAndStartRobots()   "{{{1

function! s:InitAndStartRobots()   "{{{1
    let g:robots_empty = '·'
    let g:robots_robot = '■'
    let g:robots_junk_pile = '▲'
    let g:robots_player = '●'

    tabnew
    let s:cols = 2*((getwininfo(win_getid())[0]['width']+5)/6)
    let s:rows = 2*(getwininfo(win_getid())[0]['height']/2) - 2

    setlocal filetype=robotsgame buftype=nofile bufhidden=wipe
    setlocal nonumber signcolumn=no nolist nocursorline nocursorcolumn

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
    nnoremap <buffer> <silent> f :call <SID>FinishRound()<CR>
    nnoremap <buffer> <silent> <Esc> :tabprevious<CR>

    call s:StartNewGame()
endfunction

function! s:StartNewGame()   "{{{1
    let s:score = 0
    let s:round = -1
    let s:safeTransports = 0.0
    call s:StartNewRound()
endfunction

function! s:StartNewRound()   "{{{1
    let s:round += 1
    let s:finishingRound = 0
    call s:CreateRobotsAndPlayer()
    call s:DrawGrid()
    call s:DrawAll(s:robotsPos, g:robots_robot)
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✶'], g:robots_player, ['★','✦',' '])
endfunction

function s:RobotCount()   "{{{1
    " https://en.wikipedia.org/wiki/Logistic_function
    let l:count = float2nr(0.5 * (s:rows * s:cols / 2) / (1 + exp(-0.33*(s:round - 13))))
    return max([2,l:count])
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
        call append(0, strcharpart((r % 2 ? '' : '   ') . repeat('·     ', s:cols/2), 0, getwininfo(win_getid())[0]['width']))
    endfor
    execute 'g/^$/d'
    call append(0, ['',''])
    call s:UpdateScore(0)
    normal! gg
    setlocal nomodifiable
endfunction

function! s:UpdateScore(deltaScore)   "{{{1
    let s:score += a:deltaScore
    setlocal modifiable
    call setline(1, 'ROBOTS  Round: '.(s:round+1).'  Score: '.s:score.'  Robots Remaining: '.len(s:robotsPos).'  Safe Transports: '.string(s:safeTransports))
    setlocal nomodifiable
endfunction

function! s:DrawAt(position, character)   "{{{1
    let [r,c] = a:position
    let line = getline(r)
    let lft = strcharpart(line, 0, c-1)
    let rgt = strcharpart(line, c)
    setlocal modifiable
    call setline(r, lft.a:character.rgt)
    setlocal nomodifiable
endfunction

function! s:DrawAll(positions, character)   "{{{1
    for position in a:positions
        call s:DrawAt(s:ToScreenPosition(position), a:character)
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

function! s:NewPosition(position, deltaRow, deltaCol)   "{{{1
    let [r,c] = a:position
    let r += a:deltaRow
    let c += a:deltaCol
    if r < 0 || r >= s:rows || c < 0 || c >= s:cols
        return a:position
    else
        return [r,c]
    endif
endfunction

function! s:WaitOneTurn()   "{{{1
    call s:MoveRobots()
    call s:Continue()
endfunction

function! s:Transport()   "{{{1
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✦','★','✶'], g:robots_empty, [' '])
    let s:playerPos = s:RandomPosition()
    if s:safeTransports >= 1.0
        while count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
            let s:playerPos = s:RandomPosition()
        endwhile
        let s:safeTransports -= 1.0
    else
        let s:safeTransports = 0.0
    endif
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✶'], g:robots_player, ['★','✦',' '])
    call s:UpdateScore(0)
    call s:Continue()
endfunction

function! s:FinishRound()   "{{{1
    let s:finishingRound = 1
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
            let random = map(range(8), {_ -> Random(1000000)})
            for i in range(8)
                let max = index(random, max(random))
                let [r,c] = cells[max]
                let random[max] = -1
                if r > 2 && r <= line('$') && c > 0 && c <= strchars(getline(r))
                    call s:DrawAt([r,c], sparkle)
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
    let newPos = s:NewPosition(s:playerPos, a:deltaRow, a:deltaCol)
    if count(s:robotsPos, newPos) > 0 || count(s:junkPilesPos, newPos) > 0 || newPos == s:playerPos
        return
    endif
    call s:DrawAt(s:ToScreenPosition(s:playerPos), g:robots_empty)
    let s:playerPos = newPos
    call s:DrawAt(s:ToScreenPosition(s:playerPos), g:robots_player)
    call s:MoveRobots()
    call s:Continue()
endfunction

function! s:MoveRobots()   "{{{1
    let newRobotPos = []
    for robot in s:robotsPos
        let deltaRow = s:playerPos[0] - robot[0]
        let deltaCol = s:playerPos[1] - robot[1]
        let deltaRow = (deltaRow == 0 ? (robot[0]==0 ? 1 : (robot[0]==s:rows-1 ? -1 : 2*Random(2)-1)) : deltaRow/abs(deltaRow))
        let deltaRow *= (deltaCol == 0 ? 2 : 1)
        let deltaCol = (deltaCol == 0 ? 0 : deltaCol/abs(deltaCol))
        let newPos = s:NewPosition(robot, deltaRow, deltaCol)
        if count(s:junkPilesPos, newPos) == 0
            call add(newRobotPos, newPos)
        else
            call s:UpdateScore(1)
            if s:finishingRound
                let s:safeTransports += 0.1
            endif
        endif
    endfor

    call s:DrawAll(s:robotsPos, g:robots_empty)
    let s:robotsPos = newRobotPos
    call s:DrawAll(s:robotsPos, g:robots_robot)
    call s:CreateJunkPiles()
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)
endfunction

function! s:CreateJunkPiles()   "{{{1
    let collisions = []
    for a in range(0, len(s:robotsPos)-1)
        if a < len(s:robotsPos)
            for b in range(a+1, len(s:robotsPos)-1)
                if b < len(s:robotsPos) && s:robotsPos[a] == s:robotsPos[b]
                    call add(collisions, a)
                    call add(collisions, b)
                endif
            endfor
        endif
    endfor
    let collisions = reverse(uniq(sort(collisions, 'n')))
    for collision in collisions
        call add(s:junkPilesPos, s:robotsPos[collision])
        call remove(s:robotsPos,collision)
    endfor
    let s:junkPilesPos = uniq(sort(s:junkPilesPos))
    call s:UpdateScore(len(collisions))
endfunction

function! s:GameOver()   "{{{1
    return count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
endfunction

function! s:PlayerWinsRound()   "{{{1
    return len(s:robotsPos) == 0
endfunction

function! s:Continue()   "{{{1
    if s:GameOver()
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), [], 'X', ['x'])
        call popup_dialog("You've been terminated!  Another Game? y/n", #{filter:'popup_filter_yesno', callback:'PlayAnother'})
    elseif s:PlayerWinsRound()
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✦','★','✶'], g:robots_empty, [' '])
        call s:StartNewRound()
    endif
endfunction

function! PlayAnother(id, result)   "{{{1
    if a:result
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ['✦','★','✶'], g:robots_empty, [' '])
        call s:StartNewGame()
    else
        bwipeout
    endif
endfunction
