# Marker API (GPU)

**Note:** This is a maturing feature. Only NVIDIA GPUs are supported.

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr_gpu](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr_gpu).)

```julia
# perfctr_gpu.jl
using LIKWID
using LinearAlgebra
using CUDA

@assert CUDA.functional()

LIKWID.GPUMarker.init()

# Note: CUDA defaults to Float32
Agpu = CUDA.rand(128, 64)
Bgpu = CUDA.rand(64, 128)
Cgpu = CUDA.zeros(128, 128)

LIKWID.GPUMarker.startregion("matmul")
for _ in 1:100
    mul!(Cgpu, Agpu, Bgpu)
end
LIKWID.GPUMarker.stopregion("matmul")

LIKWID.GPUMarker.close()
```

Running this file with the command `likwid-perfctr -G 0 -W FLOPS_SP -m julia perfctr_gpu.jl` one should obtain something like the following:
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

## `likwid-perfctr` in a nutshell

**Most importantly**, as for CPUs, you need to use the `-m` option to activate the marker API.

To list the available GPU performance groups, run `likwid-perfctr -a` and look for the lower "NvMon" table:
```
[...]

NvMon group name	Description
--------------------------------------------------------------------------------
    DATA	Load to store ratio
FLOPS_DP	Double-precision floating point
FLOPS_HP	Half-precision floating point
FLOPS_SP	Single-precision floating point
```
These groups can be passed to the command line option `-W`.

Another important option is `-G <list>`, where `<list>` is a list of GPUs to monitor. Note that GPU ids start with zero (not one).

Combinding the points above, the full command could look like this: `likwid-perfctr -G 0 -W FLOPS_SP -m julia`.

For more information, check out the [official documentation](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr).

## Functions

```@autodocs
Modules = [LIKWID.GPUMarker]
```
