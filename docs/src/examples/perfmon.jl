# # Monitoring performance
#
# ## Setting up
#
# ### Pinning the Julia threads
#
# It's absolutely necessary to pin the Julia threads to specific cores.
# Otherwise, the threads might migrate to different cores and our hardware performance
# counter measurements are meaningless.

## we'll consider the first `NUM_THREADS` Julia threads
using Threads: @threads, nthreads
const NUM_THREADS = 3;

@assert NUM_THREADS ≤ nthreads() #src

# Let's pin the first `NUM_THREADS` threads to the first `NUM_THREADS` cores.
using LIKWID
cores = 0:NUM_THREADS-1
@threads for tid in 1:NUM_THREADS
    LIKWID.pinthread(cores[tid])
end

# To check that the pinning was successfull, we call [`LIKWID.get_processor_id`](@ref) on each thread.
@threads for tid in 1:NUM_THREADS
    core = LIKWID.get_processor_id()
    println("Thread $tid, Core $core")
end

# ### Environment variables

# We use the `LIKWID.LIKWID_*` functions to set environment variables to configure LIKWID for our
# monitoring.
## use the following threads
cpustr = join(collect(0:NUM_THREADS-1), ",")
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

# First we register the marker region. While this is not required
# it is strongly recommended as it reduces overhead of `Marker.startregion`
# and prevents wrong counts in short regions.
#
# Note that there must be a barrier between registering a region and starting that
# region. Typically these are done in separate parallel blocks, relying on
# the implicit barrier at the end of the parallel block. Usually there is
# a parallel block for initialization and a parallel block for execution.
@threads for tid in 1:NUM_THREADS
    Marker.registerregion("Total")
    Marker.registerregion("calc_flops")

    ## To demonstrate that registering regions is optional, we do not register
    ## the "copy" region, which we'll use later.
end;

# Let's get to the actual performance monitoring.
# We will measure a single region, get the results
# and reset the region so that these results
# do not affect (potential) later measurements.
#
# But first, we'll need to define the computation
# that we want to analyze.
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
    @threads for tid in 1:NUM_THREADS
        ## Notice that only the first group specified, `FLOPS_DP`, will be measured.
        ## See further below for how to measure multiple groups.
        Marker.startregion("calc_flops")
        c = do_flops(c, a, b, NUM_FLOPS)
        Marker.stopregion("calc_flops")
    end
    return nothing
end
monitor_do_flops()

# ## Analysis
#
# To query basic information about the region from all threads
# we use [`Marker.getregion`](@ref).
@threads for threadid in 1:NUM_THREADS
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
events = Matrix(undef, nevents, NUM_THREADS + 1)
metrics = Matrix(undef, nmetrics, NUM_THREADS + 1)

for tid in 0:NUM_THREADS-1
    for eid in 0:nevents-1
        events[eid+1, 1] = PerfMon.get_name_of_event(gid, eid)
        events[eid+1, tid+2] = _zeroifnothing(PerfMon.get_result(gid, eid, tid))
    end
    for mid in 0:nmetrics-1
        metrics[mid+1, 1] = PerfMon.get_name_of_metric(gid, mid)
        metrics[mid+1, tid+2] = _zeroifnothing(PerfMon.get_metric(gid, mid, tid))
    end
end

## printing
theader = ["Thread $(i)" for i in 0:NUM_THREADS-1]
pretty_table(events; header = vcat(["Event"], theader))
pretty_table(metrics; header = vcat(["Metric"], theader))