```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/examples/dynamic_pinning.jl"
```

# Pinning Julia Threads

In the following, we demonstrate how to use LIKWID.jl to pin
Julia threads to specific cores.

!!! note
    Note that Julia implements task-based multithreading where `N`
    tasks get mapped onto `M` OS threads (M:N hybrid threading).
    We will pin the Julia (p)threads and not the tasks.
    Depending on how the latter are started/configured, tasks may
    migrate between Julia threads!

First, we load the packages and standard libraries that we'll use.

````julia
using LIKWID
using Base.Threads: nthreads, @threads
using Test, Random
````

Note that I have started julia with multiple threads (`julia -t NT`), concretely

````julia
NT = nthreads()
````

````
12
````

Let's find out on which cores are running our Julia threads.
We will use [`LIKWID.get_processor_id`](@ref) in combination with
`@threads :static for`, which guarantees that the associated tasks
are themselves pinned to Julia threads.

````julia
coreids = zeros(Int, NT)
@threads :static for i in 1:NT
    coreids[i] = LIKWID.get_processor_id()
end
println("Cores: ", coreids)
````

````
Cores: [32, 35, 34, 37, 38, 20, 39, 21, 22, 31, 33, 36]

````

Since querying all core ids is a common operation, we provide [`LIKWID.get_processor_ids`](@ref) which returns all core ids right away.

To pin a thread to a specific core, there is [`LIKWID.pinthread`](@ref). Using `@threads :static for` like above, we can, for example, pin the `NT` Julia threads to the first `NT` cores:

````julia
# core numbering starts with zero
cores_firstNT = 0:NT-1
@threads :static for i in 1:NT
    LIKWID.pinthread(cores_firstNT[i])
end
@test LIKWID.get_processor_ids() == cores_firstNT
````

````
Test Passed
  Expression: LIKWID.get_processor_ids() == cores_firstNT
   Evaluated: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] == 0:11
````

To avoid the explicit for-loop, we can directly use [`LIKWID.pinthreads`](@ref) to pin all Julia threads.

Let's try a less trivial shuffled mapping

````julia
cores_firstNT_shuffeled = shuffle(cores_firstNT)
LIKWID.pinthreads(cores_firstNT_shuffeled)
@test LIKWID.get_processor_ids() == cores_firstNT_shuffeled
````

````
Test Passed
  Expression: LIKWID.get_processor_ids() == cores_firstNT_shuffeled
   Evaluated: [7, 2, 3, 6, 10, 9, 5, 4, 0, 8, 11, 1] == [7, 2, 3, 6, 10, 9, 5, 4, 0, 8, 11, 1]
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

