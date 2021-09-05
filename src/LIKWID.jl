module LIKWID
   import Base.Threads

   const liblikwid = "liblikwid"
   include("LibLikwid.jl")
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
