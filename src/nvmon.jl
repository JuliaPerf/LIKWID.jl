module NvMon

using ..LIKWID:
    LibLikwid, gputopo_initialized, nvmon_initialized, init_topology_gpu, GroupInfoCompact, get_gpu_topology

isinitialized() = nvmon_initialized[]

"""
    init(gpuid_or_gpuids)
Initialize LIKWID's NvMon module for the gpu(s) with the given gpu id(s) (starting at 0!).
"""
function init(gpus::AbstractVector{Int32}=Int32[i - 1 for i in 1:(get_gpu_topology().numDevices)])
    nvmon_initialized[] && finalize()

    if !gputopo_initialized[]
        init_topology_gpu() || error("Couldn't init gpu topology.")
    end

    ngpus = length(gpus)
    ret = LibLikwid.nvmon_init(ngpus, gpus)
    if ret == 0
        nvmon_initialized[] = true
        return true
    end
    return false
end

init(gpus::AbstractVector{<:Integer}) = init(convert(Vector{Int32}, gpus))

function finalize()
    LibLikwid.nvmon_finalize()
    nvmon_initialized[] = false
    return nothing
end

_check_groupid(gid) = 1 ≤ gid ≤ get_number_of_groups()
_check_eventidx(gid, eidx) = 1 ≤ eidx ≤ get_number_of_events(gid)
_check_metricidx(gid, eidx) = 1 ≤ eidx ≤ get_number_of_metrics(gid)
_check_gpu(gpu) = 0 ≤ gpu < get_gpu_topology().numDevices
_check_gpuid(gpuid) = 1 ≤ gpuid ≤ get_number_of_gpus()

"""
Return the number of GPUs initialized in the nvmon module.
"""
get_number_of_gpus() = LibLikwid.nvmon_getNumberOfGPUs()

"""
Return the number of groups currently registered in the nvmon module.
"""
get_number_of_groups() = LibLikwid.nvmon_getNumberOfGroups()

"""
Return the number of events in the group with id `groupid` (starts at 1).
"""
get_number_of_events(groupid::Integer) = LibLikwid.nvmon_getNumberOfEvents(groupid - 1)

"""
Return the number of metrics in the group with id `groupid` (starts at 1).
Always zero for custom event sets.
"""
get_number_of_metrics(groupid::Integer) = LibLikwid.nvmon_getNumberOfMetrics(groupid - 1)

"""
Return a dictionary of all available nvmon groups for the GPU identified by `gpu` (starts at 0).

# Examples
```jldoctest
julia> NvMon.supported_groups()
Dict{String, LIKWID.GroupInfoCompact} with 4 entries:
  "DATA"     => DATA => Load to store ratio
  "FLOPS_SP" => FLOPS_SP => Single-precision floating point
  "FLOPS_HP" => FLOPS_HP => Half-precision floating point
  "FLOPS_DP" => FLOPS_DP => Double-precision floating point
```
"""
function supported_groups(gpu::Integer=0)
    if !gputopo_initialized[]
        init_topology_gpu() || error("Couldn't init gpu topology.")
    end
    # if !nvmon_initialized[]
    #     init(Int32[gpuid]) || error("Couldn't init nvmon.")
    # end
    _check_gpu(gpu) || return nothing

    # refs to char**
    groups_ref = Ref{Ptr{Ptr{Cchar}}}()
    shorts_ref = Ref{Ptr{Ptr{Cchar}}}()
    longs_ref = Ref{Ptr{Ptr{Cchar}}}()

    ret = LibLikwid.nvmon_getGroups(gpu, groups_ref, shorts_ref, longs_ref)
    ret <= 0 && return nothing

    groups_vec = unsafe_wrap(Array, groups_ref[], ret)
    shorts_vec = unsafe_wrap(Array, shorts_ref[], ret)
    longs_vec = unsafe_wrap(Array, longs_ref[], ret)
    res = Dict{String,GroupInfoCompact}()
    for i in 1:ret
        name = unsafe_string(groups_vec[i])
        res[name] = GroupInfoCompact(
            name,
            unsafe_string(shorts_vec[i]),
            unsafe_string(longs_vec[i]),
        )
    end
    LibLikwid.nvmon_returnGroups(ret, groups_ref[], shorts_ref[], longs_ref[])
    return res
end

"Checks if the given performance group is available on the given GPU (defaults to the first)."
isgroupsupported(group, gpu::Integer=0) = !isnothing(findfirst(g -> g.name == group, supported_groups(gpu)))

"""
    add_event_set(estr) -> groupid
Add a performance group or a custom event set to the nvmon module.
Returns a `groupid` (starting at 1) which is required to later specify the event set.
"""
function add_event_set(estr::AbstractString)
    nvmon_initialized[] || return nothing
    groupid = LibLikwid.nvmon_addEventSet(estr)
    return Int(groupid) + 1
end

