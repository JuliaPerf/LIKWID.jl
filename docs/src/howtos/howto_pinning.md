```@meta
EditURL = "<unknown>/howto_pinning.jl"
```

# How to pin Julia threads

Below, we demonstrate how to use LIKWID.jl to pin
Julia threads to specific cores. However, before we do that, let us note two things.

!!! note
    Instead of LIKWID's pinning features, we generally strongly recommend
    to use [ThreadPinning.jl](https://github.com/carstenbauer.eu/ThreadPinning.jl)
    to pin Julia threads to cores, as it provides many more options and visualizations!

!!! note
    Note that Julia implements task-based multithreading where `N`
    tasks get mapped onto `M` OS threads (M:N hybrid threading).
    We will pin the Julia (p)threads and not the tasks.
    Depending on how the latter are started/configured, tasks may
    migrate between Julia threads!

## Dynamic pinning

First, make sure to start Julia in multithreaded mode, i.e. `julia -t N`
where `N` is the desired number of Julia threads (below I'll use `N=10`).

````julia
N = Threads.nthreads()
````

````
10
````

Let's find out on which cores the Julia threads are currently running (before we've pinned them).
We will use [`LIKWID.get_processor_id`](@ref) in combination with
`Threads.@threads :static for`, which guarantees that the *tasks* associated with different instances of the loop body
get executed on different Julia threads (ThreadPinning.jl provides `@tspawnat` as a nice(r) alternative).

````julia
using LIKWID
coreids = zeros(Int, N)
Threads.@threads :static for i in 1:N
    coreids[i] = LIKWID.get_processor_id()
end
println("Cores: ", coreids)
````

````
Cores: [99, 109, 100, 111, 101, 104, 110, 102, 96, 108]

````

Since querying all core ids is a common operation, we provide [`LIKWID.get_processor_ids`](@ref) which returns all core ids right away.

````julia
println("Cores: ", LIKWID.get_processor_ids())
````

````
Cores: [99, 109, 100, 111, 101, 104, 110, 102, 96, 108]

````

To pin a thread to a specific core, there is [`LIKWID.pinthread`](@ref).
Using `Threads.@threads :static for` like above, we can, for example, pin the `N` Julia threads to the first `N` cores.

````julia
cores_firstN = 0:N-1
Threads.@threads :static for i in 1:N
    LIKWID.pinthread(cores_firstN[i])
end
println("Cores: ", LIKWID.get_processor_ids())
````

````
Cores: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

````

To avoid the explicit for-loop, we can directly use [`LIKWID.pinthreads`](@ref) to pin all Julia threads.
Let's realize a less trivial shuffled mapping.

````julia
using Random
cores_firstN_shuffeled = shuffle(cores_firstN)
LIKWID.pinthreads(cores_firstN_shuffeled)
println("Cores: ", LIKWID.get_processor_ids())
LIKWID.get_processor_ids() == cores_firstN_shuffeled
````

````
true
````

## likwid-pin

Command-line interface tool for pinning (p)threads. For details, check out the [official documentation](https://github.com/RRZE-HPC/likwid/wiki/Likwid-Pin).

### Important: Mask

(See [this discussion](https://discourse.julialang.org/t/thread-affinitization-pinning-julia-threads-to-cores/58069/7) on the Julia discourse.)

In general, `likwid-pin` pins all [pthreads](https://en.wikipedia.org/wiki/Pthreads). However, `julia` involves more than the "Julia user threads" specified via the `-t` option. For example, it create an additional unix signal thread (in [`src/signals-unix.c`](https://github.com/JuliaLang/julia/blob/master/src/signals-unix.c#L861)) and - unless `OPENBLAS_NUM_THREADS=1` - the OpenBLAS related threads (`blas_thread_init ()` in `[..]/lib/julia/libopenblas64_.so`). Hence, when you run `likwid-pin -c 0-3 julia -t 4` the four cores (0-3) are actually oversubscribed and multiple "Julia user threads" get pinned to the same core.

To work around this, we need to provide a mask to `likwid-pin` via the `-s` option. To compute an appropriate mask for `N` "Julia user threads" you may use the helper function `LIKWID.pinmask(N)`:

````julia
LIKWID.pinmask(4)
````

````
"0xffffffffffffffe1"
````

### Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/cli/likwid-pin/](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/cli/likwid-pin/).)

```julia
# pin.jl
using Base.Threads

glibc_coreid() = @ccall sched_getcpu()::Cint

@threads :static for i in 1:nthreads()
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

If you're wondering about the `-s 0xffffffffffffffe1` option, see [Mask](@ref) above.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

