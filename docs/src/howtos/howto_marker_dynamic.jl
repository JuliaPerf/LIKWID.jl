# # Marker API (CPU): Dynamic Usage
#
# !!! warning
#     The dynamic marker API usage is currently still experimental.
#
# This is a demo of how to use the marker API to monitor the performance of a computation (`do_flops` below)
# running on multiple Julia threads using LIKWID from within Julia (i.e. without using `likwid-perfctr ...`).
# You can simply start Julia with `julia -t N`.
#
# ## Measurement

# We consider the following simple function designed to do trivial floating point computations.
function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end

# Let's run a computation and monitor the performance via the marker API, concretely [`@perfmon_marker`](@ref) and [`@marker`](@ref).
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

# Multiple groups are supported as well.
@perfmon_marker ["FLOPS_DP", "CPI"] begin
        @marker "exponential" exp(3.141)
end
