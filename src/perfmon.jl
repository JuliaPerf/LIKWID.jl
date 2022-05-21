module PerfMon

using ..LIKWID:
    LibLikwid,
    perfmon_initialized,
    topo_initialized,
    numa_initialized,
    timer_initialized,
    init_topology,
    init_numa,
    GroupInfoCompact,
    OrderedDict,
    perfmon_initialized,
    get_processor_ids,
    get_processor_id,
    pinthreads,
    pinthread

function init(cpus::AbstractVector{Int32}=get_processor_ids())
    perfmon_initialized[] && finalize()

    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end

    nthreads = length(cpus)
    ret = LibLikwid.perfmon_init(nthreads, cpus)
    if ret == 0
        perfmon_initialized[] = true
        timer_initialized[] = true
        return true
    end
    return false
end

isinitialized() = perfmon_initialized[]

init(cpus::AbstractVector{<:Integer}) = init(convert(Vector{Int32}, cpus))
init(cpu::Integer) = init(Int32[cpu])

function finalize()
    LibLikwid.perfmon_finalize()
    perfmon_initialized[] = false
    return nothing
end

_check_groupid(gid) = 1 ≤ gid ≤ get_number_of_groups()
_check_eventidx(gid, eidx) = 1 ≤ eidx ≤ get_number_of_events(gid)
_check_metricidx(gid, eidx) = 1 ≤ eidx ≤ get_number_of_metrics(gid)
_check_threadidx(tidx) = 1 ≤ tidx ≤ get_number_of_threads()

"""
Return the number of threads initialized in the perfmon module.
"""
get_number_of_threads() = LibLikwid.perfmon_getNumberOfThreads()

"""
Return the number of groups currently registered in the perfmon module.
"""
get_number_of_groups() = LibLikwid.perfmon_getNumberOfGroups()

"""
Return the amount of events in the given group with id `groupid` (starts at 1).
"""
get_number_of_events(groupid::Integer) = LibLikwid.perfmon_getNumberOfEvents(groupid - 1)

"""
Return the amount of metrics in the given group with id `groupid` (starts at 1).
Always zero for custom event sets.
"""
get_number_of_metrics(groupid::Integer) = LibLikwid.perfmon_getNumberOfMetrics(groupid - 1)

"""
Return a list of all available perfmon groups.

# Examples
```jldoctest
julia> PerfMon.get_groups()
30-element Vector{LIKWID.GroupInfoCompact}:
 MEM_SP => Overview of arithmetic and main memory performance
 CYCLE_ACTIVITY => Cycle Activities
 ENERGY => Power and Energy consumption
 UOPS_RETIRE => UOPs retirement
 PMM => Intel Optane DC bandwidth in MBytes/s
 TLB_INSTR => L1 Instruction TLB miss rate/ratio
 DATA => Load to store ratio
 UOPS_ISSUE => UOPs issueing
 L2CACHE => L2 cache miss rate/ratio
 L2 => L2 cache bandwidth in MBytes/s
 ⋮
 TMA => Top down cycle allocation
 CLOCK => Power and Energy consumption
 FLOPS_DP => Double Precision MFLOP/s
 CYCLE_STALLS => Cycle Activities (Stalls)
 L3 => L3 cache bandwidth in MBytes/s
 UPI => UPI traffic
 L3NEW => L3 cache bandwidth in MBytes/s
 L3PF => L3 cache bandwidth in MBytes/s
 L2L3 => L3 cache bandwidth in MBytes/s
```
"""
function get_groups()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    # refs to char**
    groups_ref = Ref{Ptr{Ptr{Cchar}}}()
    shorts_ref = Ref{Ptr{Ptr{Cchar}}}()
    longs_ref = Ref{Ptr{Ptr{Cchar}}}()

    ret = LibLikwid.perfmon_getGroups(groups_ref, shorts_ref, longs_ref)
    ret <= 0 && return nothing

    groups_vec = unsafe_wrap(Array, groups_ref[], ret)
    shorts_vec = unsafe_wrap(Array, shorts_ref[], ret)
    longs_vec = unsafe_wrap(Array, longs_ref[], ret)
    res = Vector{GroupInfoCompact}(undef, ret)
    for i in 1:ret
        res[i] = GroupInfoCompact(
            unsafe_string(groups_vec[i]),
            unsafe_string(shorts_vec[i]),
            unsafe_string(longs_vec[i]),
        )
    end
    LibLikwid.perfmon_returnGroups(ret, groups_ref[], shorts_ref[], longs_ref[])
    return res
