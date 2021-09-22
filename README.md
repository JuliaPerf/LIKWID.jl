<div align="center">
  <img width="390px" src="https://raw.githubusercontent.com/JuliaPerf/LIKWID.jl/main/docs/src/assets/logo_with_txt.svg">
</div>

<br>

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaperf.github.io/LIKWID.jl/dev/)
[![Build Status](https://github.com/JuliaPerf/LIKWID.jl/workflows/CI/badge.svg)](https://github.com/JuliaPerf/LIKWID.jl/actions)
[![Build Status](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/badges/main/pipeline.svg?key_text=NHR@FAU&key_width=70)](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/-/pipelines)
[![codecov](https://codecov.io/gh/JuliaPerf/LIKWID.jl/branch/main/graph/badge.svg?token=Ze61CbGoO5)](https://codecov.io/gh/JuliaPerf/LIKWID.jl)
![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)

*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for the performance monitoring and benchmarking suite [LIKWID](https://github.com/RRZE-HPC/likwid).

## Installation

Prerequisites:
* You must have `likwid` installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)).
* **You must be running Linux.** (LIKWID doesn't support macOS or Windows.)

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```

## Documentation

Please check out [the documentation](https://juliaperf.github.io/LIKWID.jl/dev/) to learn how to use LIKWID.jl.

## Example: Marker API (CPU + GPU)

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr_saxpy](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr_saxpy).)

```julia
# saxpy.jl
using LIKWID
using CUDA
using LinearAlgebra

@assert CUDA.functional()

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

z_gpu = CUDA.zeros(Float32, N)
x_gpu = CUDA.rand(Float32, N)
y_gpu = CUDA.rand(Float32, N)

function saxpy_cpu!(z,a,x,y)
    z .= a .* x .+ y
end

function saxpy_gpu!(z,a,x,y)
    CUDA.@sync z .= a .* x .+ y
end

LIKWID.Marker.init()
LIKWID.GPUMarker.init()

saxpy_cpu!(z,a,x,y)
LIKWID.Marker.startregion("saxpy_cpu")
saxpy_cpu!(z,a,x,y)
LIKWID.Marker.stopregion("saxpy_cpu")

saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
LIKWID.GPUMarker.startregion("saxpy_gpu")
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
LIKWID.GPUMarker.stopregion("saxpy_gpu")

LIKWID.Marker.close()
LIKWID.GPUMarker.close()
```

Output of `likwid-perfctr -C 0 -g FLOPS_SP -G 0 -W FLOPS_SP -m julia --project=. saxpy.jl`:
```
INFO: You are running LIKWID in a cpuset with 1 CPUs. Taking given IDs as logical ID in cpuset
--------------------------------------------------------------------------------
CPU name:	Intel(R) Xeon(R) Silver 4114 CPU @ 2.20GHz
CPU type:	Intel Skylake SP processor
CPU clock:	2.20 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region saxpy_cpu, Group 1: FLOPS_SP
+-------------------+-------------+
|    Region Info    | HWThread 10 |
+-------------------+-------------+
| RDTSC Runtime [s] |    0.104644 |
|     call count    |           1 |
+-------------------+-------------+

+------------------------------------------+---------+-------------+
|                   Event                  | Counter | HWThread 10 |
+------------------------------------------+---------+-------------+
|             INSTR_RETIRED_ANY            |  FIXC0  |    60497320 |
|           CPU_CLK_UNHALTED_CORE          |  FIXC1  |   300657400 |
|           CPU_CLK_UNHALTED_REF           |  FIXC2  |   228230300 |
| FP_ARITH_INST_RETIRED_128B_PACKED_SINGLE |   PMC0  |           0 |
|    FP_ARITH_INST_RETIRED_SCALAR_SINGLE   |   PMC1  |         111 |
| FP_ARITH_INST_RETIRED_256B_PACKED_SINGLE |   PMC2  |    25000000 |
| FP_ARITH_INST_RETIRED_512B_PACKED_SINGLE |   PMC3  |           0 |
+------------------------------------------+---------+-------------+

+----------------------+-------------+
|        Metric        | HWThread 10 |
+----------------------+-------------+
|  Runtime (RDTSC) [s] |      0.1046 |
| Runtime unhalted [s] |      0.1367 |
|      Clock [MHz]     |   2897.9539 |
|          CPI         |      4.9698 |
|     SP [MFLOP/s]     |   1911.2503 |
|   AVX SP [MFLOP/s]   |   1911.2492 |
|  AVX512 SP [MFLOP/s] |           0 |
|   Packed [MUOPS/s]   |    238.9062 |
|   Scalar [MUOPS/s]   |      0.0011 |
|  Vectorization ratio |     99.9996 |
+----------------------+-------------+

Region saxpy_gpu, Group 1: FLOPS_SP
+-------------------+----------+
|    Region Info    |   GPU 0  |
+-------------------+----------+
| RDTSC Runtime [s] | 0.013071 |
|     call count    |        1 |
+-------------------+----------+

+----------------------------------------------------+---------+-----------+
|                        Event                       | Counter |   GPU 0   |
+----------------------------------------------------+---------+-----------+
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FADD_PRED_ON_SUM |   GPU0  |         0 |
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FMUL_PRED_ON_SUM |   GPU1  |         0 |
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM |   GPU2  | 100000000 |
+----------------------------------------------------+---------+-----------+

+---------------------+------------+
|        Metric       |    GPU 0   |
+---------------------+------------+
| Runtime (RDTSC) [s] |     0.0131 |
|     SP [MFLOP/s]    | 15300.8959 |
+---------------------+------------+
```

## Resources

* [LIKWID](https://github.com/RRZE-HPC/likwid) / [LIKWID Performance Tools](https://hpc.fau.de/research/tools/likwid/)
* Most C-bindings have been autogenerated using [Clang.jl](https://github.com/JuliaInterop/Clang.jl)
* [pylikwid](https://github.com/RRZE-HPC/pylikwid): Python wrappers of LIKWID
