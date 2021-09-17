module Nvmon

using ..LIKWID:
    LibLikwid, gputopo_initialized, nvmon_initialized, init_topology_gpu, GroupInfoCompact

function init(gpus::AbstractVector{Int32})
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

_check_groupid(gid) = 0 ≤ gid < get_number_of_groups()
_check_eventidx(gid, eidx) = 0 ≤ eidx < get_number_of_events(gid)
_check_metricidx(gid, eidx) = 0 ≤ eidx < get_number_of_metrics(gid)
_check_gpuid(gpuid) = 0 ≤ gpuid < get_number_of_gpus()

"""
Return the number of GPUs initialized in the nvmon module.
"""
get_number_of_gpus() = LibLikwid.nvmon_getNumberOfGPUs()

"""
Return the number of groups currently registered in the nvmon module.
"""
get_number_of_groups() = LibLikwid.nvmon_getNumberOfGroups()

"""
Return the number of events in the group.
"""
get_number_of_events(groupid::Integer) = LibLikwid.nvmon_getNumberOfEvents(groupid)

"""
Return the number of metrics in the group.
Always zero for custom event sets.
"""
get_number_of_metrics(groupid::Integer) = LibLikwid.nvmon_getNumberOfMetrics(groupid)

"""
Return a list of all available nvmon groups for the GPU identified by `gpuid`.
"""
function get_groups(gpuid::Integer=0)
    if !gputopo_initialized[]
        init_topology_gpu() || error("Couldn't init gpu topology.")
    end
    _check_gpuid(gpuid) || return nothing

    # refs to char**
    groups_ref = Ref{Ptr{Ptr{Cchar}}}()
    shorts_ref = Ref{Ptr{Ptr{Cchar}}}()
    longs_ref = Ref{Ptr{Ptr{Cchar}}}()

    ret = LibLikwid.nvmon_getGroups(gpuid, groups_ref, shorts_ref, longs_ref)
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
    LibLikwid.nvmon_returnGroups(ret, groups_ref[], shorts_ref[], longs_ref[])
    return res
end

"""
    add_event_set(estr) -> groupid
Add a performance group or a custom event set to the nvmon module.
Returns a `groupid` which is required to later specify the event set.
"""
function add_event_set(estr::AbstractString)
    nvmon_initialized[] || return nothing
    groupid = LibLikwid.nvmon_addEventSet(estr)
    return Int(groupid)
end

"""
Return the name of the group identified by `groupid`.
If it is a custom event set, the name is set to `Custom`.
"""
function get_name_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    name = unsafe_string(LibLikwid.nvmon_getGroupName(groupid))
    return name
end

"""
Return the short information about a performance group.
"""
function get_shortinfo_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    sinfo = unsafe_string(LibLikwid.nvmon_getGroupInfoShort(groupid))
    return sinfo
end

"""
Return the (long) description of a performance group.
"""
function get_longinfo_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    linfo = unsafe_string(LibLikwid.nvmon_getGroupInfoLong(groupid))
    return linfo
end

"""
Return the name of the event identified by `groupid` and `eventidx`.
"""
function get_name_of_event(groupid::Integer, eventidx::Integer)
    if !nvmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_eventidx(groupid, eventidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.nvmon_getEventName(groupid, eventidx))
    return name
end

"""
Return the name of the counter register identified by `groupid` and `eventidx`.
"""
function get_name_of_counter(groupid::Integer, eventidx::Integer)
    if !nvmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_eventidx(groupid, eventidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.nvmon_getCounterName(groupid, eventidx))
    return name
end

"""
Return the name of a derived metric identified by `groupid` and `metricidx`.
"""
function get_name_of_metric(groupid::Integer, metricidx::Integer)
    if !nvmon_initialized[] ||
       !_check_groupid(groupid) ||
       !_check_metricidx(groupid, metricidx)
        return nothing
    end
    name = unsafe_string(LibLikwid.nvmon_getMetricName(groupid, metricidx))
    return name
end

"""
Program the counter registers to measure all events in group `groupid`. Returns `true` on success.
"""
function setup_counters(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return false
    ret = LibLikwid.nvmon_setupCounters(groupid)
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
    return LibLikwid.nvmon_getIdOfActiveGroup()
end

"""
Switch currently active group to `groupid`. Returns `true` on success.
"""
function switch_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    groupid == get_id_of_active_group() && return true
    ret = LibLikwid.nvmon_switchActiveGroup(groupid)
    return ret == 0
end

"""
Return the raw counter register result of the last measurement cycle identified by group `groupid` and the indices for event `eventidx` and thread `threadidx`.
"""
function get_last_result(groupid::Integer, eventidx::Integer, threadidx::Integer)
    nvmon_initialized[] || return nothing
    _check_eventidx(groupid, eventidx) || return nothing
    _check_gpuid(threadidx) || return nothing
    res = LibLikwid.nvmon_getLastResult(groupid, eventidx, threadidx)
    return res
end

"""
Return the raw counter register result of all measurements identified by group `groupid` and the indices for event `eventidx` and thread `threadidx`.
"""
function get_result(groupid::Integer, eventidx::Integer, threadidx::Integer)
    nvmon_initialized[] || return nothing
    _check_eventidx(groupid, eventidx) || return nothing
    _check_gpuid(threadidx) || return nothing
    res = LibLikwid.nvmon_getResult(groupid, eventidx, threadidx)
    return res
end

"""
Return the derived metric result of all measurements identified by group `groupid` and the indices for metric `metricidx` and thread `threadidx`.
"""
function get_metric(groupid::Integer, metricidx::Integer, threadidx::Integer)
    nvmon_initialized[] || return nothing
    _check_metricidx(groupid, metricidx) || return nothing
    _check_gpuid(threadidx) || return nothing
    res = LibLikwid.nvmon_getMetric(groupid, metricidx, threadidx)
    return res
end

"""
Return the derived metric result of the last measurement cycle identified by group `groupid` and the indices for metric `metricidx` and thread `threadidx`.
"""
function get_last_metric(groupid::Integer, metricidx::Integer, threadidx::Integer)
    nvmon_initialized[] || return nothing
    _check_metricidx(groupid, metricidx) || return nothing
    _check_gpuid(threadidx) || return nothing
    res = LibLikwid.nvmon_getLastMetric(groupid, metricidx, threadidx)
    return res
end

"""
Return the measurement time for group identified by `groupid`.
"""
function get_time_of_group(groupid::Integer)
    nvmon_initialized[] || return nothing
    _check_groupid(groupid) || return nothing
    time = LibLikwid.nvmon_getTimeOfGroup(groupid)
    return time
end

end # module
