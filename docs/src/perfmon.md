# Performance Monitoring (PerfMon)

The basis functionality of `likwid-perfctr`.

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfmon](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfmon). Run as `julia perfmon.jl`.)

```jldoctest
# perfmon.jl
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

cpu = 0 # starts with zero!
LIKWID.PerfMon.init(cpu)
groupid = LIKWID.PerfMon.add_event_set("FLOPS_DP")
LIKWID.PerfMon.setup_counters(groupid)

LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

mdict = LIKWID.PerfMon.get_metric_results(groupid, cpu)
display(mdict)
println(); flush(stdout);
edict = LIKWID.PerfMon.get_event_results(groupid, cpu)
display(edict)

LIKWID.PerfMon.finalize()

# output

OrderedCollections.OrderedDict{String, Float64} with 10 entries:
  "Runtime (RDTSC) [s]"  => 0.721781
  "Runtime unhalted [s]" => 0.807824
  "Clock [MHz]"          => 3789.97
  "CPI"                  => 0.630098
  "DP [MFLOP/s]"         => 36.8887
  "AVX DP [MFLOP/s]"     => 36.8865
  "AVX512 DP [MFLOP/s]"  => 36.8865
  "Packed [MUOPS/s]"     => 4.61082
  "Scalar [MUOPS/s]"     => 0.00216963
  "Vectorization ratio"  => 99.953
```

## Functions

```@autodocs
Modules = [LIKWID.PerfMon]
```