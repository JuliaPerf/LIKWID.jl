```@meta
EditURL = "<unknown>/first.jl"
```

# Counting FLOPs

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

We measure the FLOPS_DP performance group, in which "DP" stands for "double precision".

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
  "Runtime (RDTSC) [s]" => 1.07912e-5
  "Runtime unhalted [s]" => 3.50774e-5
  "Clock [MHz]" => 3259.65
  "CPI" => 3.04448
  "DP [MFLOP/s]" => 926.684
````

````julia
events
````

````
OrderedCollections.OrderedDict{String, Float64} with 6 entries:
  "ACTUAL_CPU_CLOCK" => 85932.0
  "MAX_CPU_CLOCK" => 64582.0
  "RETIRED_INSTRUCTIONS" => 13668.0
  "CPU_CLOCKS_UNHALTED" => 41612.0
  "RETIRED_SSE_AVX_FLOPS_ALL" => 10000.0
  "MERGE" => 0.0
````

In particular, the event "RETIRED_SSE_AVX_FLOPS_ALL" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above

````julia
events["RETIRED_SSE_AVX_FLOPS_ALL"] == N
````

````
true
````

Feel free to play around and try monitoring other performance groups. To see which ones are supported on your system you can use [`PerfMon.supported_groups()`](@ref). This is what I get:

````julia
PerfMon.supported_groups()
````

````
18-element Vector{LIKWID.GroupInfoCompact}:
 ICACHE => Instruction cache miss rate/ratio
 ENERGY => Power and Energy consumption
 BRANCH => Branch prediction miss rate/ratio
 FLOPS_SP => Single Precision MFLOP/s
 L2CACHE => L2 cache miss rate/ratio (experimental)
 DATA => Load to store ratio
 CLOCK => Cycles per instruction
 CACHE => Data cache miss rate/ratio
 MEM2 => Main memory bandwidth in MBytes/s (channels 4-7)
 L3CACHE => L3 cache miss rate/ratio (experimental)
 CPI => Cycles per instruction
 MEM1 => Main memory bandwidth in MBytes/s (channels 0-3)
 L3 => L3 cache bandwidth in MBytes/s
 L2 => L2 cache bandwidth in MBytes/s (experimental)
 TLB => TLB miss rate/ratio
 FLOPS_DP => Double Precision MFLOP/s
 DIVIDE => Divide unit information
 NUMA => L2 cache bandwidth in MBytes/s (experimental)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

