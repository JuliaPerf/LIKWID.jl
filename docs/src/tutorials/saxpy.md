```@meta
EditURL = "<unknown>/saxpy.jl"
```

# Monitoring SAXPY on CPU and GPU

[TODO: Intro]

## Our computation
Single-precision (i.e. `Float32`) `a` times `x` plus y (SAXPY):
$$ z = a * x + y $$

Set the problem size and initialize the vectors

````julia
const N = 10_000
const a = 3.141
const x = rand(Float32, N)
const y = rand(Float32, N)
const z = zeros(Float32, N);
nothing #hide
````

## How many FLOPs?
The multiply and plus operations correspond to one FLOP each and we to `N` of those in total.

````julia
2 * N
````

````
20000
````

## CPU, tell us how many FLOPs you've performed!
We measure the FLOPS_SP performance group, in which "SP" stands for "single precision".

````julia
using LIKWID
metrics, events = @perfmon "FLOPS_SP" z .= a .* x .+ y;
nothing #hide
````

Let's look at what we got

````julia
metrics
````

````
OrderedCollections.OrderedDict{String, Float64} with 5 entries:
  "Runtime (RDTSC) [s]" => 7.32065e-6
  "Runtime unhalted [s]" => 2.86454e-5
  "Clock [MHz]" => 2695.71
  "CPI" => 1.34868
  "SP [MFLOP/s]" => 2732.0
````

````julia
events
````

````
OrderedCollections.OrderedDict{String, Float64} with 6 entries:
  "ACTUAL_CPU_CLOCK" => 70175.0
  "MAX_CPU_CLOCK" => 63773.0
  "RETIRED_INSTRUCTIONS" => 20130.0
  "CPU_CLOCKS_UNHALTED" => 27149.0
  "RETIRED_SSE_AVX_FLOPS_ALL" => 20000.0
  "MERGE" => 0.0
````

In particular, the event "RETIRED_SSE_AVX_FLOPS_ALL" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above

````julia
events["RETIRED_SSE_AVX_FLOPS_ALL"] == 2*N
````

````
true
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

