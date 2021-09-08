function init_timer()
    ret = LibLikwid.timer_init()
    # _timerinfo[] = unsafe_load(LibLikwid.get_timerTopology())
    # _build_jl_timer()
    timer_initialized[] = true
    return true
end

function finalize_timer()
    LibLikwid.timer_finalize()
    timer_initialized[] = false
    # _timerinfo[] = nothing
    return nothing
end

"""
Return the CPU clock determined at `init_timer()`.
"""
function get_cpu_clock()
    if !timer_initialized[]
        init_timer() || error("Couldn't init timer.")
    end
    return Int(LibLikwid.timer_getCpuClock())
end

"""
Return the current CPU clock read from sysfs
"""
function get_cpu_clock_current(cpu_id::Integer)
    if !timer_initialized[]
        init_timer() || error("Couldn't init timer.")
    end
    return Int(LibLikwid.timer_getCpuClockCurrent(cpu_id))
end

function start_clock()
    if !timer_initialized[]
        init_timer() || error("Couldn't init timer.")
    end
    timer = LibLikwid.TimerData()
    timer_ref = Ref(timer)
    LibLikwid.timer_start(timer_ref)
    return timer_ref[]
end

function stop_clock(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init_timer() || error("Couldn't init timer.")
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
        init_timer() || error("Couldn't init timer.")
    end
    return LibLikwid.timer_print(Ref(timer))
end

"""
Return the measured interval in cycles.
"""
function get_clock_cycles(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init_timer() || error("Couldn't init timer.")
    end
    if iszero(timer.start) || iszero(timer.stop)
        error("Start or stop is zero.")
    end
    return Int(LibLikwid.timer_printCycles(Ref(timer)))
end