"""
Return the name of the group identified by `groupid` (starts at 1).
If it is a custom event set, the name is set to `Custom`.
"""
function get_name_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    name = unsafe_string(LibLikwid.nvmon_getGroupName(groupid - 1))
    return name
end

"""
Return the short information about a performance group with id `groupid` (starts at 1).
"""
function get_shortinfo_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    sinfo = unsafe_string(LibLikwid.nvmon_getGroupInfoShort(groupid - 1))
    return sinfo
end

"""
Return the (long) description of a performance group with id `groupid` (starts at 1).
"""
function get_longinfo_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    linfo = unsafe_string(LibLikwid.nvmon_getGroupInfoLong(groupid - 1))
    return linfo
end

"""
Return the name of the event identified by `groupid` and `eventidx` (both start at 1).
"""
function get_name_of_event(groupid::Integer, eventidx::Integer)
    if !nvmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_eventidx(groupid, eventidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.nvmon_getEventName(groupid - 1, eventidx - 1))
    return name
end

"""
Return the name of the counter register identified by `groupid` and `eventidx` (both start at 1).
"""
function get_name_of_counter(groupid::Integer, eventidx::Integer)
    if !nvmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_eventidx(groupid, eventidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.nvmon_getCounterName(groupid - 1, eventidx - 1))
    return name
end

"""
Return the name of a derived metric identified by `groupid` and `metricidx` (both start at 1).
"""
function get_name_of_metric(groupid::Integer, metricidx::Integer)
    if !nvmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_metricidx(groupid, metricidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.nvmon_getMetricName(groupid - 1, metricidx - 1))
    return name
end

