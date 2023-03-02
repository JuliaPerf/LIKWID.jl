module Marker

using ..LIKWID: LibLikwid, PerfMon, capture_stderr!, get_processor_ids, LIKWID, MarkerFile,
                _print_markerfile

"""
Initialize the Marker API, assuming that julia is running under `likwid-perfctr`. Must be called previous to all other functions.
"""
function init(; N = Threads.nthreads())
    LibLikwid.likwid_markerInit()
    Threads.@threads :static for i in 1:N
        LibLikwid.likwid_markerThreadInit()
    end
    return nothing
end

"""
Initialize the Marker API only on the main thread (assuming that julia is running under `likwid-perfctr`). `LIKWID.Marker.threadinit()` must be called manually.
"""
init_nothreads() = LibLikwid.likwid_markerInit()

"""
Add the current thread to the Marker API.
"""
threadinit() = LibLikwid.likwid_markerThreadInit()

"""
Register a region with name `regiontag` to the Marker API. On success, `true` is returned.

This is an optional function to reduce the overhead of region registration at `Marker.startregion`.
If you don't call `registerregion`, the registration is done at `startregion`.
"""
function registerregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerRegisterRegion(regiontag)
    return ret == 0
end

"""
Start measurements under the name `regiontag`. On success, `true` is returned.
"""
function startregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerStartRegion(regiontag)
    return ret == 0
end

"""
Stop measurements under the name `regiontag`. On success, `true` is returned.
"""
function stopregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerStopRegion(regiontag)
    return ret == 0
end

"""
    getregion(regiontag::AbstractString, [num_events]) -> nevents, events, time, count
Get the intermediate results of the region identified by `regiontag`. On success, it returns
    * `nevents`: the number of events in the current group,
    * `events`: a list with all the aggregated event results,
    * `time`: the measurement time for the region and
    * `count`: the number of calls.
"""
function getregion(regiontag::AbstractString)
    current_group = PerfMon.get_id_of_active_group()
    return getregion(regiontag, PerfMon.get_number_of_events(current_group))
end

function getregion(regiontag::AbstractString, num_events::Integer)
    nevents = Ref(Int32(num_events))
    events = zeros(nevents[])
    time = Ref(0.0)
    count = Ref(Int32(0))
    LibLikwid.likwid_markerGetRegion(regiontag, nevents, events, time, count)
    return nevents[], events, time[], count[]
end

"""
Switch to the next event set in a round-robin fashion.
If you have set only one event set on the command line, this function performs no operation.
"""
nextgroup() = LibLikwid.likwid_markerNextGroup()

"""
Reset the values stored using the region name `regiontag`.
On success, `true` is returned.
"""
function resetregion(regiontag::AbstractString)
    ret = LibLikwid.likwid_markerResetRegion(regiontag)
    return ret == 0
end

"""
Close the connection to the LIKWID Marker API and write out measurement data to file.
This file will be evaluated by `likwid-perfctr`.
"""
close() = LibLikwid.likwid_markerClose()

"""
Checks whether the Marker API is active (by checking if the `LIKWID_MODE` environment variable has been set).
"""
isactive() = !isnothing(get(ENV, "LIKWID_MODE", nothing))

"""
    marker(f, regiontag::AbstractString)
Adds a LIKWID marker region around the execution of the given function `f` using [`Marker.startregion`](@ref),
[`Marker.stopregion`](@ref) under the hood.
Note that `LIKWID.Marker.init()` and `LIKWID.Marker.close()` must be called before and after, respectively.

# Examples
```julia
julia> using LIKWID

julia> Marker.init()

julia> marker("sleeping...") do
           sleep(1)
       end
true

julia> marker(()->rand(100), "create rand vec")
true

julia> Marker.close()

```
"""
function marker(f, regiontag::AbstractString)
    Marker.startregion(regiontag)
    f()
    return Marker.stopregion(regiontag)
end

"""
Convenience macro for flanking code with [`Marker.startregion`](@ref) and [`Marker.stopregion`](@ref).

# Examples
```julia
julia> using LIKWID

julia> Marker.init()

julia> @marker "sleeping..." sleep(1)
true

julia> @marker "create rand vec" rand(100)
true

julia> Marker.close()

```
"""
macro marker(regiontag, expr)
    q = quote
        LIKWID.Marker.startregion($regiontag)
        $(expr)
        LIKWID.Marker.stopregion($regiontag)
    end
    return esc(q)
end

