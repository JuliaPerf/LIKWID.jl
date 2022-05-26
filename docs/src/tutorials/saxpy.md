```@meta
EditURL = "<unknown>/saxpy.jl"
```

# Monitoring SAXPY on CPU(s)

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

#### How many FLOPs?
The multiply and plus operations correspond to one FLOP each and we to `N` of those in total.

````julia
2 * N
````

````
20000
````

### CPU, tell us how many FLOPs you've performed!
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
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.42058070876704e-6, "Runtime unhalted [s]" => 0.00027285937261553383, "Clock [MHz]" => 3497.564325277362, "CPI" => 1.3565646865139251, "SP [MFLOP/s]" => 3114.9830377010635)
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.42058070876704e-6, "Runtime unhalted [s]" => 4.660217411253345e-5, "Clock [MHz]" => 2979.0476574613103, "CPI" => NaN, "SP [MFLOP/s]" => 0.0)
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.42058070876704e-6, "Runtime unhalted [s]" => 4.337820905195631e-5, "Clock [MHz]" => 2846.418638904804, "CPI" => NaN, "SP [MFLOP/s]" => 0.0)
 OrderedCollections.OrderedDict("Runtime (RDTSC) [s]" => 6.42058070876704e-6, "Runtime unhalted [s]" => 4.519551627526467e-5, "Clock [MHz]" => 2970.4096435000356, "CPI" => NaN, "SP [MFLOP/s]" => 0.0)
````

````julia
events
````

````
4-element Vector{OrderedCollections.OrderedDict{String, Float64}}:
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 668445.0, "MAX_CPU_CLOCK" => 468195.0, "RETIRED_INSTRUCTIONS" => 21867.0, "CPU_CLOCKS_UNHALTED" => 29664.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 20000.0, "MERGE" => 0.0)
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 114165.0, "MAX_CPU_CLOCK" => 93882.0, "RETIRED_INSTRUCTIONS" => 0.0, "CPU_CLOCKS_UNHALTED" => 0.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 0.0, "MERGE" => 0.0)
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 106267.0, "MAX_CPU_CLOCK" => 91459.0, "RETIRED_INSTRUCTIONS" => 0.0, "CPU_CLOCKS_UNHALTED" => 0.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 0.0, "MERGE" => 0.0)
 OrderedCollections.OrderedDict("ACTUAL_CPU_CLOCK" => 110719.0, "MAX_CPU_CLOCK" => 91313.0, "RETIRED_INSTRUCTIONS" => 0.0, "CPU_CLOCKS_UNHALTED" => 0.0, "RETIRED_SSE_AVX_FLOPS_ALL" => 0.0, "MERGE" => 0.0)
````

Extracting the results for the relevant event "RETIRED_SSE_AVX_FLOPS_ALL" for all threads gives us.

````julia
flops_per_thread = getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL")
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
flops_per_thread[1] == 2 * N
````

````
true
````

[TODO: make info box] As an alternative to monitoring all Julia threads, we could have used the functional form `perfmon` to only consider the main thread.

````julia
using LIKWID
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
flops_per_thread = getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL")
````

````
4-element Vector{Float64}:
 6016.0
 5000.0
 5000.0
 5000.0
````

Note that

````julia
sum(flops_per_thread) > N
````

````
true
````

due to the overhead by the multithreading itself.

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

