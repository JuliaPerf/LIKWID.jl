<div align="center">
  <img width="390px" src="https://raw.githubusercontent.com/JuliaPerf/LIKWID.jl/main/docs/src/assets/logo_with_txt.svg">
</div>

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaperf.github.io/LIKWID.jl/dev/)
[![Build Status](https://github.com/JuliaPerf/LIKWID.jl/workflows/CI/badge.svg)](https://github.com/JuliaPerf/LIKWID.jl/actions)
[![Build Status](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/badges/main/pipeline.svg?key_text=CI+at+NHR@FAU&key_width=130)](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/-/pipelines)
[![codecov](https://codecov.io/gh/JuliaPerf/LIKWID.jl/branch/main/graph/badge.svg?token=Ze61CbGoO5)](https://codecov.io/gh/JuliaPerf/LIKWID.jl)
![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for [LIKWID](https://github.com/RRZE-HPC/likwid), in particular its [Marker API](https://github.com/RRZE-HPC/likwid/wiki/TutorialMarkerC).

## Installation

**Prerequisites:** You must have `likwid` installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)),

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```

## likwid-perfctr

### Marker API

The most important functions provided by LIKWID.jl are
* `LIKWID.Marker.startregion(::String)`
* `LIKWID.Marker.stopregion(::String)`

```julia
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

Then run `likwid-perfctr` with `--marker` like: `likwid-perfctr -C 0 -g FLOPS_DP --marker julia ...`.

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

## Resources

* [LIKWID](https://github.com/RRZE-HPC/likwid) / [LIKWID Performance Tools](https://hpc.fau.de/research/tools/likwid/)
* Most C-bindings have been autogenerated using [Clang.jl](https://github.com/JuliaInterop/Clang.jl)
* [pylikwid](https://github.com/RRZE-HPC/pylikwid): Python wrappers of LIKWID
