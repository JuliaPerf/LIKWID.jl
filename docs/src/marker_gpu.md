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

GPUMarker.init()

# Note: CUDA defaults to Float32
Agpu = CUDA.rand(128, 64)
Bgpu = CUDA.rand(64, 128)
Cgpu = CUDA.zeros(128, 128)

GPUMarker.startregion("matmul")
for _ in 1:100
    mul!(Cgpu, Agpu, Bgpu)
end
GPUMarker.stopregion("matmul")

GPUMarker.close()
```

Running this file with the command `likwid-perfctr -G 0 -W FLOPS_SP -m julia perfctr_gpu.jl` one should obtain something like the following:
```
--------------------------------------------------------------------------------
CPU name:	Intel(R) Xeon(R) Gold 6246 CPU @ 3.30GHz
CPU type:	Intel Cascadelake SP processor
CPU clock:	3.30 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region matmul, Group 1: FLOPS_SP
+-------------------+----------+
|    Region Info    |   GPU 0  |
+-------------------+----------+
| RDTSC Runtime [s] | 3.426146 |
|     call count    |        1 |
+-------------------+----------+
+----------------------------------------------------+---------+----------+
|                        Event                       | Counter |   GPU 0  |
+----------------------------------------------------+---------+----------+
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FADD_PRED_ON_SUM |   GPU0  |  2457600 |
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FMUL_PRED_ON_SUM |   GPU1  |  3276800 |
| SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM |   GPU2  | 52436990 |
+----------------------------------------------------+---------+----------+
+---------------------+---------+
|        Metric       |  GPU 0  |
+---------------------+---------+
| Runtime (RDTSC) [s] |  3.4261 |
|     SP [MFLOP/s]    | 32.2836 |
+---------------------+---------+
```

### Convenience macro

We provide (and export) the macro `@gpuregion` which can be used to write regions like

```julia
GPUMarker.startregion("matmul")
for _ in 1:100
    mul!(Cgpu, Agpu, Bgpu)
end
GPUMarker.stopregion("matmul")
```

simply as

```julia
@gpuregion "matmul" for _ in 1:100
    mul!(Cgpu, Agpu, Bgpu)
end
```

## `likwid-perfctr` in a nutshell

**Most importantly**, as for CPUs, you need to use the `-m` option to activate the marker API.

To list the available GPU performance groups, run `likwid-perfctr -a` and look for the lower "NvMon" table:
```
[...]

NvMon group name	Description
--------------------------------------------------------------------------------
    DATA	Load to store ratio
FLOPS_SP	Single-precision floating point
FLOPS_HP	Half-precision floating point
FLOPS_DP	Double-precision floating point
```
These groups can be passed to the command line option `-W`. Note that you can also query the available GPU performance groups programmatically using [`LIKWID.NvMon.get_groups(gpuid::Integer)`](@ref).

Another important option is `-G <list>`, where `<list>` is a list of GPUs to monitor. Note that GPU ids start with zero (not one).

Combinding the points above, the full command could look like this: `likwid-perfctr -G 0 -W FLOPS_SP -m julia`.

For more information, check out the [official documentation](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr).

## Functions

```@autodocs
Modules = [LIKWID.GPUMarker]
```