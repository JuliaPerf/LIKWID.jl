```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/howtos/howto_marker_dynamic.jl"
```

# Marker API (CPU): Dynamic Usage

!!! warning
    The dynamic marker API usage is currently still experimental.

This is a demo of how to use the marker API to monitor the performance of a computation (`do_flops` below)
running on multiple Julia threads using LIKWID from within Julia (i.e. without using `likwid-perfctr ...`).
You can simply start Julia with `julia -t N`.

## Preparation

As always, it's absolutely necessary to pin the Julia threads to specific cores.
Otherwise, the threads might migrate to different cores and our hardware performance
counter measurements are meaningless. Let's pin the Julia threads to the first `nthreads()` cores.

````julia
using LIKWID
using Base.Threads: @threads, nthreads
@assert nthreads() > 1 # hide
LIKWID.pinthreads(0:nthreads()-1)
````

Next, one needs to initialize the Marker module in dynamic mode and specify
the performance group of interest.

````julia
Marker.init_dynamic("FLOPS_DP")
````

## Measurement

Let's consider the following simple function designed to do trivial floating point computations.

````julia
function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end
````

````
do_flops (generic function with 1 method)
````

Let's run the computation and monitor the performance via the marker API, concretely [`@marker`](@ref).
For good measure, we put everything in a function.

````julia
function monitor_do_flops(NUM_FLOPS=100_000_000)
    a = 1.8
    b = 3.2
    c = 1.0
    @threads :static for tid in 1:nthreads()
        @marker "calc_flops" c = do_flops(c, a, b, NUM_FLOPS)
    end
    return nothing
end

monitor_do_flops()
````

## Analysis

To query basic information about the region from all threads
we use [`Marker.getregion`](@ref).

````julia
PerfMon.init()
@threads :static for threadid in 1:nthreads()
    nevents, events, time, count = Marker.getregion("calc_flops")
    gid = PerfMon.get_id_of_active_group()
    group_name = PerfMon.get_name_of_group(gid)
    # print basic info
    println("Thread $(threadid): group $(group_name), $(nevents) events, runtime $(time) s, and call count $(count)")
end;
````

````
Thread 1: group FLOPS_DP, 6 events, runtime 0.09114440672457015 s, and call count 1
Thread 2: group FLOPS_DP, 6 events, runtime 0.09110641678869748 s, and call count 1
Thread 3: group FLOPS_DP, 6 events, runtime 0.09111558692803792 s, and call count 1

````

The tools from the `LIKWID.PerfMon` module can be used to get more detailed information,
such as the event and metric results. You can either do this manually, or use the function [`LIKWID.print_results`](@ref).

````julia
LIKWID.print_results()
````

````

Group: FLOPS_DP
┌───────────────────────────┬───────────┬───────────┬───────────┐
│                     Event │  Thread 1 │  Thread 2 │  Thread 3 │
├───────────────────────────┼───────────┼───────────┼───────────┤
│          ACTUAL_CPU_CLOCK │ 7.88109e8 │ 4.33469e8 │ 4.33703e8 │
│             MAX_CPU_CLOCK │ 5.48078e8 │ 3.02606e8 │ 3.02134e8 │
│      RETIRED_INSTRUCTIONS │ 9.71598e8 │    3.35e8 │ 3.14027e8 │
│       CPU_CLOCKS_UNHALTED │ 7.82487e8 │ 4.30675e8 │  4.3277e8 │
│ RETIRED_SSE_AVX_FLOPS_ALL │ 1.00019e8 │     1.0e8 │     1.0e8 │
│                     MERGE │       0.0 │       0.0 │       0.0 │
└───────────────────────────┴───────────┴───────────┴───────────┘
┌──────────────────────┬──────────┬──────────┬──────────┐
│               Metric │ Thread 1 │ Thread 2 │ Thread 3 │
├──────────────────────┼──────────┼──────────┼──────────┤
│  Runtime (RDTSC) [s] │ 0.581184 │ 0.581184 │ 0.581184 │
│ Runtime unhalted [s] │ 0.321675 │ 0.176925 │  0.17702 │
│          Clock [MHz] │  3523.01 │  3509.54 │  3516.92 │
│                  CPI │  0.80536 │   1.2856 │  1.37813 │
│         DP [MFLOP/s] │  172.094 │  172.063 │  172.063 │
└──────────────────────┴──────────┴──────────┴──────────┘

````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

