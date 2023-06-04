using Base.Threads
SIZE = 100_000_00

function threadstest()
    # set of unique number
    unique_threads = Set{Int}()
    a = zeros(Int, SIZE)
    Threads.@threads for i = 1:SIZE
        id = Threads.threadid()
        a[i] = id

        # print if the thread is unique
        if !(id in unique_threads)
            println("thread $id is unique")
            push!(unique_threads, id)
        end
    end
end

function addyetmoreshit()
    array1 = rand(SIZE)
    array2 = rand(SIZE)
    result_array = zeros(SIZE)

    @threads for i in 1:SIZE
        result_array[i] = array1[i] * array2[i]
    end
end 

function addothershit()
    a = collect(1:SIZE)
    b = collect(1:SIZE)

    for i = 1:SIZE
        r = a[i] * b[i]
    end
end

function threadedaddothershit()
    a = collect(1:SIZE)
    b = collect(1:SIZE)

    Threads.@threads for i = 1:SIZE
        r = a[i] * b[i]
    end
end

function addsomearrays()
    array1 = rand(SIZE)
    array2 = rand(SIZE)
    result_array = array1 .* array2
    return result_array
end

function timeit(func)
    start = time()
    func()
    stop = time()
    elapsed = stop - start
    # print the function nam
    println("$func elapsed time: $elapsed")
end

# timeit(addsomearrays)
timeit(addothershit)
timeit(threadedaddothershit)
# timeit(addyetmoreshit)
# timeit(threadstest)