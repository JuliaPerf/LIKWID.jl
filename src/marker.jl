module Marker
    import ..LIKWID: liblikwid

    function init()
        ccall((:likwid_markerInit, liblikwid), Cvoid, ())
    end

    function threadinit()
        ccall((:likwid_markerThreadInit, liblikwid), Cvoid, ())
    end

    function registerregion(regiontag)
        ccall((:likwid_markerRegisterRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    function startregion(regiontag)
        ccall((:likwid_markerStartRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    function stopregion(regiontag)
        ccall((:likwid_markerStopRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    # markerGetRegion

    function nextgroup()
         ccall((:likwid_markerNextGroup, liblikwid), Cvoid,())
    end

    function resetregion(regiontag)
        ccall((:likwid_markerResetRegion, liblikwid),
               Cint, (Cstring,), regiontag)
    end

    function close()
        ccall((:likwid_markerClose, liblikwid), Cvoid, ())
    end
end