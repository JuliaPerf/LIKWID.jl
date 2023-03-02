module Timer

using ..LIKWID: LibLikwid, timer_initialized

"Initialize LIKWIDs timer module"
function init()
    ret = LibLikwid.timer_init()
    timer_initialized[] = true
    return true
end

"Close and finalize LIKWIDs timer module"
function finalize()
    LibLikwid.timer_finalize()
    timer_initialized[] = false
    return nothing
end

"""
Return the CPU clock determined at [`Timer.init()`](@ref).
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

"Start the clock and return a `LibLikwid.TimerData` object including the start timestamp."
function start_clock()
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    timer = LibLikwid.TimerData()
    timer_ref = Ref(timer)
    LibLikwid.timer_start(timer_ref)
    return timer_ref[]
end

"""
    stop_clock(timer::LibLikwid.TimerData) -> newtimer::LibLikwid.TimerData
Stop the clock and return a `LibLikwid.TimerData` object including the start and stop timestamps.
The input `timer` should be the output of [`Timer.start_clock()`](@ref).
"""
function stop_clock(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    timer_ref = Ref(timer)
    LibLikwid.timer_stop(timer_ref)
    return timer_ref[]
end

"""
    get_clock(timer::LibLikwid.TimerData)
Return the measured interval in seconds for the given `timer`.
The input `timer` should be the output of [`Timer.stop_clock`](@ref).
"""
function get_clock(timer::LibLikwid.TimerData)
    if !timer_initialized[]
        init() || error("Couldn't init timer.")
    end
    return LibLikwid.timer_print(Ref(timer))
end

"""
    get_clock_cycles(timer::LibLikwid.TimerData)
Return the measured interval in cycles for the given `timer`.
The input `timer` should be the output of [`Timer.stop_clock`](@ref).
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

"""
    timeit(f)
Time the given function `f` using [`Timer.start_clock`](@ref),
[`Timer.stop_clock`](@ref), etc. under the hood. Automatically
initializes and finalizes the timer module.

# Examples
```julia
julia> LIKWID.Timer.timeit() do
           sleep(1)
       end
(clock = 1.0008815780376372, cycles = 3603224844)
```
"""
function timeit(f)
    init() || error("Couldn't init LIKWIDs timer module.")
    try
        t_start = start_clock()
        f()
        t_stop = stop_clock(t_start)

        return (clock = get_clock(t_stop), cycles = get_clock_cycles(t_stop))
    finally
        finalize()
    end
end

"""
Convenience macro for [`Timer.timeit`](@ref).

# Examples
```julia
julia> LIKWID.Timer.@timeit sleep(1)
(clock = 1.0008815780376372, cycles = 3603224844)
```
"""
macro timeit(expr)
    q = quote
        LIKWID.Timer.timeit() do
            $(expr)
        end
    end
    return esc(q)
end

end # module
