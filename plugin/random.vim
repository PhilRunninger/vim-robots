let s:seed = str2nr(matchstr(reltimestr(reltime()), '\d\{1,6}$')[1:])

function! Random(...)
    " This is the middle-square method with entropy added for more randomness.
    " https://www.wikiwand.com/en/Middle-square_method
    "
    " Without a parameter, this function returns a number in the range [0,1).
    " With an integer parameter, n, it returns an integer in the range [0,n-1].
    if a:0 && type(a:1) != v:t_number
        throw "DataTypeError: Optional argument must be integer"
    else
        let entropy = str2nr(matchstr(reltimestr(reltime()), '\d\{1,6}$')[1:])
        let x = s:seed + entropy
        let x = string(float2nr(pow(x,2)))
        let start = (strlen(x)-6)/2
        let s:seed = str2nr(strcharpart(x, start, 6))
        return a:0 == 0 ? (s:seed / 1000000.0) : (float2nr(s:seed % a:1))
    endif
endfunction
