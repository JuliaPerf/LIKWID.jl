# saxpy_threads.jl
using LIKWID
using LinearAlgebra
using Base.Threads: nthreads, @threads

@show Threads.nthreads()
@assert nthreads() > 1 # multithreading

# Julia threads must be pinned!
LIKWID.pinthreads(0:(nthreads() - 1))

using ThreadPinning
threadinfo(; color = false)

const N = 100_000_000
const a = 3.141f0
const zs = zeros(N)
const x = rand(N)
const y = rand(N)

Marker.init()

# @parallelmarker "saxpy_threads" begin
#     Threads.@threads for i in eachindex(x, y)
#         zs[i] = a * x[i] * y[i]
#     end
# end

results = Vector{Float64}(undef, Threads.nthreads())
Threads.@threads :static for i in 1:Threads.nthreads()
    LIKWID.Marker.startregion("flop")
    results[i] = 3.12 * 4.34
    LIKWID.Marker.stopregion("flop")
end

Marker.close()
