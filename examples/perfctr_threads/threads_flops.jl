# saxpy_threads.jl
using LIKWID
using LinearAlgebra
using Base.Threads: nthreads, @threads

@assert nthreads() > 1 # multithreading

# Julia threads should be pinned!
# cores = 0:nthreads()-1
# @threads for tid in 1:nthreads()
#     LIKWID.pinthread(cores[tid])
# end

@threads for tid in 1:nthreads()
    core = LIKWID.get_processor_id()
    println("Thread $tid, Core $core")
end

# N = 100_000_000
# a = 3.141f0
# zs = [zeros(Float32, N) for _ in 1:nthreads()]
# xs = [zeros(Float32, N) for _ in 1:nthreads()]
# ys = [zeros(Float32, N) for _ in 1:nthreads()]

# function saxpy_cpu!(z, a, x, y)
#     z .= a .* x .+ y
# end

# function saxpy_threads(zs, a, xs, ys)
#     @threads for tid in 1:nthreads()
#         @region "saxpy_cpu!" saxpy_cpu!(zs[tid], a, xs[tid], ys[tid])
#     end
# end

function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end

function monitor_do_flops(NUM_FLOPS = 100_000_000)
    a = 1.8
    b = 3.2
    c = 1.0
    @threads for tid in 1:nthreads()
        Marker.startregion("calc_flops")
        c = do_flops(c, a, b, NUM_FLOPS)
        Marker.stopregion("calc_flops")
    end
    return nothing
end

Marker.init()

@threads for tid in 1:nthreads()
    Marker.registerregion("calc_flops")
end

monitor_do_flops()

Marker.close()