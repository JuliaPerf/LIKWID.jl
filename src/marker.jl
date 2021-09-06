module Marker
    import ..LIKWID: LibLikwid

    init() = LibLikwid.likwid_markerInit()
    threadinit() = LibLikwid.likwid_markerThreadInit()
    registerregion(regiontag) = LibLikwid.likwid_markerRegisterRegion(regiontag)
    startregion(regiontag) = LibLikwid.likwid_markerStartRegion(regiontag)
    stopregion(regiontag) = LibLikwid.likwid_markerStopRegion(regiontag)
    # markerGetRegion
    nextgroup() = LibLikwid.likwid_markerNextGroup()
    resetregion(regiontag) = LibLikwid.likwid_markerResetRegion(regiontag)
    close() = LibLikwid.likwid_markerClose()    
end