end

"""
    add_event_set(estr) -> groupid
Add a performance group or a custom event set to the perfmon module.
Returns a `groupid` (starting at 1) which is required to later specify the event set.
"""
function add_event_set(estr::AbstractString)
    perfmon_initialized[] || return nothing
    groupid = LibLikwid.perfmon_addEventSet(estr)
    return Int(groupid) + 1
end

"""
Return the name of the group identified by `groupid` (starts at 1).
If it is a custom event set, the name is set to `Custom`.
"""
function get_name_of_group(groupid::Integer)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    name = unsafe_string(LibLikwid.perfmon_getGroupName(groupid - 1))
    return name
end

"Get the id of the group with the given name."
function get_id_of_group(groupname::AbstractString)
    r = findfirst(i -> get_name_of_group(i) == groupname, 1:get_number_of_groups())
    isnothing(r) && error("Group with name \"$groupname\" couldn't be found.")
    return r
end

"Get the id of the metric with the given name."
function get_id_of_metric(group, metricname::AbstractString)
    gid = group isa Integer ? group : get_id_of_group(group)
    r = findfirst(i -> get_name_of_metric(gid, i) == metricname, 1:get_number_of_metrics(gid))
    isnothing(r) && error("Metric with name \"$(get_name_of_group(gid))\" couldn't be found. Available metrics are: $(list_metrics(gid))")
    return r
end

"Get the id of the event with the given name."
function get_id_of_event(group, eventname::AbstractString)
    gid = group isa Integer ? group : get_id_of_group(group)
    r = findfirst(i -> get_name_of_event(gid, i) == eventname, 1:get_number_of_events(gid))
    isnothing(r) && error("Event with name \"$(get_name_of_group(gid))\" couldn't be found. Available events are: $(list_events(gid))")
    return r
end

"""
Return the short information about a performance group with id `groupid` (starts at 1).
"""
function get_shortinfo_of_group(groupid::Integer)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    sinfo = unsafe_string(LibLikwid.perfmon_getGroupInfoShort(groupid - 1))
    return sinfo
end

"""
Return the (long) description of a performance group with id `groupid` (starts at 1).
"""
function get_longinfo_of_group(groupid::Integer)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    linfo = unsafe_string(LibLikwid.perfmon_getGroupInfoLong(groupid - 1))
    return linfo
end

"""
Return the name of the event identified by `groupid` and `eventidx` (both starting at 1).
"""
function get_name_of_event(groupid::Integer, eventidx::Integer)
    if !perfmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_eventidx(groupid, eventidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.perfmon_getEventName(groupid - 1, eventidx - 1))
    return name
end

"""
Return the name of the counter register identified by `groupid` and `eventidx` (both starting at 1).
"""
function get_name_of_counter(groupid::Integer, eventidx::Integer)
    if !perfmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_eventidx(groupid, eventidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.perfmon_getCounterName(groupid - 1, eventidx - 1))
    return name
end

"""
Return the name of a derived metric identified by `groupid` and `metricidx` (both starting at 1).
"""
function get_name_of_metric(groupid::Integer, metricidx::Integer)
    if !perfmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_metricidx(groupid, metricidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.perfmon_getMetricName(groupid - 1, metricidx - 1))
    return name
end

"""
Program the counter registers to measure all events in group `groupid` (starts at 1). Returns `true` on success.
"""
function setup_counters(groupid::Integer)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return false
    ret = LibLikwid.perfmon_setupCounters(groupid - 1)
    return ret == 0
end

"""
Start the counter registers. Returns `true` on success.
"""
function start_counters()
    perfmon_initialized[] || return nothing
    ret = LibLikwid.perfmon_startCounters()
    return ret == 0
end

"""
Stop the counter registers. Returns `true` on success.
"""
function stop_counters()
    perfmon_initialized[] || return nothing
    ret = LibLikwid.perfmon_stopCounters()
    return ret == 0
end

"""
Read the counter registers.
To be executed after `start_counters` and before `stop_counters`.
Returns `true` on success.
"""
function read_counters()
    perfmon_initialized[] || return nothing
    ret = LibLikwid.perfmon_readCounters()
    return ret == 0
end

"""
Return the `groupid` of the currently activate group.
"""
function get_id_of_active_group()
    perfmon_initialized[] || return nothing
    return LibLikwid.perfmon_getIdOfActiveGroup() + 1
