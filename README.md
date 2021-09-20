LIKWID.jl
=========

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
mul!(C, A, B)
LIKWID.Marker.stopregion("matmul")

LIKWID.Marker.close()
```

Then run `likwid-perfctr` with `--marker` like: `likwid-perfctr ... --marker julia ...`.

```
--------------------------------------------------------------------------------
CPU name:       AMD EPYC 7402 24-Core Processor                
CPU type:       AMD K17 (Zen2) architecture
CPU clock:      2.80 GHz
WARN: Linux kernel configured with paranoid level 2
WARN: Paranoid level 0 or root access is required to measure Uncore counters
Setup of event ACTUAL_CPU_CLOCK on CPU 0 failed: Permission denied
Setup of event MAX_CPU_CLOCK on CPU 0 failed: Permission denied
--------------------------------------------------------------------------------
WARN: Linux kernel configured with paranoid level 2
WARN: Paranoid level 0 or root access is required to measure Uncore counters
Setup of event ACTUAL_CPU_CLOCK on CPU 0 failed: Permission denied
Setup of event MAX_CPU_CLOCK on CPU 0 failed: Permission denied
--------------------------------------------------------------------------------
Region saxpy!, Group 1: FLOPS_SP
+-------------------+------------+
|    Region Info    | HWThread 0 |
+-------------------+------------+
| RDTSC Runtime [s] |   0.058149 |
|     call count    |          1 |
+-------------------+------------+

+---------------------------+---------+------------+
|           Event           | Counter | HWThread 0 |
+---------------------------+---------+------------+
|      ACTUAL_CPU_CLOCK     |  FIXC1  |          0 |
|       MAX_CPU_CLOCK       |  FIXC2  |          0 |
|    RETIRED_INSTRUCTIONS   |   PMC0  |   64520480 |
|    CPU_CLOCKS_UNHALTED    |   PMC1  |  189116300 |
| RETIRED_SSE_AVX_FLOPS_ALL |   PMC2  |  200000400 |
|           MERGE           |   PMC3  |          0 |
+---------------------------+---------+------------+

+----------------------+------------+
|        Metric        | HWThread 0 |
+----------------------+------------+
|  Runtime (RDTSC) [s] |     0.0581 |
| Runtime unhalted [s] |          0 |
|      Clock [MHz]     |      -     |
|          CPI         |     2.9311 |
|     SP [MFLOP/s]     |  3439.4605 |
+----------------------+------------+
```

## Resources

* [LIKWID](https://github.com/RRZE-HPC/likwid) / [LIKWID Performance Tools](https://hpc.fau.de/research/tools/likwid/)
* Most C-bindings have been autogenerated using [Clang.jl](https://github.com/JuliaInterop/Clang.jl)
