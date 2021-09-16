module LIKWID
   import Base.Threads
   using Libdl

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
   const _cputopo = Ref{Union{LibLikwid.CpuTopology, Nothing}}(nothing) # (Julia) API struct
   const cputopo = Ref{Union{CpuTopology, Nothing}}(nothing) # Julia struct
   const _cpuinfo = Ref{Union{LibLikwid.CpuInfo, Nothing}}(nothing) # (Julia) API struct
   const cpuinfo = Ref{Union{CpuInfo, Nothing}}(nothing) # Julia struct
   const _numainfo = Ref{Union{LibLikwid.NumaTopology, Nothing}}(nothing) # (Julia) API struct
   const numainfo = Ref{Union{NumaTopology, Nothing}}(nothing) # Julia struct
   const _affinity = Ref{Union{LibLikwid.AffinityDomains, Nothing}}(nothing) # (Julia) API struct
   const affinity = Ref{Union{AffinityDomains, Nothing}}(nothing) # Julia struct
   const _powerinfo = Ref{Union{LibLikwid.PowerInfo, Nothing}}(nothing) # (Julia) API struct
   const powerinfo = Ref{Union{PowerInfo, Nothing}}(nothing) # Julia struct
   const _config = Ref{Union{LibLikwid.Likwid_Configuration, Nothing}}(nothing) # (Julia) API struct
   const config = Ref{Union{Likwid_Configuration, Nothing}}(nothing) # Julia struct
   const _gputopo = Ref{Union{LibLikwid.GpuTopology, Nothing}}(nothing) # (Julia) API struct
   const gputopo = Ref{Union{GpuTopology, Nothing}}(nothing) # Julia struct

   const likwid_gpusupport = Ref{Union{Nothing, Bool}}(nothing)

   # functions
   include("topology.jl")
   include("numa.jl")
   include("configuration.jl")
   include("affinity.jl")
   include("timer.jl")
   include("thermal.jl")
   include("power.jl")
   include("access.jl")
   include("perfmon.jl")
   include("marker.jl")
   include("markerfile.jl")
   include("misc.jl")
   include("topology_gpu.jl")
   include("nvmon.jl")
   include("marker_gpu.jl")

   function init()
      Marker.init()
      Threads.@threads for i in 1:Threads.nthreads()
         Marker.threadinit()
      end
      gpusupport() && GPUMarker.init()
      init_topology()
      init_numa()
      init_perfmon()
      return nothing
   end
   
   function __init__()
      init()
      atexit() do
         Marker.close()
         gpusupport() && GPUMarker.close()
      end
   end
end
