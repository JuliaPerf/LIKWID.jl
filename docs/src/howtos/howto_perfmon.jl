# # Performance Monitoring
#
# Below we describe how one can use LIKWID.jl to measure the performance of a piece of Julia
# code on a hardware level.

# ## CPU
#
# ### [The `@perfmon` macro](@id perfmon_macro)
# The macro [`@perfmon`](@ref) is the easiest tool to use for **perf**ormance **mon**itoring.
# You need to provide two things:
# 1. the performance group(s) that you're interested in and
# 2. the piece of Julia code to be analyzed.
#
# As for the first, you can use `PerfMon.supported_groups` to get a list of the
# performance groups available on your system. The most common ones, that should also be
# available on most systems, are FLOPS_DP and FLOPS_SP for obtaining information about double-
# and single-precision floating point operations.
#
# As for point 2, pretty much every Julia code is syntactically valid, i.e. you can call a function or
# use, e.g., `begin ... end` to setup monitoring of a block of code. However, it is important to realize
# that, by default, `@perfmon` will only monitor the CPU threads ("cores") associated with
# Julia threads and, for example, does not realiably provide information about computations happening
# on separate BLAS threads. To monitor the latter, one can try to use [the `perfmon` function](@ref perfmon_function) instead.
#
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

# Apart from printing, the monitoring results are provided in form of the nested data structures `metrics` and `events`.
# For example, the FLOPS (floating point operations per second) can be queried as follows,
metrics["FLOPS_DP"][1]["DP [MFLOP/s]"]

# Here, `"FLOPS_DP` is the performance group, `1` indicated the first Julia thread, and `"DP [MFLOP/s]` is a LIKWID metric.

#md # !!! note
#md #     To ensure a reliable monitoring process, `@perfmon` will automatically pin
#md #     the Julia threads to the CPU threads they are currently running on (to avoid migration).

# ### [The `perfmon` function](@id perfmon_function)
#
# If you need more fine-grained control, you should use the [`perfmon`](@ref) function instead of [the `@perfmon` macro](@ref perfmon_macro).
# Among other things, it allows one to
# 1. disable automatic thread-pinning via `autopin=false`,
# 2. manually indicate the CPU threads ("cores") to be monitored through the `cpuids` keyword argument
# 3. suppress printing via `print=false`.

## since we'll have autopin=false, we must manually ensure that computations run on the
## cpu threads / cores that we're monitoring!
LIKWID.pinthreads([0, 1, 2])
metrics, events = perfmon(() -> saxpy!(z, a, x, y), "FLOPS_DP"; cpuids = [0, 1],
                          autopin = false);

# Note that Julia's `do` syntax can often be useful here.
metrics, events = perfmon("FLOPS_DP"; cpuids = [0, 1], autopin = false, print = false) do
    ## code goes here...
    saxpy!(z, a, x, y)
end;

# ## GPU

#md # !!! warning
#md #     Experimental

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
