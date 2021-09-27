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

ncpus = 1
LIKWID.PerfMon.init([0])
groupid = LIKWID.PerfMon.add_event_set("FLOPS_DP")
LIKWID.PerfMon.setup_counters(groupid)

LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

d = LIKWID.PerfMon.get_metric_results(groupid, cpu)
display(d)
LIKWID.PerfMon.finalize()

# output

ERROR - [./src/power.c:power_init:288] Cannot read MSR TURBO_RATIO_LIMIT_CORES
cpu = 0
```

```@example
# perfmon.jl
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

# ncpus = LIKWID.get_cpu_topology().numCoresPerSocket
ncpus = 1
cpus = collect(0:ncpus-1)
LIKWID.PerfMon.init(cpus)
groupid = LIKWID.PerfMon.add_event_set("FLOPS_DP")
LIKWID.PerfMon.setup_counters(groupid)
LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

for cpu in cpus
    @show cpu
    d = LIKWID.PerfMon.get_metric_results(groupid, cpu)
    display(d)
    println()
    d = LIKWID.PerfMon.get_event_results(groupid, cpu)
    display(d)
    println()
end
LIKWID.PerfMon.finalize()
```

## Functions

```@autodocs
Modules = [LIKWID.PerfMon]
```

<!-- cpu = 0
OrderedCollections.OrderedDict{String, Float64} with 10 entries:
  "Runtime (RDTSC) [s]" => 0.0719716
  "Runtime unhalted [s]" => 0.0172482
  "Clock [MHz]" => 4585.47
  "CPI" => 1.83921
  "DP [MFLOP/s]" => 369.924
  "AVX DP [MFLOP/s]" => 0.0
  "AVX512 DP [MFLOP/s]" => 0.0
  "Packed [MUOPS/s]" => 184.962
  "Scalar [MUOPS/s]" => 0.0
  "Vectorization ratio" => 100.0
OrderedCollections.OrderedDict{String, Float64} with 7 entries:
  "INSTR_RETIRED_ANY" => 3.37623e7
  "CPU_CLK_UNHALTED_CORE" => 6.2096e7
  "CPU_CLK_UNHALTED_REF" => 4.87528e7
  "FP_ARITH_INST_RETIRED_128B_PACKED_DOUBLE" => 1.3312e7
  "FP_ARITH_INST_RETIRED_SCALAR_DOUBLE" => 0.0
  "FP_ARITH_INST_RETIRED_256B_PACKED_DOUBLE" => 0.0
  "FP_ARITH_INST_RETIRED_512B_PACKED_DOUBLE" => 0.0 -->