end

"""
Switch currently active group to `groupid` (starts with 1). Returns `true` on success.
"""
function switch_group(groupid::Integer)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    groupid == get_id_of_active_group() && return true
    ret = LibLikwid.perfmon_switchActiveGroup(groupid - 1)
    return ret == 0
end

"""
Return the raw counter register result of the last measurement cycle identified by group `groupid` and the indices for event `eventidx` and thread `threadidx` (all starting at 1).
"""
function get_last_result(groupid::Integer, eventidx::Integer, threadidx::Integer)
    perfmon_initialized[] || return nothing
    _check_eventidx(groupid, eventidx) || return nothing
    _check_threadidx(threadidx) || return nothing
    res = LibLikwid.perfmon_getLastResult(groupid - 1, eventidx - 1, threadidx - 1)
    return res
end
get_last_event(groupid, eventidx, threadidx) = get_last_result(groupid, eventidx, threadidx)

"""
Return the raw counter register result of all measurements identified by group `groupid` and the indices for event `eventidx` and thread `threadidx` (all starting at 1).
"""
function get_result(groupid::Integer, eventidx::Integer, threadidx::Integer)
    perfmon_initialized[] || return nothing
    _check_eventidx(groupid, eventidx) || return nothing
    _check_threadidx(threadidx) || return nothing
    res = LibLikwid.perfmon_getResult(groupid - 1, eventidx - 1, threadidx - 1)
    return res
end

"""
Return the derived metric result of all measurements identified by group `groupid` and the indices for metric `metricidx` and thread `threadidx` (all starting at 1).
"""
function get_metric(groupid::Integer, metricidx::Integer, threadidx::Integer)
    perfmon_initialized[] || return nothing
    _check_metricidx(groupid, metricidx) || return nothing
    _check_threadidx(threadidx) || return nothing
    res = LibLikwid.perfmon_getMetric(groupid - 1, metricidx - 1, threadidx - 1)
    return res
end

"""
Return the derived metric result of the last measurement cycle identified by group `groupid` and the indices for metric `metricidx` and thread `threadidx` (all starting at 1).
"""
function get_last_metric(groupid::Integer, metricidx::Integer, threadidx::Integer)
    perfmon_initialized[] || return nothing
    _check_metricidx(groupid, metricidx) || return nothing
    _check_threadidx(threadidx) || return nothing
    res = LibLikwid.perfmon_getLastMetric(groupid - 1, metricidx - 1, threadidx - 1)
    return res
end

"""
Return the measurement time for group identified by `groupid` (starts at 1).
"""
function get_time_of_group(groupid::Integer)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    time = LibLikwid.perfmon_getTimeOfGroup(groupid - 1)
    return time
end

"""
List all the metrics of a given group (`groupid` starts at 1).
"""
function list_metrics(group)
    groupid = group isa Integer ? group : get_id_of_group(group)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    nmetrics = get_number_of_metrics(groupid)
    return get_name_of_metric.(Ref(groupid), 1:nmetrics)
end

"""
List all the events of a given group (`groupid` starts at 1).
"""
function list_events(group)
    groupid = group isa Integer ? group : get_id_of_group(group)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    nevents = get_number_of_events(groupid)
    return get_name_of_event.(Ref(groupid), 1:nevents)
end

