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
│          ACTUAL_CPU_CLOCK │ 594353.0 │ 172690.0 │ 219724.0 │
│             MAX_CPU_CLOCK │ 398790.0 │ 225764.0 │ 143752.0 │
│      RETIRED_INSTRUCTIONS │  67624.0 │  80827.0 │  85597.0 │
│       CPU_CLOCKS_UNHALTED │ 161793.0 │  63454.0 │  71502.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │   6668.0 │   6666.0 │   6666.0 │
│                     MERGE │      0.0 │      0.0 │      0.0 │
└───────────────────────────┴──────────┴──────────┴──────────┘
┌──────────────────────┬─────────────┬────────────┬────────────┐
│               Metric │    Thread 1 │   Thread 2 │   Thread 3 │
├──────────────────────┼─────────────┼────────────┼────────────┤
│  Runtime (RDTSC) [s] │  5.23601e-5 │ 5.23601e-5 │ 5.23601e-5 │
│ Runtime unhalted [s] │ 0.000264663 │ 7.68981e-5 │ 9.78422e-5 │
│          Clock [MHz] │     3346.97 │    1717.77 │    3432.53 │
│                  CPI │     2.39254 │   0.785059 │   0.835333 │
│         DP [MFLOP/s] │     127.349 │    127.311 │    127.311 │
└──────────────────────┴─────────────┴────────────┴────────────┘

````

Apart from printing, the monitoring results are provided in form of the nested data structures `metrics` and `events`.
For example, the FLOPS (floating point operations per second) can be queried as follows,

````julia
metrics["FLOPS_DP"][1]["DP [MFLOP/s]"]
````

````
127.34884328126886
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
│          ACTUAL_CPU_CLOCK │ 805504.0 │ 677456.0 │
│             MAX_CPU_CLOCK │ 548820.0 │ 451058.0 │
│      RETIRED_INSTRUCTIONS │  64537.0 │ 103995.0 │
│       CPU_CLOCKS_UNHALTED │ 181393.0 │ 120942.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │   6668.0 │   6666.0 │
│                     MERGE │      0.0 │      0.0 │
└───────────────────────────┴──────────┴──────────┘
┌──────────────────────┬─────────────┬─────────────┐
│               Metric │    Thread 1 │    Thread 2 │
├──────────────────────┼─────────────┼─────────────┤
│  Runtime (RDTSC) [s] │ 0.000189612 │ 0.000189612 │
│ Runtime unhalted [s] │ 0.000358688 │ 0.000301668 │
│          Clock [MHz] │     3296.01 │     3372.87 │
│                  CPI │     2.81068 │     1.16296 │
│         DP [MFLOP/s] │     35.1665 │     35.1559 │
└──────────────────────┴─────────────┴─────────────┘

````

Note that Julia's `do` syntax can often be useful here.

````julia
metrics, events = perfmon("FLOPS_DP"; cpuids=[0,1], autopin=false, print=false) do
    # code goes here...
    saxpy!(z, a, x, y)
end;
````

## GPU

!!! warning
    Experimental

````julia
using LIKWID
using CUDA

N = 10_000
a = 3.141f0 # Float32
x = CUDA.rand(Float32, N)
y = CUDA.rand(Float32, N)
z = CUDA.zeros(Float32, N)

saxpy!(z, a, x, y) = z .= a .* x .+ y
saxpy!(z, a, x, y); # warmup

metrics, events = @nvmon "FLOPS_SP" saxpy!(z, a, x, y);
````

````

Group: FLOPS_SP
┌────────────────────────────────────────────────────┬─────────┐
│                                              Event │   GPU 1 │
├────────────────────────────────────────────────────┼─────────┤
│ SMSP_SASS_THREAD_INST_EXECUTED_OP_FADD_PRED_ON_SUM │     0.0 │
│ SMSP_SASS_THREAD_INST_EXECUTED_OP_FMUL_PRED_ON_SUM │     0.0 │
│ SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM │ 10000.0 │
└────────────────────────────────────────────────────┴─────────┘
┌─────────────────────┬────────────┐
│              Metric │      GPU 1 │
├─────────────────────┼────────────┤
│ Runtime (RDTSC) [s] │ 1.84467e10 │
│        SP [MFLOP/s] │ 1.0842e-12 │
└─────────────────────┴────────────┘

````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

