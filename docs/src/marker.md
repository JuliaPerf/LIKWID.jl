# Marker API (CPU)

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr).)

```julia
# perfctr.jl
using LIKWID
using LinearAlgebra

LIKWID.Marker.init()

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

LIKWID.Marker.startregion("matmul")
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.Marker.stopregion("matmul")

LIKWID.Marker.close()
```

Running this file with the command `likwid-perfctr -C 0 -g FLOPS_DP -m julia perfctr.jl` one should obtain something like the following:
```
--------------------------------------------------------------------------------
CPU name:	11th Gen Intel(R) Core(TM) i7-11700K @ 3.60GHz
CPU type:	Intel Rocketlake processor
CPU clock:	3.60 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region matmul, Group 1: FLOPS_DP
+-------------------+------------+
|    Region Info    | HWThread 0 |
+-------------------+------------+
| RDTSC Runtime [s] |   0.465348 |
|     call count    |          1 |
+-------------------+------------+

+------------------------------------------+---------+------------+
|                   Event                  | Counter | HWThread 0 |
+------------------------------------------+---------+------------+
|             INSTR_RETIRED_ANY            |  FIXC0  | 4414042000 |
|           CPU_CLK_UNHALTED_CORE          |  FIXC1  | 2237935000 |
|           CPU_CLK_UNHALTED_REF           |  FIXC2  | 1648606000 |
| FP_ARITH_INST_RETIRED_128B_PACKED_DOUBLE |   PMC0  |  106496000 |
|    FP_ARITH_INST_RETIRED_SCALAR_DOUBLE   |   PMC1  |        569 |
| FP_ARITH_INST_RETIRED_256B_PACKED_DOUBLE |   PMC2  |          0 |
| FP_ARITH_INST_RETIRED_512B_PACKED_DOUBLE |   PMC3  |          0 |
+------------------------------------------+---------+------------+

+----------------------+------------+
|        Metric        | HWThread 0 |
+----------------------+------------+
|  Runtime (RDTSC) [s] |     0.4653 |
| Runtime unhalted [s] |     0.6217 |
|      Clock [MHz]     |  4886.7513 |
|          CPI         |     0.5070 |
|     DP [MFLOP/s]     |   457.7061 |
|   AVX DP [MFLOP/s]   |          0 |
|  AVX512 DP [MFLOP/s] |          0 |
|   Packed [MUOPS/s]   |   228.8524 |
|   Scalar [MUOPS/s]   |     0.0012 |
|  Vectorization ratio |    99.9995 |
+----------------------+------------+
```

**Sidenote**: Given the absence of AVX calls, it seems like OpenBLAS is falling back to a suboptimal Nehalem kernel. If we install [MKL.jl](https://github.com/JuliaLinearAlgebra/MKL.jl) and add `using MKL` to the top of our script above, the metrics table becomes

```
+----------------------+------------+
|        Metric        | HWThread 0 |
+----------------------+------------+
|  Runtime (RDTSC) [s] |     0.4599 |
| Runtime unhalted [s] |     0.6065 |
|      Clock [MHz]     |  4888.9102 |
|          CPI         |     0.5145 |
|     DP [MFLOP/s]     |   459.6089 |
|   AVX DP [MFLOP/s]   |   459.6080 |
|  AVX512 DP [MFLOP/s] |   459.6080 |
|   Packed [MUOPS/s]   |    57.4510 |
|   Scalar [MUOPS/s]   |     0.0008 |
|  Vectorization ratio |    99.9986 |
+----------------------+------------+
```

<!-- ## Most important Functions

```@docs
LIKWID.Marker.init()
LIKWID.Marker.startregion(regiontag::AbstractString)
LIKWID.Marker.stopregion(regiontag::AbstractString)
LIKWID.Marker.close()
``` -->

## `likwid-perfctr` in a nutshell

**Most importantly**, you need to use the `-m` option to activate the marker API.

To list the available performance groups, run `likwid-perfctr -a`:
```
Group name      Description
--------------------------------------------------------------------------------
     DATA       Load to store ratio
 FLOPS_DP       Double Precision MFLOP/s
   BRANCH       Branch prediction miss rate/ratio
   ENERGY       Power and Energy consumption
FLOPS_AVX       Packed AVX MFLOP/s
   DIVIDE       Divide unit information
 FLOPS_SP       Single Precision MFLOP/s
      TMA       Top down cycle allocation
```
These groups can be passed to the command line option `-g`.

Another important option is `-C <list>`:
> Processor ids to pin threads and measure, e.g. 1,2-4,8. For information about the `<list>` syntax, see `likwid-pin`.
Note that cpu ids start with zero (not one).

Combinding the points above, the full command could look like this: `likwid-perfctr -C 0 -g FLOPS_DP -m julia`.

For more information, check out the [official documentation](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr).

## Functions

```@autodocs
Modules = [LIKWID.Marker]
```