"""
Convenience macro for flanking code with [`Marker.startregion`](@ref) and [`Marker.stopregion`](@ref) on all threads separately.

# Examples
```julia
julia> using LIKWID

julia> Marker.init()

julia> @parallelmarker begin
           Threads.@thread :static for i in 1:Threads.nthreads()
               # thread-local computation
           end
       end

julia> Marker.close()

```
"""
macro parallelmarker(regiontag, expr)
    q = quote
        Threads.@threads :static for i in 1:Threads.nthreads()
            LIKWID.Marker.startregion($regiontag)
        end
        $(expr)
        Threads.@threads :static for i in 1:Threads.nthreads()
            LIKWID.Marker.stopregion($regiontag)
        end
    end
    return esc(q)
end

function prepare_marker_dynamic(groups; cpuids = get_processor_ids(),
                                markerfile = joinpath(pwd(), "likwid.markerfile"),
                                force = true, verbosity = 0)
    LIKWID.clearenv()
    # the cpu threads to be considered
    if cpuids isa String
        cpustr = cpuids
    elseif cpuids isa Integer || (cpuids isa AbstractVector && eltype(cpuids) <: Integer)
        cpustr = join(cpuids, ",")
    else
        throw(ArgumentError("cpuids must be an integer, an abstract vector of integers, or a cpu string"))
    end
    LIKWID.LIKWID_THREADS(cpustr)
    # the location the marker file will be stored
    LIKWID.LIKWID_FILEPATH(markerfile)
    # Use the access daemon
    LIKWID.LIKWID_MODE(1) # TODO: use LIKWID.accessmode() here?
    # Overwrite registers (if they are in use)
    LIKWID.LIKWID_FORCE(force)
    # Debug level
    LIKWID.LIKWID_DEBUG(verbosity)
    # Events to measure
    if groups isa AbstractString
        groupsstr = groups
    elseif groups isa AbstractVector && eltype(groups) <: AbstractString
        groupsstr = join(groups, "|")
    else
        throw(ArgumentError("groups must be a string or a vector of strings"))
    end
    LIKWID.LIKWID_EVENTS(groupsstr)
    return nothing
end

function _save_env_vars()
    threads = get(ENV, "LIKWID_THREADS", nothing)
    fp = get(ENV, "LIKWID_FILEPATH", nothing)
    mode = get(ENV, "LIKWID_MODE", nothing)
    force = get(ENV, "LIKWID_FORCE", nothing)
    debug = get(ENV, "LIKWID_DEBUG", nothing)
    events = get(ENV, "LIKWID_EVENTS", nothing)
    return (threads, fp, mode, force, debug, events)
end

function _set_or_unset(key, value)
    if isnothing(value)
        delete!(ENV, key)
    else
        ENV[key] = value
    end
end

function _restore_env_vars(x)
    _set_or_unset("LIKWID_THREADS", x[1])
    _set_or_unset("LIKWID_FILEPATH", x[2])
    _set_or_unset("LIKWID_MODE", x[3])
    _set_or_unset("LIKWID_FORCE", x[4])
    _set_or_unset("LIKWID_DEBUG", x[5])
    _set_or_unset("LIKWID_EVENTS", x[6])
    return nothing
end

"""
    init_dynamic(group_or_groups; kwargs...)
Initialize the full Marker API from within the current Julia session (i.e. no `likwird-perfctr` necessary).
A performance group, e.g. "FLOPS_DP", must be provided as the first argument.
"""
function init_dynamic(group_or_groups; cpuids = get_processor_ids(), kwargs...)
    prepare_marker_dynamic(group_or_groups; cpuids, kwargs...)
    return init(; N = length(cpuids))
end

