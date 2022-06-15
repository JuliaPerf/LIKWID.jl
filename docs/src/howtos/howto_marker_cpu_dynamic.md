```@meta
EditURL = "<unknown>/howto_marker_cpu_dynamic.jl"
```

# Marker API (CPU): Dynamic Usage

This is a demo of how to use the marker API to monitor the performance of a computation (`do_flops` below)
running on multiple Julia threads using LIKWID from within Julia (i.e. without using `likwid-perfctr ...`).
You can simply start Julia with `julia -t N`.

## Setting up

### Pinning the Julia threads

It's absolutely necessary to pin the Julia threads to specific cores.
Otherwise, the threads might migrate to different cores and our hardware performance
counter measurements are meaningless.

Let's pin the Julia threads to the first `nthreads()` cores.

````julia
using LIKWID
using Base.Threads: @threads, nthreads
@assert nthreads() > 1 # hide
LIKWID.pinthreads(0:nthreads()-1)
````

### Environment variables

We use the `LIKWID.LIKWID_*` functions to set environment variables to configure LIKWID for our
monitoring.

````julia
# use the following threads
cpustr = join(0:nthreads()-1, ",")
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
````

### Initialize LIKWID modules

````julia
using LIKWID: PerfMon
Marker.init_nothreads()
PerfMon.init()
````

````
true
````

## Measurement

````julia
# simple function designed to do floating point computations
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

Let's run the computation and monitor the performance. For good measure,
we put everything in a function.

````julia
function monitor_do_flops(NUM_FLOPS = 100_000_000)
    a = 1.8
    b = 3.2
    c = 1.0
    @threads :static for tid in 1:nthreads()
        # Notice that only the first group specified, `FLOPS_DP`, will be measured.
        # See further below for how to measure multiple groups.
        ; Marker.startregion("calc_flops")
        @region "calc_flops" c = do_flops(c, a, b, NUM_FLOPS)
        ; Marker.stopregion("calc_flops")
    end
    return nothing
end
monitor_do_flops()
````

````
WARN: Region calc_flops was already started
WARN: Region calc_flops was already started
WARN: Region calc_flops was already started
WARN: Stopping an unknown/not-started region calc_flops
WARN: Stopping an unknown/not-started region calc_flops
WARN: Stopping an unknown/not-started region calc_flops

````

## Analysis

To query basic information about the region from all threads
we use [`Marker.getregion`](@ref).

````julia
@threads :static for threadid in 1:nthreads()
    nevents, events, time, count = Marker.getregion("calc_flops")
    gid = PerfMon.get_id_of_active_group()
    group_name = PerfMon.get_name_of_group(gid)
    # print basic info
    println("Thread $(threadid): group $(group_name), $(nevents) events, runtime $(time) s, and call count $(count)")
end;
````

````
Thread 1: group FLOPS_DP, 6 events, runtime 0.09083124763678302 s, and call count 1
Thread 2: group FLOPS_DP, 6 events, runtime 0.09081997779150272 s, and call count 1
Thread 3: group FLOPS_DP, 6 events, runtime 0.09083271784730416 s, and call count 1

````

The tools from the `LIKWID.PerfMon` module can be used to get more detailed information,
such as the event and metric results.

````julia
using PrettyTables
using Printf
_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

# extract event and metric results
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

# printing
theader = ["Thread $(i)" for i in 1:nthreads()]
pretty_table(events; header = vcat(["Event"], theader))
pretty_table(metrics; header = vcat(["Metric"], theader))
````

````
┌───────────────────────────┬───────────┬───────────┬───────────┐
│                     Event │  Thread 1 │  Thread 2 │  Thread 3 │
├───────────────────────────┼───────────┼───────────┼───────────┤
│          ACTUAL_CPU_CLOCK │  1.6629e9 │ 4.49548e8 │  4.4838e8 │
│             MAX_CPU_CLOCK │ 1.15592e9 │ 3.13751e8 │ 3.12692e8 │
│      RETIRED_INSTRUCTIONS │ 2.18953e9 │ 3.15543e8 │ 3.15447e8 │
│       CPU_CLOCKS_UNHALTED │ 1.64928e9 │ 4.47128e8 │ 4.47229e8 │
│ RETIRED_SSE_AVX_FLOPS_ALL │ 1.00035e8 │     1.0e8 │     1.0e8 │
│                     MERGE │       0.0 │       0.0 │       0.0 │
└───────────────────────────┴───────────┴───────────┴───────────┘
┌──────────────────────┬──────────┬──────────┬──────────┐
│               Metric │ Thread 1 │ Thread 2 │ Thread 3 │
├──────────────────────┼──────────┼──────────┼──────────┤
│  Runtime (RDTSC) [s] │  1.03519 │  1.03519 │  1.03519 │
│ Runtime unhalted [s] │ 0.678736 │  0.18349 │ 0.183013 │
│          Clock [MHz] │  3524.53 │  3510.38 │  3513.12 │
│                  CPI │ 0.753256 │  1.41701 │  1.41776 │
│         DP [MFLOP/s] │   96.634 │  96.6004 │  96.6004 │
└──────────────────────┴──────────┴──────────┴──────────┘

````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

