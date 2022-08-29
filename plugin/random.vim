let s:seed = reltime()[1]
let s:max = 1000000000

function! Random(...)
    " This is loosely based on the middle-square method: https://www.wikiwand.com/en/Middle-square_method
    "
    " Without a parameter, this function returns a number in the range [0,1).
    " With an integer parameter, n, it returns an integer in the range [0,n-1].
    if a:0 && (type(a:1) != v:t_number || a:1 < 1 || a:1 > s:max)
        throw 'Error calling Random(): Optional argument must be a positive integer <= ' . s:max . '.'
    endif

    let s:seed = float2nr(pow(s:seed + reltime()[1],2)) % s:max
    return a:0 == 0 ? (s:seed / (1.0 * s:max)) : (s:seed % a:1)
endfunction