"""
  `get_metric_results([groupid_or_groupname, metricid_or_metricname, threadid::Integer])`

Retrieve the results of monitored metrics.

Optionally, a group, metric, and threadid can be provided to select a subset of metrics or a single metric.
If given as integers, note that `groupid`, `metricid`, and `threadid` all start at 1 and the latter enumerates the monitored cpu threads.

If no arguments are provided, a nested data structure is returned in which different
levels correspond to performance groups, cpu threads, and metrics (in this order).

**Examples**
```julia
julia> PerfMon.get_metric_results("FLOPS_DP")
4-element Vector{OrderedDict{String, Float64}}:
 OrderedDict("Runtime (RDTSC) [s]" => 1.1381168037989857, "Runtime unhalted [s]" => 0.0016642799007831007, "Clock [MHz]" => 2911.9285695819794, "CPI" => NaN, "DP [MFLOP/s]" => 0.0)
 OrderedDict("Runtime (RDTSC) [s]" => 1.1381168037989857, "Runtime unhalted [s]" => 1.4755564705029072, "Clock [MHz]" => 3523.1114993407705, "CPI" => 0.3950777002592585, "DP [MFLOP/s]" => 17608.069202657578)
 OrderedDict("Runtime (RDTSC) [s]" => 1.1381168037989857, "Runtime unhalted [s]" => 7.80437228993214e-5, "Clock [MHz]" => 2638.6244625814124, "CPI" => NaN, "DP [MFLOP/s]" => 0.0)
 OrderedDict("Runtime (RDTSC) [s]" => 1.1381168037989857, "Runtime unhalted [s]" => 7.050705084934875e-5, "Clock [MHz]" => 2807.7525945849698, "CPI" => NaN, "DP [MFLOP/s]" => 0.0)

julia> PerfMon.get_metric_results("FLOPS_DP", 2) # results of second monitored cpu thread
OrderedDict{String, Float64} with 5 entries:
  "Runtime (RDTSC) [s]"  => 1.13812
  "Runtime unhalted [s]" => 1.47556
  "Clock [MHz]"          => 3523.11
  "CPI"                  => 0.395078
  "DP [MFLOP/s]"         => 17608.1

julia> PerfMon.get_metric_results("FLOPS_DP", "DP [MFLOP/s]", 2)
17608.069202657578
```
"""
function get_metric_results(group, threadid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    _check_threadidx(threadid) || return nothing
    nmetrics = get_number_of_metrics(groupid)
    d = OrderedDict{String,Float64}()
    for metricid in 1:nmetrics
        metric = get_name_of_metric(groupid, metricid)
        d[metric] = get_last_metric(groupid, metricid, threadid)
    end
    return d
end
get_metric_results(groupid::Integer) = get_metric_results.(groupid, 1:get_number_of_threads())
get_metric_results(groupname::AbstractString) = get_metric_results(get_id_of_group(groupname))

function get_metric_results(group, metric, threadid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    metricid = metric isa Integer ? metric : get_id_of_metric(groupid, metric)
    return get_last_metric(groupid, metricid, threadid)
end
get_metric_results(group, metric) = get_metric_results.(Ref(group), Ref(metric), 1:get_number_of_threads())

"""
  `get_metric_results()`

Get the metric results for all performance groups and all monitored
([`PerfMon.init`](@ref)) cpu threads.

Returns a an `OrderedDict` whose keys correspond to the performance groups
and the values hold the results for all monitored cpu threads.

**Examples**
```julia
julia> results = PerfMon.get_metric_results()
OrderedDict{String, Vector{OrderedDict{String, Float64}}} with 1 entry:
  "FLOPS_DP" => [OrderedDict("Runtime (RDTSC) [s]"=>1.13812, "Runtime unhalted [s]"=>0.00166428, "Clock [MHz]"=>291…

julia> PerfMon.get_metric_results()["FLOPS_DP"][2]["DP [MFLOP/s]"]
17608.069202657578
```
"""
function get_metric_results()
    ngrps = get_number_of_groups()
    results = OrderedDict{String,Vector{OrderedDict{String,Float64}}}()
    for group in 1:ngrps
        groupname = get_name_of_group(group)
        group_results = get_metric_results(group)
        results[groupname] = group_results
    end
    return results
end

"""
  `get_event_results([groupid_or_groupname, eventid_or_eventname, threadid::Integer])`

Retrieve the results of monitored events. Same as [`get_metric_results`](@ref) but for raw events.
"""
function get_event_results(group, threadid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    _check_threadidx(threadid) || return nothing
    nevents = get_number_of_events(groupid)
    d = OrderedDict{String,Float64}()
    for eventid in 1:nevents
        event = get_name_of_event(groupid, eventid)
        d[event] = get_last_event(groupid, eventid, threadid)
    end
    return d
end
get_event_results(groupid::Integer) = get_event_results.(groupid, 1:get_number_of_threads())
get_event_results(groupname::AbstractString) = get_event_results(get_id_of_group(groupname))

function get_event_results(group, event, threadid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    eventid = event isa Integer ? event : get_id_of_event(groupid, event)
    return get_last_event(groupid, eventid, threadid)
end
get_event_results(group, event) = get_event_results.(Ref(group), Ref(event), 1:get_number_of_threads())

function get_event_results()
    ngrps = get_number_of_groups()
    results = OrderedDict{String,Vector{OrderedDict{String,Float64}}}()
    for group in 1:ngrps
        groupname = get_name_of_group(group)
        group_results = get_event_results(group)
        results[groupname] = group_results
    end
    return results
end

"""
    perfmon(f, group_or_groups[; cpuids, autopin=true])
Monitor performance groups while executing the given function `f` on one or multiple Julia threads.
Note that
* `PerfMon.init` and `PerfMon.finalize()` are called automatically, and
* the measurement of multiple performance groups is sequential and `f` is executed multiple times.


**Keyword arguments:**
* `cpuids` (default: currently used CPU threads): specify the CPU threads (~ cores) to be monitored
* `autopin` (default: `true`): automatically pin Julia threads to the CPU threads (~ cores) they are currently running on (to avoid migration and wrong results).

# Example
```julia
julia> using LIKWID

julia> x = rand(1000); y = rand(1000);

julia> metrics, events = perfmon("FLOPS_DP") do
           x .+ y;
       end;

julia> metrics                                                                      
OrderedDict{String, Float64} with 5 entries:
  "Runtime (RDTSC) [s]"  => 8.56091e-6
  "Runtime unhalted [s]" => 3.22377e-5
  "Clock [MHz]"          => 3506.47
  "CPI"                  => 4.78484
  "DP [MFLOP/s]"         => 116.81
                                          
julia> events                                                                       
OrderedDict{String, Float64} with 6 entries:
  "ACTUAL_CPU_CLOCK"          => 78974.0
  "MAX_CPU_CLOCK"             => 55174.0
  "RETIRED_INSTRUCTIONS"      => 5977.0
  "CPU_CLOCKS_UNHALTED"       => 28599.0
  "RETIRED_SSE_AVX_FLOPS_ALL" => 1000.0
  "MERGE"                     => 0.0

julia> metrics, events = perfmon(("FLOPS_DP", "MEM1")) do
           x .+ y;
       end;
```
"""
function perfmon(f, group_or_groups; cpuids=get_processor_ids(), autopin=true)
    cpuids = cpuids isa Integer ? [cpuids] : cpuids
    autopin && _perfmon_autopin(cpuids)
    PerfMon.init(cpuids)
    groups = group_or_groups isa AbstractString ? (group_or_groups,) : group_or_groups
    for group in groups
        gid = PerfMon.add_event_set(group)
        PerfMon.setup_counters(gid)
        PerfMon.start_counters()
        f()
        PerfMon.stop_counters()
    end
    metrics_results = PerfMon.get_metric_results()
    event_results = PerfMon.get_event_results()
    PerfMon.finalize()
    if group_or_groups isa AbstractString
        # since we only have one group simplify the result structue
        metrics_results = metrics_results[group_or_groups]
        event_results = event_results[group_or_groups]
        if length(cpuids) == 1 # only one cputhread monitored
            metrics_results = first(metrics_results)
            event_results = first(event_results)
        end
    end
    metrics_results, event_results
end

function _perfmon_autopin(cpuids)
    if length(cpuids) != Threads.nthreads()
        @warn("Number of CPU ID(s) ($(length(cpuids))) doesn't match number of Julia threads ($(Threads.nthreads())). Won't autopin the Julia threads.")
    elseif length(cpuids) == 1
        pinthread(cpuids[1])
    elseif length(cpuids) == Threads.nthreads()
        pinthreads(cpuids)
    end
    return nothing
end

"""
    @perfmon groupname codeblock

See also: [`perfmon`](@ref)

# Example
```
julia> using LIKWID

julia> x = rand(1000); y = rand(1000);

julia> metrics, events = @perfmon "FLOPS_DP" x .+ y;

julia> metrics                                                                      
OrderedDict{String, Float64} with 5 entries:
  "Runtime (RDTSC) [s]"  => 8.56091e-6
  "Runtime unhalted [s]" => 3.22377e-5
  "Clock [MHz]"          => 3506.47
  "CPI"                  => 4.78484
  "DP [MFLOP/s]"         => 116.81
                                          
julia> events                                                                       
OrderedDict{String, Float64} with 6 entries:
  "ACTUAL_CPU_CLOCK"          => 78974.0
  "MAX_CPU_CLOCK"             => 55174.0
  "RETIRED_INSTRUCTIONS"      => 5977.0
  "CPU_CLOCKS_UNHALTED"       => 28599.0
  "RETIRED_SSE_AVX_FLOPS_ALL" => 1000.0
  "MERGE"                     => 0.0
```
"""
macro perfmon(groupname::AbstractString, expr)
    q = quote
        PerfMon.perfmon($groupname) do
            $(expr)
        end
    end
    return esc(q)
end

end # module
