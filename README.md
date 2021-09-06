# LIKWID.jl

[![Build Status](https://github.com/JuliaPerf/LIKWID.jl/workflows/CI/badge.svg)](https://github.com/JuliaPerf/LIKWID.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaPerf/LIKWID.jl/branch/master/graph/badge.svg?token=Ze61CbGoO5)](https://codecov.io/gh/JuliaPerf/LIKWID.jl)

*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for [LIKWID](https://github.com/RRZE-HPC/likwid), in particular its [Marker API](https://github.com/RRZE-HPC/likwid/wiki/TutorialMarkerC).

## Installation

**Prerequisites:** You must have LIKWID installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)). Specifically, `liblikwid` must be accessible.

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```

## likwid-perfctr

### Marker API

The most important functions provided by LIKWID.jl are
* `LIKWID.Marker.startregion(::String)`
* `LIKWID.Marker.stopregion(::String)`

which let you mark regions for a `likwid-perfctr` performance analysis (see [marker.jl](https://github.com/JuliaPerf/LIKWID.jl/blob/main/src/marker.jl) for all functions). Note that you need to use LIKWIDs `--marker` (or short `-m`) flag for the markers to actually be used, i.e. you need to run julia as follows:
```
likwid-perfctr .... --marker julia ...
```

#### Example
```julia
# saxpy_cpu.jl
using LIKWID
using LinearAlgebra

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

function saxpy!(z,a,x,y)
    z .= a .* x .+ y
end

saxpy!(z,a,x,y)
LIKWID.Marker.startregion("saxpy!")
saxpy!(z,a,x,y)
LIKWID.Marker.stopregion("saxpy!")
```

Running the code with `likwid-perfctr -C 0 -g FLOPS_SP -m julia saxpy_cpu.jl` should then produce an output similar to the following.

<details>
<summary>Example Output</summary>

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

</details>
<br>

### NVIDIA GPU Marker API

LIKWID.jl also provides wrappers for LIKWIDs functionality to analyze GPU performance metrics (see [NVIDIA GPU Marker API](https://github.com/RRZE-HPC/likwid/wiki/LIKWID-and-Nvidia-GPUs)). Note that this feature is only active if CUDA is available and you have built LIKWID with `NVIDIA_INTERFACE=true`. Similar to the regular Marker API for CPUs (see above), regions of Julia code can be marked via
* `LIKWID.GPUMarker.startregion(::String)`
* `LIKWID.GPUMarker.stopregion(::String)`

(See [gpu_marker.jl](https://github.com/JuliaPerf/LIKWID.jl/blob/main/src/gpu_marker.jl) for all functions.)

#### Example CPU + GPU
```julia
# saxpy_cpu_gpu.jl
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

println("CPU")
saxpy_cpu!(z,a,x,y)
LIKWID.Marker.startregion("saxpy_cpu!")
saxpy_cpu!(z,a,x,y)
LIKWID.Marker.stopregion("saxpy_cpu!")

println("GPU")
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
LIKWID.GPUMarker.startregion("saxpy_gpu!")
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
LIKWID.GPUMarker.stopregion("saxpy_gpu!")
```

You should get output similar to below when you run this code with

```
likwid-perfctr -C 0 -g FLOPS_SP -G 0 -W FLOPS_SP -m julia saxpy_cpu_gpu.jl
```

<details>
<summary>Example CPU + GPU Output</summary>

```
INFO: You are running LIKWID in a cpuset with 1 CPUs. Taking given IDs as logical ID in cpuset
--------------------------------------------------------------------------------
CPU name:       AMD EPYC 7402 24-Core Processor                
CPU type:       AMD K17 (Zen2) architecture
CPU clock:      2.80 GHz
ERROR - [./src/includes/perfmon_perfevent.h:perfmon_setupCountersThread_perfevent:881] Permission denied.
Setup of event ACTUAL_CPU_CLOCK on CPU 18 failed: Permission denied
ERROR - [./src/includes/perfmon_perfevent.h:perfmon_setupCountersThread_perfevent:881] Permission denied.
Setup of event MAX_CPU_CLOCK on CPU 18 failed: Permission denied
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
ERROR - [./src/includes/perfmon_perfevent.h:perfmon_setupCountersThread_perfevent:881] Permission denied.
Setup of event ACTUAL_CPU_CLOCK on CPU 18 failed: Permission denied
ERROR - [./src/includes/perfmon_perfevent.h:perfmon_setupCountersThread_perfevent:881] Permission denied.
Setup of event MAX_CPU_CLOCK on CPU 18 failed: Permission denied
CPU
GPU
--------------------------------------------------------------------------------
Region saxpy_cpu!, Group 1: FLOPS_SP
+-------------------+-------------+
|    Region Info    | HWThread 18 |
+-------------------+-------------+
| RDTSC Runtime [s] |    0.060933 |
|     call count    |           1 |
+-------------------+-------------+

+---------------------------+---------+-------------+
|           Event           | Counter | HWThread 18 |
+---------------------------+---------+-------------+
|      ACTUAL_CPU_CLOCK     |  FIXC1  |           0 |
|       MAX_CPU_CLOCK       |  FIXC2  |           0 |
|    RETIRED_INSTRUCTIONS   |   PMC0  |    64275390 |
|    CPU_CLOCKS_UNHALTED    |   PMC1  |   201643900 |
| RETIRED_SSE_AVX_FLOPS_ALL |   PMC2  |   200000400 |
|           MERGE           |   PMC3  |           0 |
+---------------------------+---------+-------------+

+----------------------+-------------+
|        Metric        | HWThread 18 |
+----------------------+-------------+
|  Runtime (RDTSC) [s] |      0.0609 |
| Runtime unhalted [s] |           0 |
|      Clock [MHz]     |      -      |
|          CPI         |      3.1372 |
|     SP [MFLOP/s]     |   3282.2738 |
+----------------------+-------------+

Region saxpy_gpu!, Group 1: FLOPS_SP
+-------------------+----------+
|    Region Info    |   GPU 0  |
+-------------------+----------+
| RDTSC Runtime [s] | 0.008691 |
|     call count    |        1 |
+-------------------+----------+

+----------------------------------------------------+---------+-----------+
|                        Event                       | Counter |   GPU 0   |
+----------------------------------------------------+---------+-----------+
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FADD_PRED_ON_SUM |   GPU0  |         0 |
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FMUL_PRED_ON_SUM |   GPU1  |         0 |
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM |   GPU2  | 200000000 |
+----------------------------------------------------+---------+-----------+

+---------------------+------------+
|        Metric       |    GPU 0   |
+---------------------+------------+
| Runtime (RDTSC) [s] |     0.0087 |
|     SP [MFLOP/s]    | 46023.1457 |
+---------------------+------------+
```

</details>
<br>

## License

LIKWID.jl is licensed under the [MIT license](LICENSE).