# Performance Monitoring (PerfMon)

The basis functionality of `likwid-perfctr`.

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfmon](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfmon).)

```julia
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
```

Running the above with `julia perfmon.jl` one obtains (modulo architectural differences):

```
OrderedCollections.OrderedDict{String, Float64} with 10 entries:
  "Runtime (RDTSC) [s]" => 0.447041
  "Runtime unhalted [s]" => 0.00339698
  "Clock [MHz]" => 4597.86
  "CPI" => 0.494021
  "DP [MFLOP/s]" => 59.5561
  "AVX DP [MFLOP/s]" => 0.0
  "AVX512 DP [MFLOP/s]" => 0.0
  "Packed [MUOPS/s]" => 29.778
  "Scalar [MUOPS/s]" => 7.82926e-5
  "Vectorization ratio" => 99.9997
OrderedCollections.OrderedDict{String, Float64} with 7 entries:
  "INSTR_RETIRED_ANY" => 2.47543e7
  "CPU_CLK_UNHALTED_CORE" => 1.22292e7
  "CPU_CLK_UNHALTED_REF" => 9.5751e6
  "FP_ARITH_INST_RETIRED_128B_PACKED_DOUBLE" => 1.3312e7
  "FP_ARITH_INST_RETIRED_SCALAR_DOUBLE" => 35.0
  "FP_ARITH_INST_RETIRED_256B_PACKED_DOUBLE" => 0.0
  "FP_ARITH_INST_RETIRED_512B_PACKED_DOUBLE" => 0.0
```

## Functions

```@autodocs
Modules = [LIKWID.PerfMon]
```