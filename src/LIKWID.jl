module LIKWID
   import Base.Threads

   const liblikwid = "liblikwid"
   include("marker.jl")

   function getProcessorId()
      ccall((:likwid_getProcessorId, liblikwid), Cint, ())
   end

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
