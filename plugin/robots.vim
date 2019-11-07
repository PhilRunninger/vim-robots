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
    call s:DrawAt(s:ToScreenPosition(s:playerPos), g:robots_player)
endfunction

function! s:InitAll()   "{{{1
    tabnew

    let s:cols = 2*((getwininfo(win_getid())[0]['width']+5)/6)
    let s:rows = 2*(getwininfo(win_getid())[0]['height']/2) - 2
    let s:robotCount = 20
    let g:robots_empty = "·"
    let g:robots_robot = "◯"
    let g:robots_junk_pile = "▲"
    let g:robots_player = "●"

    setlocal filetype=robotsgame
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal nonumber
    setlocal nocursorline nocursorcolumn

    nnoremap <buffer> <silent> 1 :call <SID>MovePlayer(1,-1)<CR>
    nnoremap <buffer> <silent> 2 :call <SID>MovePlayer(2, 0)<CR>
    nnoremap <buffer> <silent> 3 :call <SID>MovePlayer(1, 1)<CR>
    nnoremap <buffer> <silent> 4 <nop>
    nnoremap <buffer> <silent> 5 :call <SID>MoveRobots()<CR>
    nnoremap <buffer> <silent> 6 <nop>
    nnoremap <buffer> <silent> 7 :call <SID>MovePlayer(-1,-1)<CR>
    nnoremap <buffer> <silent> 8 :call <SID>MovePlayer(-2, 0)<CR>
    nnoremap <buffer> <silent> 9 :call <SID>MovePlayer(-1, 1)<CR>
    nnoremap <buffer> <silent> <Enter> :call <SID>Teleport()<CR>
endfunction

function! s:InitRobotsAndPlayer()   "{{{1
    let s:junkPilesPos = []
    let s:robotsPos = []
    for i in range(1,s:robotCount)
        call add(s:robotsPos, s:RandomPosition())
        while index(s:robotsPos, s:robotsPos[-1]) == 2
            let s:robotsPos[-1] = s:RandomPosition()
        endwhile
    endfor

    let s:playerPos = s:RandomPosition()
    while index(s:robotsPos, s:playerPos) == 1
        let s:playerPos = s:RandomPosition()
    endwhile
endfunction

function! s:DrawGrid()   "{{{1
    setlocal modifiable
    normal! ggdG
    for r in range(1,s:rows,1)
        call append(0, (r % 2 ? "" : "   ") . trim(repeat("·     ", s:cols/2)))
    endfor
    execute 'g/^$/d'
    call append(0, ["ROBOTS    Score: 0",""])
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

function! s:EraseCell(position)   "{{{1
    call s:DrawAt(s:ToScreenPosition(a:position), g:robots_empty)
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

function! s:Teleport()   "{{{1
    call s:EraseCell(s:playerPos)
    let s:playerPos = s:RandomPosition()
    while index(s:robotsPos, s:playerPos) == 1
        let s:playerPos = s:RandomPosition()
    endwhile
    call s:DrawAt(s:ToScreenPosition(s:playerPos), g:robots_player)
endfunction

function! s:MovePlayer(deltaRow, deltaCol)   "{{{1
    let newPos = s:NewPosition(s:playerPos, a:deltaRow, a:deltaCol)
    if index(s:junkPilesPos,newPos) != -1 || index(s:robotsPos,newPos) != -1 || newPos == s:playerPos
        return
    endif
    call s:EraseCell(s:playerPos)
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
        if index(s:junkPilesPos, newPos) == -1
            call add(newRobotPos, newPos)
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
endfunction

function! s:CheckForGameOver()   "{{{1
    let options = #{filter:"popup_filter_yesno", callback:"PlayAnother"}
    if len(s:robotsPos) == 0
        let s:robotCount = float2nr(ceil(s:robotCount * 1.25))
        call popup_dialog("You Won!  Another Game? y/n", options)
    elseif index(s:robotsPos, s:playerPos) != -1
        let s:robotCount = 20
        call popup_dialog("You've been terminated!  Another Game? y/n", options)
    endif
endfunction

function! PlayAnother(id, result)   "{{{1
    if a:result
        call s:StartRobots(0)
    else
        bwipeout
    endif
endfunction
