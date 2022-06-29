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
PerfMon.init(cpu)
groupid = PerfMon.add_event_set("FLOPS_DP")
PerfMon.setup_counters(groupid)

PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
PerfMon.stop_counters()

mdict = PerfMon.get_metric_results(groupid, cpu)
display(mdict)
println(); flush(stdout);
edict = PerfMon.get_event_results(groupid, cpu)
display(edict)

PerfMon.finalize()
```

Running the above with `julia perfmon.jl` one obtains (modulo architectural differences):

```
OrderedCollections.OrderedDict{String, Float64} with 10 entries:
  "Runtime (RDTSC) [s]" => 0.695678
  "Runtime unhalted [s]" => 0.0014145
  "Clock [MHz]" => 1200.12
  "CPI" => 1.00722
  "DP [MFLOP/s]" => 38.2706
  "AVX DP [MFLOP/s]" => 38.2706
  "AVX512 DP [MFLOP/s]" => 38.2706
  "Packed [MUOPS/s]" => 4.78382
  "Scalar [MUOPS/s]" => 0.0
  "Vectorization ratio" => 100.0
OrderedCollections.OrderedDict{String, Float64} with 7 entries:
  "INSTR_RETIRED_ANY" => 4.63437e6
  "CPU_CLK_UNHALTED_CORE" => 4.66782e6
  "CPU_CLK_UNHALTED_REF" => 1.28352e7
  "FP_ARITH_INST_RETIRED_128B_PACKED_DOUBLE" => 0.0
  "FP_ARITH_INST_RETIRED_SCALAR_DOUBLE" => 0.0
  "FP_ARITH_INST_RETIRED_256B_PACKED_DOUBLE" => 0.0
  "FP_ARITH_INST_RETIRED_512B_PACKED_DOUBLE" => 3.328e6
```

## API

```@index
Pages   = ["perfmon.md"]
Order   = [:function, :macro, :type]
```

### Functions

```@autodocs
Modules = [LIKWID.PerfMon]
```

### Types

```@docs
LIKWID.GroupInfoCompact
```