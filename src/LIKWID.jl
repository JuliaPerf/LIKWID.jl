module LIKWID
   import Base.Threads

   const liblikwid = "liblikwid"
   include("LibLikwid.jl")

   const topo_initialized = Ref{Bool}(false)
   const numa_initialized = Ref{Bool}(false)
   const perfmon_initialized = Ref{Bool}(false)
   const timer_initialized = Ref{Bool}(false)
   const cpuinfo = Ref{Union{LibLikwid.CpuInfo_t, Ptr{Nothing}}}(C_NULL)
   const cputopo = Ref{Union{LibLikwid.CpuTopology_t, Ptr{Nothing}}}(C_NULL)
   const numainfo = Ref{Union{LibLikwid.NumaTopology_t, Ptr{Nothing}}}(C_NULL)

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
