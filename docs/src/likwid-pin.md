```@setup likwid
using LIKWID
```

# likwid-pin

Pinning threads to cores. For details, check out the [official documentation](https://github.com/RRZE-HPC/likwid/wiki/Likwid-Pin).

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/pin](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/pin).)

```julia
# pin.jl
using Base.Threads

glibc_coreid() = @ccall sched_getcpu()::Cint

@threads for i in 1:nthreads()
    println("Thread: $(i), CPU: $(glibc_coreid())")
end
```

Running this file with e.g. `likwid-pin -s 0xffffffffffffffe1 -c 1,3,5,7 julia -t 4 pin.jl` one obtains
```
[pthread wrapper] 
[pthread wrapper] MAIN -> 1
[pthread wrapper] PIN_MASK: 0->3  1->5  2->7  
[pthread wrapper] SKIP MASK: 0xFFFFFFFFFFFFFFE1
	threadid 140576878921280 -> SKIP 
	threadid 140576612378176 -> hwthread 3 - OK
	threadid 140576590759488 -> hwthread 5 - OK
	threadid 140576494188096 -> hwthread 7 - OK
Thread: 1, CPU: 1
Thread: 2, CPU: 3
Thread: 3, CPU: 5
Thread: 4, CPU: 7
```

If you're wondering about the `-s 0xffffffffffffffe1` option, see [Mask](@ref) below.

## Mask

(See [this discussion](https://discourse.julialang.org/t/thread-affinitization-pinning-julia-threads-to-cores/58069/7) on the Julia discourse.)

In general, `likwid-pin` pins all pthread-threads. However, `julia` involves more than the "Julia user threads" specified via the `-t` option. For example, it create an additional unix signal thread (in [`src/signals-unix.c`](https://github.com/JuliaLang/julia/blob/master/src/signals-unix.c#L861)) and - unless `OPENBLAS_NUM_THREADS=1` - the OpenBLAS related threads (`blas_thread_init ()` in `[..]/lib/julia/libopenblas64_.so`). Hence, when you run `likwid-pin -c 0-3 julia -t 4` the four cores (0-3) are actually oversubscribed and multiple "Julia user threads" get pinned to the same core.

To work around this, we need to provide a mask to `likwid-pin` via the `-s` option. To compute an appropriate mask for `N` "Julia user threads" you may use the helper function `LIKWID.pin_mask(N)`:

```@repl likwid
LIKWID.pin_mask(4)
```