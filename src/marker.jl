module Marker

using ..LIKWID: LibLikwid, PerfMon, capture_stderr!

"""
Initialize the Marker API. Must be called previous to all other functions.
"""
function init()
    LibLikwid.likwid_markerInit()
    Threads.@threads for i in 1:Threads.nthreads()
        LibLikwid.likwid_markerThreadInit()
    end
    return nothing
end

"""
Initialize the Marker API only on the main thread. `LIKWID.Marker.threadinit()` must be called manually.
"""
init_nothreads() = LibLikwid.likwid_markerInit()

"""
Add the current thread to the Marker API.
"""
threadinit() = LibLikwid.likwid_markerThreadInit()

"""
Register a region with name `regiontag` to the Marker API. On success, `true` is returned.

This is an optional function to reduce the overhead of region registration at `Marker.startregion`.
If you don't call `registerregion`, the registration is done at `startregion`.
"""
function registerregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerRegisterRegion(regiontag)
    return ret == 0
end

"""
Start measurements under the name `regiontag`. On success, `true` is returned.
"""
function startregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerStartRegion(regiontag)
    return ret == 0
end

"""
Stop measurements under the name `regiontag`. On success, `true` is returned.
"""
function stopregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerStopRegion(regiontag)
    return ret == 0
end

"""
    getregion(regiontag::AbstractString) -> nevents, events, time, count
Get the intermediate results of the region identified by `regiontag`. On success, it returns
    * `nevents`: the number of events in the current group,
    * `events`: a list with all the aggregated event results,
    * `time`: the measurement time for the region and
    * `count`: the number of calls.
"""
function getregion(regiontag::AbstractString)
    current_group = PerfMon.get_id_of_active_group()
    nevents = Ref(PerfMon.get_number_of_events(current_group))
    events = zeros(nevents[])
    time = Ref(0.0)
    count = Ref(Int32(0))
    LibLikwid.likwid_markerGetRegion(regiontag, nevents, events, time, count)
    return nevents[], events, time[], count[]
end

"""
Switch to the next event set in a round-robin fashion.
If you have set only one event set on the command line, this function performs no operation.
"""
nextgroup() = LibLikwid.likwid_markerNextGroup()

"""
Reset the values stored using the region name `regiontag`.
On success, `true` is returned.
"""
function resetregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerResetRegion(regiontag)
    return ret == 0
end

"""
Close the connection to the LIKWID Marker API and write out measurement data to file.
This file will be evaluated by `likwid-perfctr`.
"""
close() = LibLikwid.likwid_markerClose()

"""
Checks whether the Marker API is active, i.e. julia has been started under `likwid-perfctr -C ... -g ... -m`.
"""
function isactive()
    buf = IOBuffer()
    capture_stderr!(Marker.init, buf)
    s = String(take!(buf))
    return !startswith(s, "Running without Marker API")
end

end # module
