module Timer

using ..LIKWID: LibLikwid, timer_initialized

function init()
    ret = LibLikwid.timer_init()
    timer_initialized[] = true
    return true
end

function finalize()
    LibLikwid.timer_finalize()
    timer_initialized[] = false
    return nothing
end

"""
Return the CPU clock determined at `Timer.init()`.
"""
function get_cpu_clock()
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    return Int(LibLikwid.timer_getCpuClock())
end

"""
Return the current CPU clock read from sysfs
"""
function get_cpu_clock_current(cpu_id::Integer)
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    return Int(LibLikwid.timer_getCpuClockCurrent(cpu_id))
end

function start_clock()
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    timer = LibLikwid.TimerData()
    timer_ref = Ref(timer)
    LibLikwid.timer_start(timer_ref)
    return timer_ref[]
end

function stop_clock(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    timer_ref = Ref(timer)
    LibLikwid.timer_stop(timer_ref)
    return timer_ref[]
end

"""
Return the measured interval in seconds.
"""
function get_clock(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    return LibLikwid.timer_print(Ref(timer))
end

"""
Return the measured interval in cycles.
"""
function get_clock_cycles(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    if iszero(timer.start) || iszero(timer.stop)
        error("Start or stop is zero.")
    end
    return Int(LibLikwid.timer_printCycles(Ref(timer)))
end

end # module
