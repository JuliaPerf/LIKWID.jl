# # Marker API (CPU): Dynamic Usage
#
# !!! warning
#     The dynamic marker API usage is currently still experimental.
#
# This is a demo of how to use the marker API to monitor the performance of a computation (`do_flops` below)
# running on multiple Julia threads using LIKWID from within Julia (i.e. without using `likwid-perfctr ...`).
# You can simply start Julia with `julia -t N`.
#
# ## Preparation
#
# As always, it's absolutely necessary to pin the Julia threads to specific cores.
# Otherwise, the threads might migrate to different cores and our hardware performance
# counter measurements are meaningless. Let's pin the Julia threads to the first `nthreads()` cores.
using LIKWID
using Base.Threads: @threads, nthreads
@assert nthreads() > 1 # hide
LIKWID.pinthreads(0:nthreads()-1)

# Next, one needs to initialize the Marker module in dynamic mode and specify
# the performance group of interest.
Marker.init_dynamic("FLOPS_DP")

# ## Measurement

# Let's consider the following simple function designed to do trivial floating point computations.
function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end

# Let's run the computation and monitor the performance via the marker API, concretely [`@marker`](@ref).
# For good measure, we put everything in a function.
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

# ## Analysis
#
# To query basic information about the region from all threads
# we use [`Marker.getregion`](@ref).
PerfMon.init()
@threads :static for threadid in 1:nthreads()
    nevents, events, time, count = Marker.getregion("calc_flops")
    gid = PerfMon.get_id_of_active_group()
    group_name = PerfMon.get_name_of_group(gid)
    ## print basic info
    println("Thread $(threadid): group $(group_name), $(nevents) events, runtime $(time) s, and call count $(count)")
end;

# The tools from the `LIKWID.PerfMon` module can be used to get more detailed information,
# such as the event and metric results. You can either do this manually, or use the function [`LIKWID.print_results`](@ref).
LIKWID.print_results()
