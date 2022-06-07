```@meta
EditURL = "<unknown>/saxpy.jl"
```

# Counting FLOPS: SAXPY

[TODO: Intro]

````julia
Threads.nthreads()
````

````
4
````

## Single-threaded
### Our computation
Single-precision (i.e. `Float32`) `a` times `x` plus y (SAXPY):
$$ z = a \cdot x + y $$

Set the problem size and initialize the vectors

````julia
const N = 10_000
const a = 3.141
const x = rand(Float32, N)
const y = rand(Float32, N)
const z = zeros(Float32, N);
nothing #hide
````

#### How many FLOPS?
The multiply and plus operations correspond to one FLOP each and we to `N` of those in total.

````julia
2 * N
````

````
20000
````

### CPU, tell us how many FLOPS you've performed!
We measure the FLOPS_SP performance group, in which "SP" stands for "single precision".

````julia
using LIKWID
metrics, events = @perfmon "FLOPS_SP" begin
    z .= a .* x .+ y
end;
nothing #hide
````

Note that while the computation itself is single-threaded `@perfmon` automatically monitors all Julia threads and the returned `metrics` and `events` are vectors.

````julia
metrics
````

````
4-element Vector{OrderedCollections.OrderedDict{String, Float64}}:
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.60034766051643e-6, "Runtime unhalted [s]" => 0.00033270201423170505, "Clock [MHz]" => 3477.4045029176364, "CPI" => 1.4240179265559976, "SP [MFLOP/s]" => 3030.1434149659844)
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.60034766051643e-6, "Runtime unhalted [s]" => 4.18479185439693e-5, "Clock [MHz]" => 1819.605961159614, "CPI" => NaN, "SP [MFLOP/s]" => 0.0)
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.60034766051643e-6, "Runtime unhalted [s]" => 4.34251444784409e-5, "Clock [MHz]" => 2842.8443607258373, "CPI" => NaN, "SP [MFLOP/s]" => 0.0)
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.60034766051643e-6, "Runtime unhalted [s]" => 3.945064941530685e-5, "Clock [MHz]" => 1929.0358595256655, "CPI" => NaN, "SP [MFLOP/s]" => 0.0)
````

````julia
events
````

````
4-element Vector{OrderedCollections.OrderedDict{String, Float64}}:
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 815077.0, "MAX_CPU_CLOCK" => 574231.0, "RETIRED_INSTRUCTIONS" => 21867.0, "CPU_CLOCKS_UNHALTED" => 31139.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 20000.0, "MERGE" => 0.0)
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 102522.0, "MAX_CPU_CLOCK" => 138033.0, "RETIRED_INSTRUCTIONS" => 0.0, "CPU_CLOCKS_UNHALTED" => 0.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 0.0, "MERGE" => 0.0)
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 106386.0, "MAX_CPU_CLOCK" => 91680.0, "RETIRED_INSTRUCTIONS" => 0.0, "CPU_CLOCKS_UNHALTED" => 0.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 0.0, "MERGE" => 0.0)
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 96649.0, "MAX_CPU_CLOCK" => 122744.0, "RETIRED_INSTRUCTIONS" => 0.0, "CPU_CLOCKS_UNHALTED" => 0.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 0.0, "MERGE" => 0.0)
````

Extracting the results for the relevant event "RETIRED\_SSE\_AVX\_FLOPS\_ALL" for all threads gives us.

````julia
FLOPS_per_thread = getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL")
````

````
4-element Vector{Float64}:
 20000.0
     0.0
     0.0
     0.0
````

This matches our expectation from above, i.e.

````julia
FLOPS_per_thread[1] == 2 * N
````

````
true
````

[TODO: make info box] As an alternative to monitoring all Julia threads, we could have used the functional form `perfmon` to only consider the main thread.

````julia
LIKWID.pinthread(0)
metrics, events = perfmon("FLOPS_SP"; cpuids=[0], autopin=false) do
    z .= a .* x .+ y
end;
nothing #hide
````

## Multi-threaded

````julia
using LIKWID
metrics, events = @perfmon "FLOPS_SP" begin
    Threads.@threads for i in eachindex(x, y, z)
        z[i] = a * x[i] + y[i]
    end
end;
nothing #hide
````

````julia
FLOPS_per_thread = getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL")
````

````
4-element Vector{Float64}:
 6016.0
 5000.0
 5000.0
 5000.0
````

Note that `sum(FLOPS_per_thread) > N` since the multithreading itself has some overhead.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

