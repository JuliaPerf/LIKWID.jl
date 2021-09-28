module HPM

using ..LIKWID: LibLikwid, access_initialized

"""
Sets the mode how the MSR and PCI registers should be accessed. Available options:
  * `0` or `LibLikwid.ACCESSMODE_DIRECT`: direct access (propably root priviledges required)
  * `1` or `LibLikwid.ACCESSMODE_DAEMON`: accesses through the access daemon
Must be called **before** [`HPM.init`](@ref).
"""
function mode(mode::Union{Integer, LibLikwid.AccessMode})
    if mode == LibLikwid.ACCESSMODE_DIRECT || mode == LibLikwid.ACCESSMODE_DAEMON
        LibLikwid.HPMmode(mode)
        return true
    end
    return false
end

"""
Initialize the access module internals to either the MSR/PCI files or the access daemon
"""
function init()
    err = LibLikwid.HPMinit()
    if err == 0
        access_initialized[] = true
        return true
    end
    return false
end

"""
Add the given CPU to the access module. This opens the commnunication to either the MSR/PCI files or the access daemon.
"""
function add_thread(cpuid)
    if !access_initialized[]
        return -1
    end
    ret = LibLikwid.HPMaddThread(cpuid)
    return Int(ret)
end

"""
Close the connections to the MSR/PCI files or the access daemon.
"""
function finalize()
    LibLikwid.HPMfinalize()
    access_initialized[] = false
    return nothing
end

end # module