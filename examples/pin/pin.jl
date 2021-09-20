# likwid-pin -s 0xffffffffffffffe1 -c 1,3,5,7 julia -t4 pin.jl
using Base.Threads

glibc_coreid() = @ccall sched_getcpu()::Cint

@threads for i in 1:nthreads()
    println("Thread: $(i), CPU: $(glibc_coreid())")
end