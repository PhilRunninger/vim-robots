function! Random(...)
    " Without a parameter, this function returns a number in the range [0,1).
    " With an integer parameter, n, it returns an integer in the range [0,n-1].
    if a:0 && (type(a:1) != v:t_number || a:1 < 1)
        throw 'Error in call Random(' . a:1 . ') - optional argument must be a positive integer.'
    endif

    let num = map(range(3), {_ -> fmod(reltimefloat(reltime()),1) * 1.0e6})
    let num = fmod(num[0]*num[1]*num[2], 2038074743) / 2038074743.0
    return a:0 ? float2nr(num*a:1) : num
endfunction
