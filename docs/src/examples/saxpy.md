# Using the Marker API

## CPU

Example that demonstrates using the CPU Marker API.

```julia
# saxpy_cpu.jl
using LIKWID
using LinearAlgebra

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

function saxpy_cpu!(z,a,x,y)
    z .= a .* x .+ y
end

Marker.init()

saxpy_cpu!(z,a,x,y)
@region "saxpy_cpu" saxpy_cpu!(z,a,x,y)

Marker.close()
```

Output of `likwid-perfctr -C 0 -g FLOPS_SP -m julia saxpy_cpu.jl`:
```
--------------------------------------------------------------------------------
CPU name:	Intel(R) Xeon(R) Gold 6148 CPU @ 2.40GHz
CPU type:	Intel Skylake SP processor
CPU clock:	2.39 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region saxpy_cpu, Group 1: FLOPS_SP
+-------------------+------------+
|    Region Info    | HWThread 0 |
+-------------------+------------+
| RDTSC Runtime [s] |   0.097326 |
|     call count    |          1 |
+-------------------+------------+

+------------------------------------------+---------+------------+
|                   Event                  | Counter | HWThread 0 |
+------------------------------------------+---------+------------+
|             INSTR_RETIRED_ANY            |  FIXC0  |   10850760 |
|           CPU_CLK_UNHALTED_CORE          |  FIXC1  |   69311210 |
|           CPU_CLK_UNHALTED_REF           |  FIXC2  |          0 |
| FP_ARITH_INST_RETIRED_128B_PACKED_SINGLE |   PMC0  |          0 |
|    FP_ARITH_INST_RETIRED_SCALAR_SINGLE   |   PMC1  |        111 |
| FP_ARITH_INST_RETIRED_256B_PACKED_SINGLE |   PMC2  |    4805495 |
| FP_ARITH_INST_RETIRED_512B_PACKED_SINGLE |   PMC3  |          0 |
+------------------------------------------+---------+------------+

+----------------------+------------+
|        Metric        | HWThread 0 |
+----------------------+------------+
|  Runtime (RDTSC) [s] |     0.0973 |
| Runtime unhalted [s] |     0.0289 |
|      Clock [MHz]     |     inf    |
|          CPI         |     6.3877 |
|     SP [MFLOP/s]     |   395.0039 |
|   AVX SP [MFLOP/s]   |   395.0028 |
|  AVX512 SP [MFLOP/s] |          0 |
|   Packed [MUOPS/s]   |    49.3753 |
|   Scalar [MUOPS/s]   |     0.0011 |
|  Vectorization ratio |    99.9977 |
+----------------------+------------+
```

## CPU+GPU

Example that demonstrates using the CPU and GPU Marker API together in one application.

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

Marker.init()
GPUMarker.init()

saxpy_cpu!(z,a,x,y)
@region "saxpy_cpu" saxpy_cpu!(z,a,x,y)

saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
@gpuregion "saxpy_gpu" saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)

Marker.close()
GPUMarker.close()
```

Output of `likwid-perfctr -C 0 -g FLOPS_SP -G 0 -W FLOPS_SP -m julia saxpy.jl`:
```
--------------------------------------------------------------------------------
CPU name:	Intel(R) Xeon(R) Gold 6246 CPU @ 3.30GHz
CPU type:	Intel Cascadelake SP processor
CPU clock:	3.30 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region saxpy_cpu, Group 1: FLOPS_SP
+-------------------+------------+
|    Region Info    | HWThread 0 |
+-------------------+------------+
| RDTSC Runtime [s] |   0.090796 |
|     call count    |          1 |
+-------------------+------------+
+------------------------------------------+---------+------------+
|                   Event                  | Counter | HWThread 0 |
+------------------------------------------+---------+------------+
|             INSTR_RETIRED_ANY            |  FIXC0  |   59866700 |
|           CPU_CLK_UNHALTED_CORE          |  FIXC1  |  344927500 |
|           CPU_CLK_UNHALTED_REF           |  FIXC2  |  298780700 |
| FP_ARITH_INST_RETIRED_128B_PACKED_SINGLE |   PMC0  |          0 |
|    FP_ARITH_INST_RETIRED_SCALAR_SINGLE   |   PMC1  |        111 |
| FP_ARITH_INST_RETIRED_256B_PACKED_SINGLE |   PMC2  |   25000000 |
| FP_ARITH_INST_RETIRED_512B_PACKED_SINGLE |   PMC3  |          0 |
+------------------------------------------+---------+------------+
+----------------------+------------+
|        Metric        | HWThread 0 |
+----------------------+------------+
|  Runtime (RDTSC) [s] |     0.0908 |
| Runtime unhalted [s] |     0.1045 |
|      Clock [MHz]     |  3809.5859 |
|          CPI         |     5.7616 |
|     SP [MFLOP/s]     |  2202.7354 |
|   AVX SP [MFLOP/s]   |  2202.7341 |
|  AVX512 SP [MFLOP/s] |          0 |
|   Packed [MUOPS/s]   |   275.3418 |
|   Scalar [MUOPS/s]   |     0.0012 |
|  Vectorization ratio |    99.9996 |
+----------------------+------------+
Region saxpy_gpu, Group 1: FLOPS_SP
+-------------------+----------+
|    Region Info    |   GPU 0  |
+-------------------+----------+
| RDTSC Runtime [s] | 0.010824 |
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
| Runtime (RDTSC) [s] |     0.0108 |
|     SP [MFLOP/s]    | 18477.1502 |
+---------------------+------------+
```
