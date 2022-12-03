module LIKWID
import Base.Threads
using Libdl
using Unitful
using OrderedCollections
using PrettyTables

export OrderedDict

# liblikwid
const liblikwid = "liblikwid"
include("LibLikwid.jl")

# Julia types
include("types.jl")

# Note: underscore prefix -> liblikwid API
const topo_initialized = Ref{Bool}(false)
const numa_initialized = Ref{Bool}(false)
const affinity_initialized = Ref{Bool}(false)
const timer_initialized = Ref{Bool}(false)
const power_initialized = Ref{Bool}(false)
const config_initialized = Ref{Bool}(false)
const access_initialized = Ref{Bool}(false)
const perfmon_initialized = Ref{Bool}(false)
const gputopo_initialized = Ref{Bool}(false)
const nvmon_initialized = Ref{Bool}(false)
const _cputopo = Ref{Union{LibLikwid.CpuTopology,Nothing}}(nothing) # (Julia) API struct
const cputopo = Ref{Union{CpuTopology,Nothing}}(nothing) # Julia struct
const _cpuinfo = Ref{Union{LibLikwid.CpuInfo,Nothing}}(nothing) # (Julia) API struct
const cpuinfo = Ref{Union{CpuInfo,Nothing}}(nothing) # Julia struct
const _numainfo = Ref{Union{LibLikwid.NumaTopology,Nothing}}(nothing) # (Julia) API struct
const numainfo = Ref{Union{NumaTopology,Nothing}}(nothing) # Julia struct
const _affinity = Ref{Union{LibLikwid.AffinityDomains,Nothing}}(nothing) # (Julia) API struct
const affinity = Ref{Union{AffinityDomains,Nothing}}(nothing) # Julia struct
const _powerinfo = Ref{Union{LibLikwid.PowerInfo,Nothing}}(nothing) # (Julia) API struct
const powerinfo = Ref{Union{PowerInfo,Nothing}}(nothing) # Julia struct
const _config = Ref{Union{LibLikwid.Likwid_Configuration,Nothing}}(nothing) # (Julia) API struct
const config = Ref{Union{Likwid_Configuration,Nothing}}(nothing) # Julia struct
const _gputopo = Ref{Union{LibLikwid.GpuTopology,Nothing}}(nothing) # (Julia) API struct
const gputopo = Ref{Union{GpuTopology,Nothing}}(nothing) # Julia struct

const likwid_gpusupport = Ref{Union{Nothing,Bool}}(nothing)

# functions
include("topology.jl")
include("numa.jl")
include("configuration.jl")
include("affinity.jl")
include("timer.jl")
include("thermal.jl")
include("power.jl")
include("access.jl")
include("prettyprinting.jl")
include("perfmon.jl")
import .PerfMon
import .PerfMon: perfmon, @perfmon
export PerfMon, perfmon, @perfmon
include("misc.jl")
include("markerfile.jl")
import .MarkerFile
export MarkerFile
include("marker.jl")
import .Marker
import .Marker: marker, @marker, @parallelmarker, perfmon_marker, @perfmon_marker
export Marker, marker, @marker, @parallelmarker, perfmon_marker, @perfmon_marker
include("topology_gpu.jl")
include("nvmon.jl")
import .NvMon
import .NvMon: nvmon, @nvmon
export NvMon, nvmon, @nvmon
include("marker_gpu.jl")
import .GPUMarker
import .GPUMarker: gpumarker, @gpumarker
export GPUMarker, gpumarker, @gpumarker
include("frequency.jl")

function __init__()
    if gpusupport()
        init_topology_gpu()
    end
    if accessmode() == LibLikwid.ACCESSMODE_PERF &&
        !haskey(ENV, "LIKWID_PERF_PID")
        pid = getpid()
        @debug "Setting environment variable LIKWID_PERF_PID" pid
        ENV["LIKWID_PERF_PID"] = pid
    end
    return nothing
end

function init(; gpu=false)
    Marker.init()
    init_topology()
    init_numa()
    init_affinity()
    PerfMon.init()
    Timer.init()
    if accessmode() == LibLikwid.ACCESSMODE_DAEMON
        HPM.init()
        Power.init()
        # init_thermal(0)
        Freq.init()
    end
    if gpu && gpusupport()
        GPUMarker.init()
        init_topology_gpu()
        NvMon.init()
    end
    return nothing
end

function finalize(; gpu=true)
    Marker.close()
    finalize_topology()
    finalize_numa()
    finalize_affinity()
    PerfMon.finalize()
    HPM.finalize()
    Timer.finalize()
    Power.finalize()
    Freq.finalize()
    if gpu && gpusupport()
        GPUMarker.close()
        finalize_topology_gpu()
        NvMon.finalize()
    end
    return nothing
end

end
