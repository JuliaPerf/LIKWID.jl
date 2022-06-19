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

## Measurement

We consider the following simple function designed to do trivial floating point computations.

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

Let's run a computation and monitor the performance via the marker API, concretely [`@perfmon_marker`](@ref) and [`@marker`](@ref).

````julia
@perfmon_marker "FLOPS_DP" begin
    NUM_FLOPS = 100_000_000
    a = 1.8
    b = 3.2
    c = 1.0
    @threads :static for tid in 1:nthreads()
        @marker "calc_flops" c = do_flops(c, a, b, NUM_FLOPS)
        sin(b) # not monitored
        @marker "exponential" exp(a)
    end
end
````

````

Region: calc_flops, Group: FLOPS_DP
┌───────────────────────────┬───────────┬───────────┬───────────┐
│                     Event │  Thread 1 │  Thread 2 │  Thread 3 │
├───────────────────────────┼───────────┼───────────┼───────────┤
│          ACTUAL_CPU_CLOCK │ 3.21635e8 │ 3.21602e8 │ 3.21575e8 │
│             MAX_CPU_CLOCK │ 2.23556e8 │ 2.23551e8 │ 2.23515e8 │
│      RETIRED_INSTRUCTIONS │ 3.02249e8 │ 3.23256e8 │ 3.02244e8 │
│       CPU_CLOCKS_UNHALTED │ 3.21056e8 │ 3.19609e8 │ 3.20995e8 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     1.0e8 │     1.0e8 │     1.0e8 │
│                     MERGE │       0.0 │       0.0 │       0.0 │
└───────────────────────────┴───────────┴───────────┴───────────┘
┌──────────────────────┬───────────┬───────────┬───────────┐
│               Metric │  Thread 1 │  Thread 2 │  Thread 3 │
├──────────────────────┼───────────┼───────────┼───────────┤
│  Runtime (RDTSC) [s] │ 0.0912224 │ 0.0912163 │ 0.0912013 │
│ Runtime unhalted [s] │   0.13129 │  0.131277 │  0.131265 │
│          Clock [MHz] │   3524.59 │   3524.32 │   3524.58 │
│                  CPI │   1.06222 │  0.988716 │   1.06204 │
│         DP [MFLOP/s] │   1096.22 │    1096.3 │   1096.48 │
└──────────────────────┴───────────┴───────────┴───────────┘

Region: exponential, Group: FLOPS_DP
┌───────────────────────────┬──────────┬──────────┬──────────┐
│                     Event │ Thread 1 │ Thread 2 │ Thread 3 │
├───────────────────────────┼──────────┼──────────┼──────────┤
│          ACTUAL_CPU_CLOCK │  86015.0 │  87389.0 │  84186.0 │
│             MAX_CPU_CLOCK │  59364.0 │  60197.0 │  58261.0 │
│      RETIRED_INSTRUCTIONS │   4262.0 │   3980.0 │   4014.0 │
│       CPU_CLOCKS_UNHALTED │   5320.0 │   4610.0 │   4571.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     27.0 │     27.0 │     27.0 │
│                     MERGE │      0.0 │      0.0 │      0.0 │
└───────────────────────────┴──────────┴──────────┴──────────┘
┌──────────────────────┬────────────┬────────────┬────────────┐
│               Metric │   Thread 1 │   Thread 2 │   Thread 3 │
├──────────────────────┼────────────┼────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 6.00047e-8 │ 6.00047e-8 │ 6.00047e-8 │
│ Runtime unhalted [s] │ 3.51109e-5 │ 3.56718e-5 │ 3.43643e-5 │
│          Clock [MHz] │    3549.63 │    3556.43 │    3539.92 │
│                  CPI │    1.24824 │    1.15829 │    1.13876 │
│         DP [MFLOP/s] │    449.965 │    449.965 │    449.965 │
└──────────────────────┴────────────┴────────────┴────────────┘

````

Multiple groups are supported as well.

````julia
@perfmon_marker ["FLOPS_DP", "CPI"] begin
        @marker "exponential" exp(3.141)
end
````

````

Region: exponential, Group: FLOPS_DP
┌───────────────────────────┬──────────┐
│                     Event │ Thread 1 │
├───────────────────────────┼──────────┤
│          ACTUAL_CPU_CLOCK │  96747.0 │
│             MAX_CPU_CLOCK │  66518.0 │
│      RETIRED_INSTRUCTIONS │   4198.0 │
│       CPU_CLOCKS_UNHALTED │   7550.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     10.0 │
│                     MERGE │      0.0 │
└───────────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 2.00016e-8 │
│ Runtime unhalted [s] │ 3.94917e-5 │
│          Clock [MHz] │    3563.12 │
│                  CPI │    1.79848 │
│         DP [MFLOP/s] │    499.961 │
└──────────────────────┴────────────┘

Region: exponential, Group: CPI
┌──────────────────────┬──────────┐
│                Event │ Thread 1 │
├──────────────────────┼──────────┤
│     ACTUAL_CPU_CLOCK │  51461.0 │
│        MAX_CPU_CLOCK │  35207.0 │
│ RETIRED_INSTRUCTIONS │   3667.0 │
│  CPU_CLOCKS_UNHALTED │   4703.0 │
│         RETIRED_UOPS │   4755.0 │
└──────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 3.02065e-8 │
│ Runtime unhalted [s] │ 1.91974e-6 │
│          Clock [MHz] │    3580.81 │
│                  CPI │    1.28252 │
│  CPI (based on uops) │   0.989064 │
│                  IPC │   0.779715 │
└──────────────────────┴────────────┘

````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

