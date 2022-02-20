# saxpy_threads.jl
using LIKWID
using LinearAlgebra
using Base.Threads: nthreads, @threads

@assert nthreads() > 1 # multithreading

# Julia threads should be pinned!
@threads :static for tid in 1:nthreads()
    core = LIKWID.get_processor_id()
    println("Thread $tid, Core $core")
end

N = 100_000_000
a = 3.141f0
zs = [zeros(Float32, N) for _ in 1:nthreads()]
x = rand(Float32, N)
y = rand(Float32, N)

function saxpy_cpu!(z, a, x, y)
    z .= a .* x .+ y
end

function saxpy_threads(zs, a, x, y)
    @threads :static for tid in 1:nthreads()
        @region "saxpy_cpu!" saxpy_cpu!(zs[tid], a, x, y)
    end
end

Marker.init()

saxpy_cpu!(zs[1], a, x, y) # precompile saxpy_cpu
saxpy_threads(zs, a, x, y)

Marker.close()