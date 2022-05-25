using Base.Threads

glibc_coreid() = @ccall sched_getcpu()::Cint

@threads :static for i in 1:nthreads()
    println("Thread: $(i), CPU: $(glibc_coreid())")
end