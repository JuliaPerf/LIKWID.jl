```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/examples/perfmon.jl"
```

# Monitoring performance

## Setting up

### Pinning the Julia threads

It's highly recommended to pin the Julia threads to specific cores.
We'll use [ThreadPools.jl](https://github.com/tro3/ThreadPools.jl)
to operate with only a few of the available Julia threads.

````@example perfmon
# we'll consider the first `NUM_THREADS` Julia threads
using ThreadPools
const NUM_THREADS = 3;
nothing #hide
````

!!! note
    If you want to use all Julia threads, replace the parallel blocks, i.e.
    `tmap(1:NUM_THREADS) do threadid`, by `Threads.@threads :static for threadid in 1:NUM_THREADS`.

Let's pin the first `NUM_THREADS` threads to the first `NUM_THREADS` cores.

````@example perfmon
using LIKWID
cores = 0:NUM_THREADS-1
tmap(i->LIKWID.pinthread(cores[i]), 1:NUM_THREADS)
tmap(i->LIKWID.get_processor_id(), 1:NUM_THREADS) # check
````

### Environment variables

We use the `LIKWID.LIKWID_*` functions to set environment variables to configure LIKWID for our
monitoring.

````@example perfmon
# use the following threads
cpustr = join(collect(0:NUM_THREADS-1), ",")
LIKWID.LIKWID_THREADS(cpustr)
# the location the marker file will be stored
LIKWID.LIKWID_FILEPATH(joinpath(@__DIR__, "likwid_marker.out"))
# Use the access daemon
LIKWID.LIKWID_MODE(1)
# Overwrite registers (if they are in use)
LIKWID.LIKWID_FORCE(true)
# Debug level
LIKWID.LIKWID_DEBUG(0)
# Events to measure
LIKWID.LIKWID_EVENTS("FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0");
nothing #hide
````

### Initialize LIKWID modules

````@example perfmon
using LIKWID: PerfMon
Marker.init_nothreads()
PerfMon.init()
````

## Measurement

First we register the marker region. While this is not required
it is strongly recommended as it reduces overhead of `Marker.startregion`
and prevents wrong counts in short regions.

Note that there must be a barrier between registering a region and starting that
region. Typically these are done in separate parallel blocks, relying on
the implicit barrier at the end of the parallel block. Usually there is
a parallel block for initialization and a parallel block for execution.

````@example perfmon
tmap(1:NUM_THREADS) do threadid
    Marker.registerregion("Total")
    Marker.registerregion("calc_flops")

    # To demonstrate that registering regions is optional, we do not register
    # the "copy" region, which we'll use later.
end;
nothing #hide
````

Let's get to the actual performance monitoring.
We will measure a single region, get the results
and reset the region so that these results
do not affect (potential) later measurements.

But first, we'll need to define the computation
that we want to analyze.

````@example perfmon
# simple function designed to do floating point computations
function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end
````

Let's run the computation and monitor the performance. For good measure,
we put everything in a function.

````@example perfmon
function monitor_do_flops(NUM_FLOPS = 100_000_000)
    a = 1.8
    b = 3.2
    c = 1.0
    tmap(1:NUM_THREADS) do threadid
        # Notice that only the first group specified, `FLOPS_DP`, will be measured.
        # See further below for how to measure multiple groups.
        Marker.startregion("calc_flops")
        c = do_flops(c, a, b, NUM_FLOPS)
        Marker.stopregion("calc_flops")
    end
    return nothing
end
monitor_do_flops()
````

## Analysis

To query basic information about the region from all threads
we use [`Marker.getregion`](@ref).

````@example perfmon
tmap(1:NUM_THREADS) do threadid
    nevents, events, time, count = Marker.getregion("calc_flops")
    gid = PerfMon.get_id_of_active_group()
    group_name = PerfMon.get_name_of_group(gid)
    # print basic info
    println("Thread $(threadid): group $(group_name), $(nevents) events, runtime $(time) s, and call count $(count)")
end;
nothing #hide
````

The tools from the `LIKWID.PerfMon` module can be used to get more detailed information,
such as the event and metric results.

````@example perfmon
using PrettyTables
using Printf
_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

# extract event and metric results
gid = PerfMon.get_id_of_active_group()
nevents = PerfMon.get_number_of_events(gid)
nmetrics = PerfMon.get_number_of_metrics(gid)
events = Matrix(undef, nevents, NUM_THREADS+1)
metrics = Matrix(undef, nmetrics, NUM_THREADS+1)

for tid in 0:NUM_THREADS-1
    for eid in 0:nevents-1
        events[eid+1,1] = PerfMon.get_name_of_event(gid, eid)
        events[eid+1,tid+2] = _zeroifnothing(PerfMon.get_result(gid, eid, tid))
    end
    for mid in 0:nmetrics-1
        metrics[mid+1,1] = PerfMon.get_name_of_metric(gid, mid)
        metrics[mid+1,tid+2] = _zeroifnothing(PerfMon.get_metric(gid, mid, tid))
    end
end

# printing
theader = ["Thread $(i)" for i in 0:NUM_THREADS-1]
pretty_table(events; header=vcat(["Event"], theader))
pretty_table(metrics; header=vcat(["Metric"], theader))
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

