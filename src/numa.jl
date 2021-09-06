function init_numa()
    ret = LibLikwid.numa_init()
    if ret == 0
        _numa_initialized[] = true
        return true
    end
    return false
end

function finalize_numa()
    LibLikwid.numa_finalize()
    _numa_initialized[] = false
    _numainfo[] = nothing
    return nothing
end