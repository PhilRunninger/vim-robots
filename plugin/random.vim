let s:seed = reltime()[1]

function! Random(...)
    " This is the middle-square method with entropy added for more randomness.
    " https://www.wikiwand.com/en/Middle-square_method
    "
    " Without a parameter, this function returns a number in the range [0,1).
    " With an integer parameter, n, it returns an integer in the range [0,n-1].
    if a:0 && (type(a:1) != v:t_number || a:1 < 1 || a:1 > 1000000000)
        throw "DataTypeError: Optional argument must be a positive integer <= 1,000,000,000."
    endif

    let s:seed = pow(s:seed + reltime()[1],2)
    let power = log10(s:seed)
    let s:seed = float2nr(s:seed / pow(10,power/4)) % 1000000000
    return a:0 == 0 ? (s:seed / 1000000000.0) : (s:seed % a:1)
endfunction
