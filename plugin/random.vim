" Pseudo-Random Number Generator
"
" Uses the Lehmer, aka Park-Miller, algorithm.
" https://en.wikipedia.org/wiki/Lehmer_random_number_generator
"
" Without a parameter, this function returns a number in the range [0,1).
" With an integer parameter, n, it returns an integer in the range [0,n-1].

let s:state = float2nr(fmod(reltimefloat(reltime()),1) * 1.0e7)

function! Random(...)
    if a:0 && (type(a:1) != v:t_number || a:1 < 1)
        throw 'Error in call Random(' . a:1 . ') - optional argument must be a positive integer.'
    endif

    let s:state = (s:state * 48271) % 0x7fffffff

    let result = s:state / (0x7fffffff + 1.0)
    return a:0 ? float2nr(result * a:1) : result
endfunction
