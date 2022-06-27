```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/howtos/howto_perfmon.jl"
```

# Performance Monitoring

Below we describe how one can use LIKWID.jl to measure the performance of a piece of Julia
code on a hardware level.

## CPU

### [The `@perfmon` macro](@id perfmon_macro)
The macro [`@perfmon`](@ref) is the easiest tool to use for **perf**ormance **mon**itoring.
You need to provide two things:
1. the performance group(s) that you're interested in and
2. the piece of Julia code to be analyzed.

As for the first, you can use `PerfMon.supported_groups` to get a list of the
performance groups available on your system. The most common ones, that should also be
available on most systems, are FLOPS_DP and FLOPS_SP for obtaining information about double-
and single-precision floating point operations.

As for point 2, pretty much every Julia code is syntactically valid, i.e. you can call a function or
use, e.g., `begin ... end` to setup monitoring of a block of code. However, it is important to realize
that, by default, `@perfmon` will only monitor the CPU threads ("cores") associated with
Julia threads and, for example, does not realiably provide information about computations happening
on separate BLAS threads. To monitor the latter, one can try to use [the `perfmon` function](@ref perfmon_function) instead.

````julia
using LIKWID
using Base.Threads

N = 10_000
a = 3.141
x = rand(N)
y = rand(N)
z = zeros(N)

function saxpy!(z, a, x, y)
    @threads :static for i in eachindex(z)
        z[i] = a * x[i] + y[i]
    end
    return z
end
saxpy!(z, a, x, y); # warmup

metrics, events = @perfmon "FLOPS_DP" saxpy!(z, a, x, y);
````

````

Group: FLOPS_DP
┌───────────────────────────┬──────────┬──────────┬──────────┐
│                     Event │ Thread 1 │ Thread 2 │ Thread 3 │
├───────────────────────────┼──────────┼──────────┼──────────┤
│          ACTUAL_CPU_CLOCK │ 687714.0 │ 184029.0 │ 204089.0 │
│             MAX_CPU_CLOCK │ 480077.0 │ 236107.0 │ 167067.0 │
│      RETIRED_INSTRUCTIONS │ 135713.0 │ 101920.0 │ 108457.0 │
│       CPU_CLOCKS_UNHALTED │ 133810.0 │  65675.0 │  70501.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │   6668.0 │   6666.0 │   6666.0 │
│                     MERGE │      0.0 │      0.0 │      0.0 │
└───────────────────────────┴──────────┴──────────┴──────────┘
┌──────────────────────┬─────────────┬────────────┬────────────┐
│               Metric │    Thread 1 │   Thread 2 │   Thread 3 │
├──────────────────────┼─────────────┼────────────┼────────────┤
│  Runtime (RDTSC) [s] │  4.66796e-5 │ 4.66796e-5 │ 4.66796e-5 │
│ Runtime unhalted [s] │ 0.000280697 │ 7.51132e-5 │ 8.33009e-5 │
│          Clock [MHz] │     3509.68 │    1909.62 │    2992.95 │
│                  CPI │    0.985978 │   0.644378 │   0.650036 │
│         DP [MFLOP/s] │     142.846 │    142.803 │    142.803 │
└──────────────────────┴─────────────┴────────────┴────────────┘

````

Apart from printing, the monitoring results are provided in form of the nested data structures `metrics` and `events`.
For example, the FLOPS (floating point operations per second) can be queried as follows,

````julia
metrics["FLOPS_DP"][1]["DP [MFLOP/s]"]
````

````
142.84618968452162
````

Here, `"FLOPS_DP` is the performance group, `1` indicated the first Julia thread, and `"DP [MFLOP/s]` is a LIKWID metric.

!!! note
    To ensure a reliable monitoring process, `@perfmon` will automatically pin
    the Julia threads to the CPU threads they are currently running on (to avoid migration).

### [The `perfmon` function](@id perfmon_function)

If you need more fine-grained control, you should use the [`perfmon`](@ref) function instead of [the `@perfmon` macro](@ref perfmon_macro).
Among other things, it allows one to
1. disable automatic thread-pinning via `autopin=false`,
2. manually indicate the CPU threads ("cores") to be monitored through the `cpuids` keyword argument
3. suppress printing via `print=false`.

````julia
# since we'll have autopin=false, we must manually ensure that computations run on the
# cpu threads / cores that we're monitoring!
LIKWID.pinthreads([0,1,2])
metrics, events = perfmon(() -> saxpy!(z, a, x, y), "FLOPS_DP"; cpuids=[0,1], autopin=false);
````

````

Group: FLOPS_DP
┌───────────────────────────┬──────────┬──────────┐
│                     Event │ Thread 1 │ Thread 2 │
├───────────────────────────┼──────────┼──────────┤
│          ACTUAL_CPU_CLOCK │ 388430.0 │ 207768.0 │
│             MAX_CPU_CLOCK │ 270063.0 │ 170692.0 │
│      RETIRED_INSTRUCTIONS │ 116777.0 │ 115387.0 │
│       CPU_CLOCKS_UNHALTED │ 129366.0 │  80826.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │   6668.0 │   6666.0 │
│                     MERGE │      0.0 │      0.0 │
└───────────────────────────┴──────────┴──────────┘
┌──────────────────────┬─────────────┬────────────┐
│               Metric │    Thread 1 │   Thread 2 │
├──────────────────────┼─────────────┼────────────┤
│  Runtime (RDTSC) [s] │  4.45796e-5 │ 4.45796e-5 │
│ Runtime unhalted [s] │ 0.000158541 │ 8.48025e-5 │
│          Clock [MHz] │     3523.85 │    2982.19 │
│                  CPI │      1.1078 │   0.700478 │
│         DP [MFLOP/s] │     149.575 │     149.53 │
└──────────────────────┴─────────────┴────────────┘

````

Note that Julia's `do` syntax can often be useful here.

````julia
metrics, events = perfmon("FLOPS_DP"; cpuids=[0,1], autopin=false, print=false) do
    # code goes here...
    saxpy!(z, a, x, y)
end;
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