"""
    perfmon_marker(f, group_or_groups[; kwargs...])
Monitor performance groups in marked areas (see [`@marker`](@ref)) while executing the
given function `f` on one or multiple Julia threads.

**This is an experimental feature!**

Note that
* `Marker.init_dynamic`, `Marker.init`, `Marker.close`, and `PerfMon.finalize` are called automatically
* the measurement of multiple performance groups is sequential and requires multiple executions of `f`!

**Keyword arguments:**
* `cpuids` (default: currently used CPU threads): specify the CPU threads (~ cores) to be monitored
* `autopin` (default: `true`): automatically pin Julia threads to the CPU threads (~ cores) they are currently running on (to avoid migration and wrong results).
* `keep` (default: `false`): keep the temporarily created marker file

# Example
```julia
julia> using LIKWID

julia> perfmon_marker("FLOPS_DP") do
           # only the marked regions are monitored!
           NUM_FLOPS = 100_000_000
           a = 1.8
           b = 3.2
           c = 1.3
           @marker "calc_flops" for _ in 1:NUM_FLOPS
                c = a * b + c
            end
           z = a*b+c
           @marker "exponential" exp(z)
           sin(c)
       end

Region: calc_flops, Group: FLOPS_DP
┌───────────────────────────┬───────────┐
│                     Event │  Thread 1 │
├───────────────────────────┼───────────┤
│          ACTUAL_CPU_CLOCK │ 3.00577e8 │
│             MAX_CPU_CLOCK │ 2.08917e8 │
│      RETIRED_INSTRUCTIONS │ 3.00005e8 │
│       CPU_CLOCKS_UNHALTED │ 3.00067e8 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     1.0e8 │
│                     MERGE │       0.0 │
└───────────────────────────┴───────────┘
┌──────────────────────┬───────────┐
│               Metric │  Thread 1 │
├──────────────────────┼───────────┤
│  Runtime (RDTSC) [s] │ 0.0852431 │
│ Runtime unhalted [s] │  0.122687 │
│          Clock [MHz] │   3524.84 │
│                  CPI │   1.00021 │
│         DP [MFLOP/s] │   1173.12 │
└──────────────────────┴───────────┘

Region: exponential, Group: FLOPS_DP
┌───────────────────────────┬──────────┐
│                     Event │ Thread 1 │
├───────────────────────────┼──────────┤
│          ACTUAL_CPU_CLOCK │  85696.0 │
│             MAX_CPU_CLOCK │  59192.0 │
│      RETIRED_INSTRUCTIONS │   5072.0 │
│       CPU_CLOCKS_UNHALTED │   6013.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     27.0 │
│                     MERGE │      0.0 │
└───────────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 2.60005e-7 │
│ Runtime unhalted [s] │ 3.49786e-5 │
│          Clock [MHz] │    3546.95 │
│                  CPI │    1.18553 │
│         DP [MFLOP/s] │    103.844 │
└──────────────────────┴────────────┘

```
"""
function perfmon_marker(f, group_or_groups; cpuids = get_processor_ids(), autopin = true,
                        keep = false, print = true, kwargs...)
    cpuids = cpuids isa Integer ? [cpuids] : cpuids
    autopin && PerfMon._perfmon_autopin(cpuids)
    env_vars_before = _save_env_vars()
    Marker.init_dynamic(group_or_groups; cpuids = cpuids, kwargs...)
    PerfMon.init(cpuids)
    markerfile = LIKWID.LIKWID_FILEPATH()
    isfile(markerfile) && rm(markerfile)
    groups = group_or_groups isa AbstractString ? (group_or_groups,) : group_or_groups
    for group in groups
        f()
        Marker.nextgroup()
    end
    Marker.close()
    # PerfMon.finalize()
    # PerfMon.init(cpuids)
    print && _print_markerfile(markerfile)
    PerfMon.finalize()
    !keep && rm(markerfile)
    _restore_env_vars(env_vars_before)
    return nothing
end

"""
    @perfmon_marker group_or_groups codeblock

**This is an experimental feature!**

See also: [`perfmon_marker`](@ref)

# Example
```julia
julia> using LIKWID

julia> @perfmon_marker "FLOPS_DP" begin
           @marker "exponential" exp(3.141)
       end

Region: exponential, Group: FLOPS_DP
┌───────────────────────────┬──────────┐
│                     Event │ Thread 1 │
├───────────────────────────┼──────────┤
│          ACTUAL_CPU_CLOCK │ 115146.0 │
│             MAX_CPU_CLOCK │  78547.0 │
│      RETIRED_INSTRUCTIONS │   4208.0 │
│       CPU_CLOCKS_UNHALTED │   7112.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │     10.0 │
│                     MERGE │      0.0 │
└───────────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 3.02056e-8 │
│ Runtime unhalted [s] │ 4.70008e-5 │
│          Clock [MHz] │     3591.4 │
│                  CPI │    1.69011 │
│         DP [MFLOP/s] │    331.064 │
└──────────────────────┴────────────┘

```
"""
macro perfmon_marker(group_or_groups, expr)
    q = quote
        Marker.perfmon_marker($group_or_groups) do
            $(expr)
        end
    end
    return esc(q)
end

_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

end # module
