```@meta
EditURL = "<unknown>/first.jl"
```

# Hardware Performance Monitoring: The Very First Time

[TODO: Intro]

## Our computation

````julia
vecadd(a, b) = a .+ b
````

````
vecadd (generic function with 1 method)
````

Example: Perform `vecadd`

````julia
vecadd([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
````

````
3-element Vector{Float64}:
 5.0
 7.0
 9.0
````

## How many FLOPs does the CPU core perfom?
We expect the CPU to perform `N` additions, one for each element of the vectors.

## CPU, tell us how many FLOPs you've performed!
Set the problem size and initialize the vectors

````julia
const N = 10_000
const a = rand(N)
const b = rand(N);
nothing #hide
````

We will measure the FLOPS_DP performance group, in which "DP" stands for "double precision".

````julia
using LIKWID
metrics, events = @perfmon "FLOPS_DP" vecadd(a, b);
nothing #hide
````

Let's look at what we got

````julia
metrics
````

````
OrderedCollections.OrderedDict{String, Float64} with 5 entries:
  "Runtime (RDTSC) [s]" => 9.78097e-6
  "Runtime unhalted [s]" => 3.44214e-5
  "Clock [MHz]" => 3246.68
  "CPI" => 2.92655
  "DP [MFLOP/s]" => 1022.39
````

````julia
events
````

````
OrderedCollections.OrderedDict{String, Float64} with 6 entries:
  "ACTUAL_CPU_CLOCK" => 84324.0
  "MAX_CPU_CLOCK" => 63626.0
  "RETIRED_INSTRUCTIONS" => 13546.0
  "CPU_CLOCKS_UNHALTED" => 39643.0
  "RETIRED_SSE_AVX_FLOPS_ALL" => 10000.0
  "MERGE" => 0.0
````

In particular, the event "RETIRED_SSE_AVX_FLOPS_ALL" is the relevant one here. Note that it matches our expectation above

````julia
events["RETIRED_SSE_AVX_FLOPS_ALL"] == N
````

````
true
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

