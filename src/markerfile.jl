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
Return the region tag for the region identified by `ridx`.
"""
regiontag(ridx) = unsafe_string(LibLikwid.perfmon_getTagOfRegion(ridx))

"""
Return the group id for the region identified by `ridx`.
"""
regiongroup(ridx) = Int(LibLikwid.perfmon_getGroupOfRegion(ridx))

"""
Return the number of events of the region identified by `ridx`.
"""
regionevents(ridx) = Int(LibLikwid.perfmon_getEventsOfRegion(ridx))

"""
Return the number of threads of the region identified by `ridx`.
"""
regionthreads(ridx) = Int(LibLikwid.perfmon_getThreadsOfRegion(ridx))

"""
Return the accumulated measurement time for the region identified by `rid` and the thread index `tidx`.
"""
regiontime(ridx, tidx) = LibLikwid.perfmon_getTimeOfRegion(ridx, tidx)

"""
Return the call count for the region identified by `rid` and the thread index `tidx`.
"""
regioncount(ridx, tidx) = LibLikwid.perfmon_getCountOfRegion(ridx, tidx)

"""
Return the call count for the region identified by `ridx`, the event index `eidx` and the thread index `tidx`.
"""
regionresult(ridx, eidx, tidx) = LibLikwid.perfmon_getResultOfRegionThread(ridx, eidx, tidx)

"""
Return the call count for the region identified by `ridx`, the metric index `midx` and the thread index `tidx`.
"""
regionmetric(ridx, midx, tidx) = LibLikwid.perfmon_getMetricOfRegionThread(ridx, midx, tidx)

end # module
