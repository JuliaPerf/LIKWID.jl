module MarkerFile

using ..LIKWID: LibLikwid

"""
Reads in the result file of an application run instrumented by the LIKWID Marker API.

*Note:* julia must have been started under `likwid-perfctr ... -m`.
"""
function read(fp::AbstractString)
    ret = LibLikwid.perfmon_readMarkerFile(fp)
    return ret ≥ 0
end

"""
Return the number of regions in an application run.
"""
numregions() = Int(LibLikwid.perfmon_getNumberOfRegions())

"""
Return the region tag for the region identified by `ridx` (starts at 1).
"""
regiontag(ridx) = unsafe_string(LibLikwid.perfmon_getTagOfRegion(ridx - 1))

"Return the tags of all available regions"
regions() = regiontag.(1:numregions())

"""
Return the group id for the region identified by `ridx` (starts at 1).
"""
regiongroup(ridx) = Int(LibLikwid.perfmon_getGroupOfRegion(ridx - 1)) + 1

"""
Return the number of events of the region identified by `ridx` (starts at 1).
"""
regionevents(ridx) = Int(LibLikwid.perfmon_getEventsOfRegion(ridx - 1))

"""
Return the number of metrics of the region identified by `ridx` (starts at 1).
"""
regionmetrics(ridx) = Int(LibLikwid.perfmon_getMetricsOfRegion(ridx - 1))

"""
Return the number of threads of the region identified by `ridx` (starts at 1).
"""
regionthreads(ridx) = Int(LibLikwid.perfmon_getThreadsOfRegion(ridx - 1))

"""
Return the accumulated measurement time for the region identified by `rid` and the thread index `tidx` (both starting at 1).
"""
regiontime(ridx, tidx) = LibLikwid.perfmon_getTimeOfRegion(ridx - 1, tidx - 1)

"""
Return the call count for the region identified by `rid` and the thread index `tidx` (both starting at 1).
"""
regioncount(ridx, tidx) = LibLikwid.perfmon_getCountOfRegion(ridx - 1, tidx - 1)

"""
Return the call count for the region identified by `ridx`, the event index `eidx` and the thread index `tidx` (all starting at 1).
"""
regionresult(ridx, eidx, tidx) = LibLikwid.perfmon_getResultOfRegionThread(ridx - 1, eidx - 1, tidx - 1)

"""
Return the call count for the region identified by `ridx`, the metric index `midx` and the thread index `tidx` (all starting at 1).
"""
regionmetric(ridx, midx, tidx) = LibLikwid.perfmon_getMetricOfRegionThread(ridx - 1, midx - 1, tidx - 1)

end # module
