```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/howtos/howto_marker_dynamic.jl"
```

# Marker API (CPU): Dynamic Usage

!!! warning
    The dynamic marker API usage is currently still experimental.

This is a demo of how to use the marker API to monitor the performance of a computation (`do_flops` below)
running on multiple Julia threads using LIKWID from within Julia (i.e. without using `likwid-perfctr ...`).
You can simply start Julia with `julia -t N`.

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
using LIKWID
using Base.Threads: @threads, nthreads

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
│          ACTUAL_CPU_CLOCK │   3.213e8 │ 3.21238e8 │ 3.21314e8 │
│             MAX_CPU_CLOCK │ 2.23315e8 │ 2.23278e8 │ 2.23329e8 │
│      RETIRED_INSTRUCTIONS │ 3.02219e8 │ 3.23243e8 │ 3.02222e8 │
│       CPU_CLOCKS_UNHALTED │ 3.20743e8 │ 3.19392e8 │ 3.20809e8 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     1.0e8 │     1.0e8 │     1.0e8 │
│                     MERGE │       0.0 │       0.0 │       0.0 │
└───────────────────────────┴───────────┴───────────┴───────────┘
┌──────────────────────┬───────────┬───────────┬───────────┐
│               Metric │  Thread 1 │  Thread 2 │  Thread 3 │
├──────────────────────┼───────────┼───────────┼───────────┤
│  Runtime (RDTSC) [s] │ 0.0911222 │ 0.0911035 │ 0.0911281 │
│ Runtime unhalted [s] │  0.131151 │  0.131126 │  0.131156 │
│          Clock [MHz] │   3524.78 │   3524.68 │   3524.71 │
│                  CPI │   1.06129 │  0.988086 │    1.0615 │
│         DP [MFLOP/s] │   1097.43 │   1097.66 │   1097.36 │
└──────────────────────┴───────────┴───────────┴───────────┘

Region: exponential, Group: FLOPS_DP
┌───────────────────────────┬──────────┬──────────┬──────────┐
│                     Event │ Thread 1 │ Thread 2 │ Thread 3 │
├───────────────────────────┼──────────┼──────────┼──────────┤
│          ACTUAL_CPU_CLOCK │  90372.0 │  88095.0 │  88595.0 │
│             MAX_CPU_CLOCK │  62254.0 │  60687.0 │  61519.0 │
│      RETIRED_INSTRUCTIONS │   6264.0 │   6004.0 │   6377.0 │
│       CPU_CLOCKS_UNHALTED │   7289.0 │   6338.0 │   8291.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     27.0 │     27.0 │     27.0 │
│                     MERGE │      0.0 │      0.0 │      0.0 │
└───────────────────────────┴──────────┴──────────┴──────────┘
┌──────────────────────┬────────────┬────────────┬────────────┐
│               Metric │   Thread 1 │   Thread 2 │   Thread 3 │
├──────────────────────┼────────────┼────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 9.02097e-8 │ 6.00037e-8 │ 2.49811e-7 │
│ Runtime unhalted [s] │ 3.68888e-5 │ 3.59594e-5 │ 3.61635e-5 │
│          Clock [MHz] │    3556.36 │    3556.27 │    3528.09 │
│                  CPI │    1.16363 │    1.05563 │    1.30014 │
│         DP [MFLOP/s] │    299.303 │    449.972 │    108.082 │
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
│          ACTUAL_CPU_CLOCK │  96922.0 │
│             MAX_CPU_CLOCK │  66444.0 │
│      RETIRED_INSTRUCTIONS │   5927.0 │
│       CPU_CLOCKS_UNHALTED │   6822.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     10.0 │
│                     MERGE │      0.0 │
└───────────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │  3.0206e-8 │
│ Runtime unhalted [s] │ 3.95624e-5 │
│          Clock [MHz] │     3573.6 │
│                  CPI │      1.151 │
│         DP [MFLOP/s] │    331.061 │
└──────────────────────┴────────────┘

Region: exponential, Group: CPI
┌──────────────────────┬──────────┐
│                Event │ Thread 1 │
├──────────────────────┼──────────┤
│     ACTUAL_CPU_CLOCK │  49747.0 │
│        MAX_CPU_CLOCK │  34300.0 │
│ RETIRED_INSTRUCTIONS │   5695.0 │
│  CPU_CLOCKS_UNHALTED │   4607.0 │
│         RETIRED_UOPS │   6598.0 │
└──────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 2.00012e-8 │
│ Runtime unhalted [s] │ 1.88052e-6 │
│          Clock [MHz] │    3553.14 │
│                  CPI │   0.808955 │
│  CPI (based on uops) │   0.698242 │
│                  IPC │    1.23616 │
└──────────────────────┴────────────┘

````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

