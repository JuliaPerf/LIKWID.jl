module GPUMarker
    import ..LIKWID: liblikwid
    using Libdl

    function issupported()
        dlopen(liblikwid) do handle
            return !isnothing(dlsym(handle, :likwid_gpuMarkerInit; throw_error=false))
        end
    end

    function init()
        ccall((:likwid_gpuMarkerInit, liblikwid), Cvoid, ())
    end

    function threadinit()
        ccall((:likwid_gpuMarkerThreadInit, liblikwid), Cvoid, ())
    end

    function registerregion(regiontag)
        ccall((:likwid_gpuMarkerRegisterRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    function startregion(regiontag)
        ccall((:likwid_gpuMarkerStartRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    function stopregion(regiontag)
        ccall((:likwid_gpuMarkerStopRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    # markerGetRegion

    function nextgroup()
         ccall((:likwid_gpuMarkerNextGroup, liblikwid), Cvoid,())
    end

    function resetregion(regiontag)
        ccall((:likwid_gpuMarkerResetRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    function close()
        ccall((:likwid_gpuMarkerClose, liblikwid), Cvoid, ())
    end
end