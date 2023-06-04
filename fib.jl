# 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144.


function fib(n)
    if n == 0
        return 0
    elseif n == 1 
        return 1
    elseif n == 2
        return 1
    else
        return fib(n-1) + fib(n - 2)
    end
end

fib_cache = Dict{Int, BigInt}()
fib_cache[0] = 0
fib_cache[1] = 1
fib_cache[2] = 0

function cache_fib(n)
    if haskey(fib_cache, n)
        return fib_cache[n]
    end

    r = 0
    if n == 0
        r = 0
    elseif n == 1 
        r = 1
    elseif n == 2
        r = 1
    else
        r = cache_fib(n-1) + cache_fib(n - 2)
    end

    fib_cache[n] = r
    return r
end

for i = 1:1000000
    r = cache_fib(i)
    # println("$i : $r")
    println("$i")
end


