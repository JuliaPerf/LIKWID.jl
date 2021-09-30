module GPUMarker

using ..LIKWID: LibLikwid, NvMon, gpusupport, capture_stderr!

"""
Initialize the NvMon Marker API of the LIKWID library. Must be called previous to all other functions.
"""
function init()
    gpusupport() || error(
        "liblikwid hasn't been compiled with GPU support (i.e. `NVIDIA_INTERFACE=true`).",
    )
    return LibLikwid.likwid_gpuMarkerInit()
end

"""
Register a region with name `regiontag` to the GPU Marker API. On success, `true` is returned.

This is an optional function to reduce the overhead of region registration at `Marker.startregion`.
If you don't call `registerregion`, the registration is done at `startregion`.
"""
function registerregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_gpuMarkerRegisterRegion(regiontag)
    return ret == 0
end

"""
Start measurements under the name `regiontag`. On success, `true` is returned.
"""
function startregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_gpuMarkerStartRegion(regiontag)
    return ret == 0
end

"""
Stop measurements under the name `regiontag`. On success, `true` is returned.
"""
function stopregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_gpuMarkerStopRegion(regiontag)
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
    current_group = NvMon.get_id_of_active_group()
    nevents = Ref(NvMon.get_number_of_events(current_group))
    events_ref = Ref{Ptr{Float64}}()
    time = Ref(0.0)
    count = Ref(Int32(0))
    ngpus = Ref(Int32(0))
    LibLikwid.likwid_gpuMarkerGetRegion(regiontag, ngpus, nevents, events_ref, time, count)
    events = unsafe_wrap(Array, events_ref[], nevents[])
    return ngpus[], nevents[], events, time[], count[]
end

"""
Switch to the next event set in a round-robin fashion.
If you have set only one event set on the command line, this function performs no operation.
"""
nextgroup() = LibLikwid.likwid_gpuMarkerNextGroup()

"""
Reset the values stored using the region name `regiontag`.
On success, `true` is returned.
"""
function resetregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_gpuMarkerResetRegion(regiontag)
    return ret == 0
end

"""
Close the connection to the LIKWID GPU Marker API and write out measurement data to file.
This file will be evaluated by `likwid-perfctr`.
"""
close() = LibLikwid.likwid_gpuMarkerClose()

"""
Checks whether the NVIDIA GPU Marker API is active, i.e. julia has been started under `likwid-perfctr -G ... -W ... -m`.
"""
function isactive()
    buf = IOBuffer()
    capture_stderr!(GPUMarker.init, buf)
    s = String(take!(buf))
    return !startswith(s, "Running without GPU Marker API")
end

"""
    gpuregion(f, regiontag::AbstractString)
Adds a LIKWID GPU marker region around the execution of the given function `f` using [`GPUMarker.startregion`](@ref),
[`GPUMarker.stopregion`](@ref) under the hood.
Note that `LIKWID.GPUMarker.init()` and `LIKWID.GPUMarker.close()` must be called before and after, respectively.

# Examples
```julia
julia> using LIKWID, CUDA

julia> GPUMarker.init()

julia> gpuregion("sleeping...") do
           sleep(1)
       end
true

julia> gpuregion(()->CUDA.rand(100), "create rand vec")
true

julia> GPUMarker.close()

```
"""
function gpuregion(f, regiontag::AbstractString)
    GPUMarker.startregion(regiontag)
    f()
    return GPUMarker.stopregion(regiontag)
end

"""
Convenience macro for flanking code with [`GPUMarker.startregion`](@ref) and [`GPUMarker.stopregion`](@ref).

# Examples
```julia
julia> using LIKWID, CUDA

julia> GPUMarker.init()

julia> @gpuregion "sleeping..." sleep(1)
true

julia> @gpuregion "create rand vec" CUDA.rand(100)
true

julia> GPUMarker.close()

```
"""
macro gpuregion(regiontag, expr)
    q = quote
        LIKWID.GPUMarker.startregion($regiontag)
        $(expr)
        LIKWID.GPUMarker.stopregion($regiontag)
    end
    return esc(q)
end

end # module
