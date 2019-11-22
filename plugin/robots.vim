" vim: foldmethod=marker

command! Robots :call <SID>StartRobots(1)   "{{{1

function! s:StartRobots(first)   "{{{1
    if a:first
        call s:InitAll()
    endif
    call s:InitRobotsAndPlayer()
    call s:DrawGrid()
    call s:DrawAll(s:robotsPos, g:robots_robot)
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ["✶"], g:robots_player, ["★","✦"," "])
endfunction

function! s:InitAll()   "{{{1
    tabnew

    let s:cols = 2*((getwininfo(win_getid())[0]['width']+5)/6)
    let s:rows = 2*(getwininfo(win_getid())[0]['height']/2) - 2
    let s:score = 0
    let s:robotCount = 2
    let g:robots_empty = "·"
    let g:robots_robot = "■"
    let g:robots_junk_pile = "▲"
    let g:robots_player = "●"

    setlocal filetype=robotsgame buftype=nofile bufhidden=wipe
    setlocal nonumber nolist nocursorline nocursorcolumn

    nnoremap <buffer> <silent> 1 :call <SID>MovePlayer(1,-1)<CR>
    nnoremap <buffer> <silent> 2 :call <SID>MovePlayer(2, 0)<CR>
    nnoremap <buffer> <silent> 3 :call <SID>MovePlayer(1, 1)<CR>
    nnoremap <buffer> <silent> 4 <nop>
    nnoremap <buffer> <silent> 5 :call <SID>MoveRobots()<CR>
    nnoremap <buffer> <silent> 6 <nop>
    nnoremap <buffer> <silent> 7 :call <SID>MovePlayer(-1,-1)<CR>
    nnoremap <buffer> <silent> 8 :call <SID>MovePlayer(-2, 0)<CR>
    nnoremap <buffer> <silent> 9 :call <SID>MovePlayer(-1, 1)<CR>
    nnoremap <buffer> <silent> <Enter> :call <SID>Transport()<CR>
endfunction

function! s:InitRobotsAndPlayer()   "{{{1
    let s:junkPilesPos = []
    let s:robotsPos = []
    for i in range(1,s:robotCount)
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
        call append(0, strcharpart((r % 2 ? "" : "   ") . repeat("·     ", s:cols/2), 0, getwininfo(win_getid())[0]['width']))
    endfor
    execute 'g/^$/d'
    call append(0, ["",""])
    call s:UpdateScore(0)
    setlocal nomodifiable
endfunction

function! s:UpdateScore(deltaScore)
    let s:score += a:deltaScore
    setlocal modifiable
    call setline(1, "ROBOTS  Score: ".s:score."  Robots Remaining: ".len(s:robotsPos))
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

function! s:Transport()   "{{{1
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ["✦","★","✶"], g:robots_empty, [" "])
    let s:playerPos = s:RandomPosition()
    while count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
        let s:playerPos = s:RandomPosition()
    endwhile
    call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ["✶"], g:robots_player, ["★","✦"," "])
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
endfunction

function! s:MoveRobots()   "{{{1
    let newRobotPos = []
    for robot in s:robotsPos
        let deltaRow = s:playerPos[0] - robot[0]
        let deltaCol = s:playerPos[1] - robot[1]
        let deltaRow = (deltaRow == 0 ? 2*Random(2)-1 : deltaRow/abs(deltaRow))
        let deltaRow *= (deltaCol == 0 ? 2 : 1)
        let deltaCol = (deltaCol == 0 ? 0 : deltaCol/abs(deltaCol))
        let newPos = s:NewPosition(robot, deltaRow, deltaCol)
        if count(s:junkPilesPos, newPos) == 0
            call add(newRobotPos, newPos)
        else
            call s:UpdateScore(1)
        endif
    endfor

    call s:DrawAll(s:robotsPos, g:robots_empty)
    let s:robotsPos = newRobotPos
    call s:DrawAll(s:robotsPos, g:robots_robot)
    call s:CreateJunkPiles()
    call s:DrawAll(s:junkPilesPos, g:robots_junk_pile)
    call s:CheckForGameOver()
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

function! s:CheckForGameOver()   "{{{1
    if count(s:robotsPos, s:playerPos) > 0 || count(s:junkPilesPos, s:playerPos) > 0
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), [], "X", ["x"])
        let s:robotCount = 2
        call popup_dialog("You've been terminated!  Another Game? y/n", #{filter:"popup_filter_yesno", callback:"PlayAnother"})
    elseif len(s:robotsPos) == 0
        let s:robotCount = float2nr(ceil(s:robotCount * 1.25))
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ["✦","★","✶"], g:robots_empty, [" "])
        call s:StartRobots(0)
    endif
endfunction

function! PlayAnother(id, result)   "{{{1
    if a:result
        call s:DrawTransporterBeam(s:ToScreenPosition(s:playerPos), ["✦","★","✶"], g:robots_empty, [" "])
        call s:StartRobots(0)
    else
        bwipeout
    endif
endfunction
