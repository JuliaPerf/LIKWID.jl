module Marker

using ..LIKWID: LibLikwid, PerfMon, capture_stderr!, get_processor_ids, LIKWID, MarkerFile, _print_markerfile

"""
Initialize the Marker API, assuming that julia is running under `likwid-perfctr`. Must be called previous to all other functions.
"""
function init(; N=Threads.nthreads())
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
Checks whether the Marker API is active, i.e. julia has been started under `likwid-perfctr -C ... -g ... -m`.
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

function prepare_marker_dynamic(groups; cpuids=get_processor_ids(), markerfile=joinpath(pwd(), "likwid.markerfile"), force=true, verbosity=0)
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

"""
    init_dynamic(group_or_groups; kwargs...)
Initialize the full Marker API from within the current Julia session (i.e. no `likwird-perfctr` necessary).
A performance group, e.g. "FLOPS_DP", must be provided as the first argument.
"""
function init_dynamic(group_or_groups; cpuids=get_processor_ids(), kwargs...)
    prepare_marker_dynamic(group_or_groups; cpuids, kwargs...)
    return init(; N=length(cpuids))
end

"""
    perfmon_marker(f, group_or_groups[; kwargs...])
Monitor performance groups in marked areas (see [`@marker`](@ref)) while executing the
given function `f` on one or multiple Julia threads. Note that
* `Marker.init_dynamic`, `Marker.init`, `Marker.close`, and `PerfMon.finalize` are called automatically
* the measurement of multiple performance groups is sequential and requires multiple executions of `f`!

**Keyword arguments:**
* `cpuids` (default: currently used CPU threads): specify the CPU threads (~ cores) to be monitored
* `autopin` (default: `true`): automatically pin Julia threads to the CPU threads (~ cores) they are currently running on (to avoid migration and wrong results).
* `keep` (default: `false`): keep the temporarily created marker file

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

"""
function perfmon_marker(f, group_or_groups; cpuids=get_processor_ids(), autopin=true, keep=false, kwargs...)
    cpuids = cpuids isa Integer ? [cpuids] : cpuids
    autopin && PerfMon._perfmon_autopin(cpuids)
    Marker.init_dynamic(group_or_groups; cpuids=cpuids, kwargs...)
    PerfMon.init(cpuids)
    markerfile = LIKWID.LIKWID_FILEPATH()
    isfile(markerfile) && rm(markerfile)
    groups = group_or_groups isa AbstractString ? (group_or_groups,) : group_or_groups
    for group in groups
        f()
        Marker.nextgroup()
    end
    Marker.close()
    _print_markerfile(markerfile)
    PerfMon.finalize()
    !keep && rm(markerfile)
    return nothing
end

"""
    @perfmon_marker group_or_groups codeblock

See also: [`perfmon_marker`](@ref)
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