"""
Program the counter registers to measure all events in group `groupid` (starts at 1). Returns `true` on success.
"""
function setup_counters(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return false
    ret = LibLikwid.nvmon_setupCounters(groupid - 1)
    return ret == 0
end

"""
Start the counter registers. Returns `true` on success.
"""
function start_counters()
    nvmon_initialized[] || return nothing
    ret = LibLikwid.nvmon_startCounters()
    return ret == 0
end

"""
Stop the counter registers. Returns `true` on success.
"""
function stop_counters()
    nvmon_initialized[] || return nothing
    ret = LibLikwid.nvmon_stopCounters()
    return ret == 0
end

"""
Read the counter registers.
To be executed after `start_counters` and before `stop_counters`.
Returns `true` on success.
"""
function read_counters()
    nvmon_initialized[] || return nothing
    ret = LibLikwid.nvmon_readCounters()
    return ret == 0
end

"""
Return the `groupid` of the currently activate group.
"""
function get_id_of_active_group()
    nvmon_initialized[] || return nothing
    return LibLikwid.nvmon_getIdOfActiveGroup() + 1
end

"""
Switch currently active group to `groupid` (starts at 1). Returns `true` on success.
"""
function switch_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    groupid == get_id_of_active_group() && return true
    ret = LibLikwid.nvmon_switchActiveGroup(groupid - 1)
    return ret == 0
end

"""
Return the raw counter register result of the last measurement cycle identified by group `groupid` and the indices for event `eventidx` and gpu `gpuid` (all starting at 1).
"""
function get_last_result(groupid::Integer, eventidx::Integer, gpuid::Integer)
    nvmon_initialized[] || return nothing
    _check_eventidx(groupid, eventidx) || return nothing
    _check_gpuid(gpuid) || return nothing
    res = LibLikwid.nvmon_getLastResult(groupid - 1, eventidx - 1, gpuid - 1)
    return res
end

"""
Return the raw counter register result of all measurements identified by group `groupid` and the indices for event `eventidx` and gpu `gpuid` (all starting at 1).
"""
function get_result(groupid::Integer, eventidx::Integer, gpuid::Integer)
    nvmon_initialized[] || return nothing
    _check_eventidx(groupid, eventidx) || return nothing
    _check_gpuid(gpuid) || return nothing
    res = LibLikwid.nvmon_getResult(groupid - 1, eventidx - 1, gpuid - 1)
    return res
end

"""
Return the derived metric result of all measurements identified by group `groupid` and the indices for metric `metricidx` and gpu `gpuid` (all starting at 1).
"""
function get_metric(groupid::Integer, metricidx::Integer, gpuid::Integer)
    nvmon_initialized[] || return nothing
    _check_metricidx(groupid, metricidx) || return nothing
    _check_gpuid(gpuid) || return nothing
    res = LibLikwid.nvmon_getMetric(groupid - 1, metricidx - 1, gpuid - 1)
    return res
end

"""
Return the derived metric result of the last measurement cycle identified by group `groupid` and the indices for metric `metricidx` and gpu `gpuid` (all starting at 1).
"""
function get_last_metric(groupid::Integer, metricidx::Integer, gpuid::Integer)
    nvmon_initialized[] || return nothing
    _check_metricidx(groupid, metricidx) || return nothing
    _check_gpuid(gpuid) || return nothing
    res = LibLikwid.nvmon_getLastMetric(groupid - 1, metricidx - 1, gpuid - 1)
    return res
end

"""
Return the measurement time for group identified by `groupid` (starts at 1).
"""
function get_time_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    time = LibLikwid.nvmon_getTimeOfGroup(groupid - 1)
    return time
end

"""
  `get_metric_results([groupid_or_groupname, metricid_or_metricname, gpuid::Integer])`

Retrieve the results of monitored metrics.

Optionally, a group, metric, and gpuid can be provided to select a subset of metrics or a single metric.
If given as integers, note that `groupid`, `metricid`, and `gpuid` all start at 1 and the latter enumerates the monitored gpus.

If no arguments are provided, a nested data structure is returned in which different
levels correspond to performance groups, gpus, and metrics (in this order).
```
"""
function get_metric_results(group, gpuid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    _check_groupid(gpuid) || return nothing
    nmetrics = get_number_of_metrics(groupid)
    d = OrderedDict{String,Float64}()
    for metricid in 1:nmetrics
        metric = get_name_of_metric(groupid, metricid)
        d[metric] = get_last_metric(groupid, metricid, gpuid)
    end
    return d
end
get_metric_results(groupid::Integer) = get_metric_results.(groupid, 1:get_number_of_threads())
get_metric_results(groupname::AbstractString) = get_metric_results(get_id_of_group(groupname))

function get_metric_results(group, metric, gpuid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    metricid = metric isa Integer ? metric : get_id_of_metric(groupid, metric)
    return get_last_metric(groupid, metricid, gpuid)
end
get_metric_results(group, metric) = get_metric_results.(Ref(group), Ref(metric), 1:get_number_of_threads())

"""
  `get_metric_results()`

Get the metric results for all performance groups and all monitored
([`NvMon.init`](@ref)) gpus.

Returns a an `OrderedDict` whose keys correspond to the performance groups
and the values hold the results for all monitored gpus.
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
  `get_event_results([groupid_or_groupname, eventid_or_eventname, gpuid::Integer])`

Retrieve the results of monitored events. Same as [`get_metric_results`](@ref) but for raw events.
"""
function get_event_results(group, gpuid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    perfmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    _check_gpuid(gpuid) || return nothing
    nevents = get_number_of_events(groupid)
    d = OrderedDict{String,Float64}()
    for eventid in 1:nevents
        event = get_name_of_event(groupid, eventid)
        d[event] = get_last_event(groupid, eventid, gpuid)
    end
    return d
end
get_event_results(groupid::Integer) = get_event_results.(groupid, 1:get_number_of_threads())
get_event_results(groupname::AbstractString) = get_event_results(get_id_of_group(groupname))

function get_event_results(group, event, gpuid::Integer)
    groupid = group isa Integer ? group : get_id_of_group(group)
    eventid = event isa Integer ? event : get_id_of_event(groupid, event)
    return get_last_event(groupid, eventid, gpuid)
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
    nvmon(f, group_or_groups[; gpuids])
Monitor performance groups while executing the given function `f` on one or multiple GPUs.
Note that
* `NvMon.init` and `NvMon.finalize` are called automatically
* the measurement of multiple performance groups is sequential and requires multiple executions of `f`!

**Keyword arguments:**
* `gpuids` (default: first GPU): specify the GPUs to be monitored

# Example
```julia
julia> using LIKWID

julia> x = CUDA.rand(1000); y = CUDA.rand(1000);

julia> metrics, events = nvmon("FLOPS_DP") do
           CUDA.@sync x .+ y;
       end;
```
"""
function nvmon(f, group_or_groups; gpuids=0)
    gpuids = gpuids isa Integer ? [gpuids] : gpuids
    NvMon.init(gpuids)
    groups = group_or_groups isa AbstractString ? (group_or_groups,) : group_or_groups
    for group in groups
        gid = NvMon.add_event_set(group)
        NvMon.setup_counters(gid)
        NvMon.start_counters()
        f()
        NvMon.stop_counters()
    end
    metrics_results = NvMon.get_metric_results()
    event_results = NvMon.get_event_results()
    NvMon.finalize()
    if group_or_groups isa AbstractString
        # since we only have one group simplify the result structue
        metrics_results = metrics_results[group_or_groups]
        event_results = event_results[group_or_groups]
        if length(gpuids) == 1 # only one cputhread monitored
            metrics_results = first(metrics_results)
            event_results = first(event_results)
        end
    end
    metrics_results, event_results
end

"""
    @nvmon group_or_groups codeblock

See also: [`nvmon`](@ref)

# Example
```
julia> using LIKWID

julia> x = CUDA.rand(1000); y = CUDA.rand(1000);

julia> metrics, events = @nvmon "FLOPS_DP" x .+ y;
```
"""
macro nvmon(group_or_groups, expr)
    q = quote
        NvMon.nvmon($group_or_groups) do
            $(expr)
        end
    end
    return esc(q)
end

end # module
