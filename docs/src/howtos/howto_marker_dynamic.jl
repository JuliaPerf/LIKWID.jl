# # Marker API (CPU): Dynamic Usage
#
# This is a demo of how to use the marker API to monitor the performance of a computation (`do_flops` below)
# running on multiple Julia threads using LIKWID from within Julia (i.e. without using `likwid-perfctr ...`).
# You can simply start Julia with `julia -t N`.
#
# ## Setting up
#
# ### Pinning the Julia threads
#
# It's absolutely necessary to pin the Julia threads to specific cores.
# Otherwise, the threads might migrate to different cores and our hardware performance
# counter measurements are meaningless.
#
# Let's pin the Julia threads to the first `nthreads()` cores.
using LIKWID
using Base.Threads: @threads, nthreads
@assert nthreads() > 1 # hide
LIKWID.pinthreads(0:nthreads()-1)

# ### Environment variables

# We use the `LIKWID.LIKWID_*` functions to set environment variables to configure LIKWID for our
# monitoring.
## use the following threads
cpustr = join(0:nthreads()-1, ",")
LIKWID.LIKWID_THREADS(cpustr)
## the location the marker file will be stored
LIKWID.LIKWID_FILEPATH(joinpath(@__DIR__, "likwid_marker.out"))
## Use the access daemon
LIKWID.LIKWID_MODE(1)
## Overwrite registers (if they are in use)
LIKWID.LIKWID_FORCE(true)
## Debug level
LIKWID.LIKWID_DEBUG(0)
## Events to measure
LIKWID.LIKWID_EVENTS("FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0");

# ### Initialize LIKWID modules
using LIKWID: PerfMon
Marker.init_nothreads()
PerfMon.init()

# ## Measurement

## simple function designed to do floating point computations
function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end

# Let's run the computation and monitor the performance. For good measure,
# we put everything in a function.
function monitor_do_flops(NUM_FLOPS = 100_000_000)
    a = 1.8
    b = 3.2
    c = 1.0
    @threads :static for tid in 1:nthreads()
        ## Notice that only the first group specified, `FLOPS_DP`, will be measured.
        ## See further below for how to measure multiple groups.
        @marker "calc_flops" c = do_flops(c, a, b, NUM_FLOPS)
    end
    return nothing
end
monitor_do_flops()

# ## Analysis
#
# To query basic information about the region from all threads
# we use [`Marker.getregion`](@ref).
@threads :static for threadid in 1:nthreads()
    nevents, events, time, count = Marker.getregion("calc_flops")
    gid = PerfMon.get_id_of_active_group()
    group_name = PerfMon.get_name_of_group(gid)
    ## print basic info
    println("Thread $(threadid): group $(group_name), $(nevents) events, runtime $(time) s, and call count $(count)")
end;

# The tools from the `LIKWID.PerfMon` module can be used to get more detailed information,
# such as the event and metric results.
using PrettyTables
using Printf
_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

## extract event and metric results
gid = PerfMon.get_id_of_active_group()
nevents = PerfMon.get_number_of_events(gid)
nmetrics = PerfMon.get_number_of_metrics(gid)
events = Matrix(undef, nevents, nthreads() + 1)
metrics = Matrix(undef, nmetrics, nthreads() + 1)

for tid in 1:nthreads()
    for eid in 1:nevents
        events[eid, 1] = PerfMon.get_name_of_event(gid, eid)
        events[eid, tid+1] = _zeroifnothing(PerfMon.get_result(gid, eid, tid))
    end
    for mid in 1:nmetrics
        metrics[mid, 1] = PerfMon.get_name_of_metric(gid, mid)
        metrics[mid, tid+1] = _zeroifnothing(PerfMon.get_metric(gid, mid, tid))
    end
end

## printing
theader = ["Thread $(i)" for i in 1:nthreads()]
pretty_table(events; header = vcat(["Event"], theader))
pretty_table(metrics; header = vcat(["Metric"], theader))
