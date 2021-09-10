function hpmmode(mode::Union{Integer, LibLikwid.AccessMode})
    if mode == LibLikwid.ACCESSMODE_DIRECT || mode == LibLikwid.ACCESSMODE_DAEMON
        LibLikwid.HPMmode(mode)
        return true
    end
    return false
end

function init_hpm()
    err = LibLikwid.HPMinit()
    if err == 0
        access_initialized[] = true
        return true
    end
    return false
end

function hpm_add_thread(cpuid)
    if !access_initialized[]
        return -1
    end
    ret = LibLikwid.HPMaddThread(cpuid)
    return Int(ret)
end

function finalize_hpm()
    LibLikwid.HPMfinalize()
    access_initialized[] = false
    return nothing
end