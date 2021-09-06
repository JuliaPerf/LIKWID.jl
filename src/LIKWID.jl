module LIKWID
   import Base.Threads

   # liblikwid
   const liblikwid = "liblikwid"
   include("LibLikwid.jl")

   # Julia types
   include("types.jl")

   # Note: underscore prefix -> liblikwid API
   const _perfmon_initialized = Ref{Bool}(false)
   const _timer_initialized = Ref{Bool}(false)
   const _numa_initialized = Ref{Bool}(false) # NUMA module of liblikwid
   const _numainfo = Ref{Union{LibLikwid.NumaTopology, Nothing}}(nothing) # (Julia) API struct
   const _topo_initialized = Ref{Bool}(false) # Topo module of liblikwid
   const cputopo = Ref{Union{CpuTopology, Nothing}}(nothing) # Julia struct
   const _cputopo = Ref{Union{LibLikwid.CpuTopology, Nothing}}(nothing) # (Julia) API struct
   const cpuinfo = Ref{Union{LibLikwid.CpuInfo, Nothing}}(nothing)

   # functions
   include("numa.jl")
   include("topology.jl")
   include("marker.jl")
   
   function __init__()
      Marker.init()
      Threads.@threads for i in 1:Threads.nthreads()
         Marker.threadinit()
      end
      atexit() do
         Marker.close()
      end
   end
end
