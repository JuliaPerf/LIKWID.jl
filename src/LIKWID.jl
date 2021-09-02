module LIKWID
   import Base.Threads

   const liblikwid = "liblikwid"
   include("marker.jl")
   include("gpu_marker.jl")

   function getProcessorId()
      ccall((:likwid_getProcessorId, liblikwid), Cint, ())
   end

   function __init__()
      Marker.init()
      GPUMarker.issupported() && GPUMarker.init()
      Threads.@threads for i in 1:Threads.nthreads()
         Marker.threadinit()
      end
      atexit() do
         Marker.close()
         GPUMarker.issupported() && GPUMarker.close()
      end
   end
end
