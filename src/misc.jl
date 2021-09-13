"""
Returns the ID of the currently executing CPU.
"""
get_processor_id() = Int(LibLikwid.likwid_getProcessorId())

"""
Returns the ID of the currently executing CPU via `glibc`s `sched_getcpu` function.
"""
get_processor_id_glibc() = Int(@ccall sched_getcpu()::Cint)

"""
Pins the current process to the CPU given as `cpuid`.
"""
function pinprocess(cpuid::Integer)
    ret = LibLikwid.likwid_pinProcess(cpuid)
    return ret == 0
end

"""
Pins the current thread to the CPU given as `cpuid`.
"""
function pinthread(cpuid::Integer)
    ret = LibLikwid.likwid_pinThread(cpuid)
    return ret == 0
end

"""
Set the verbosity level of the LIKWID library. Returns `true` on success.

Options are:
  * `LIKWID.LibLikwid.DEBUGLEV_ONLY_ERROR` or `0`

  * `LIKWID.LibLikwid.DEBUGLEV_INFO` or `1`

  * `LIKWID.LibLikwid.DEBUGLEV_DETAIL` or `2`

  * `LIKWID.LibLikwid.DEBUGLEV_DEVELOP` or `3`
"""
function setverbosity(verbosity::Integer)
    if verbosity ≥ LibLikwid.DEBUGLEV_ONLY_ERROR && verbosity ≤ LibLikwid.DEBUGLEV_DEVELOP
        LibLikwid.perfmon_setVerbosity(verbosity)
        return true        
    end
    return false
end