using Test
using BenchmarkTools
using CUDA

# delete a var


N = 10^2
x = fill(1.0f0, N)  # a vector filled with 1.0 (Float32)
y = fill(2.0f0, N)  # a vector filled with 2.0

# y .+= x 
# pf = @test all(y .== 3.0f0)
# println(pf)

# function sequential_add!(y, x)
#     for i in eachindex(y, x)
#         @inbounds y[i] += x[i]
#     end
#     return nothing
# end

# function parallel_add!(y, x)
#     Threads.@threads for i in eachindex(y, x)
#         @inbounds y[i] += x[i]
#     end
#     return nothing
# end

# fill!(y, 2.0f0)
# @btime sequential_add!(y, x)

# fill!(y, 2.0f0)
# @btime parallel_add!(y, x)

x_d = CUDA.fill(1.0f0, N)  # a vector stored on the GPU filled with 1.0 (Float32)
y_d = CUDA.fill(2.0f0, N)  # a vector stored on the GPU filled with 2.0