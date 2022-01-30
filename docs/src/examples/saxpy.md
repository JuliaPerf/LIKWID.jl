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

## Multithreading

!!! warning
    It is crucial that you pin the Julia threads reliably to the cores that we are monitoring with LIKWID. Here, we will use `likwid-pin` with an appropriate [`pinmask`](@ref) but, in general, it might be easier to use [`JULIA_EXCLUSIVE=1`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_EXCLUSIVE) or [`ThreadPinning.jl`](https://github.com/carstenbauer/ThreadPinning.jl).

```julia
# saxpy_threads.jl
using LIKWID
using LinearAlgebra
using Base.Threads: nthreads, @threads

@assert nthreads() > 1 # multithreading

# Julia threads should be pinned!
@threads for tid in 1:nthreads()
    core = LIKWID.get_processor_id()
    println("Thread $tid, Core $core")
end

N = 100_000_000
a = 3.141f0
zs = [zeros(Float32, N) for _ in 1:nthreads()]
x = rand(Float32, N)
y = rand(Float32, N)

function saxpy_cpu!(z, a, x, y)
    z .= a .* x .+ y
end

function saxpy_threads(zs, a, x, y)
    @threads for tid in 1:nthreads()
        @region "saxpy_cpu!" saxpy_cpu!(zs[tid], a, x, y)
    end
end

Marker.init()

saxpy_cpu!(zs[1], a, x, y) # precompile saxpy_cpu
saxpy_threads(zs, a, x, y)

Marker.close()
```

Output for `likwid-perfctr -c 0-2 -g FLOPS_SP -m likwid-pin -s 0xfffffffffffffff1 -c 0-2 julia --project=. -t3 threads.jl`:
```
Warning: The Marker API requires the application to run on the selected CPUs.
Warning: likwid-perfctr pins the application only when using the -C command line option.
Warning: LIKWID assumes that the application does it before the first instrumented code region is started.
Warning: You can use the string in the environment variable LIKWID_THREADS to pin you application to
Warning: to the CPUs specified after the -c command line option.
--------------------------------------------------------------------------------
CPU name:	Intel(R) Xeon(R) Gold 6246 CPU @ 3.30GHz
CPU type:	Intel Cascadelake SP processor
CPU clock:	3.30 GHz
--------------------------------------------------------------------------------
Thread 2, Core 1
Thread 3, Core 2
Thread 1, Core 0
--------------------------------------------------------------------------------
Region saxpy_cpu!, Group 1: FLOPS_SP
+-------------------+------------+------------+------------+
|    Region Info    | HWThread 0 | HWThread 1 | HWThread 2 |
+-------------------+------------+------------+------------+
| RDTSC Runtime [s] |   0.146394 |   0.199333 |   0.178488 |
|     call count    |          1 |          1 |          1 |
+-------------------+------------+------------+------------+
+------------------------------------------+---------+------------+------------+------------+
|                   Event                  | Counter | HWThread 0 | HWThread 1 | HWThread 2 |
+------------------------------------------+---------+------------+------------+------------+
|             INSTR_RETIRED_ANY            |  FIXC0  |   46977220 |   47074720 |   47030020 |
|           CPU_CLK_UNHALTED_CORE          |  FIXC1  |  383841400 |  399093000 |  382726500 |
|           CPU_CLK_UNHALTED_REF           |  FIXC2  |  343281800 |  403328100 |  386764600 |
| FP_ARITH_INST_RETIRED_128B_PACKED_SINGLE |   PMC0  |          0 |          0 |          0 |
|    FP_ARITH_INST_RETIRED_SCALAR_SINGLE   |   PMC1  |          0 |          0 |          0 |
| FP_ARITH_INST_RETIRED_256B_PACKED_SINGLE |   PMC2  |   25000000 |   25000000 |   25000000 |
| FP_ARITH_INST_RETIRED_512B_PACKED_SINGLE |   PMC3  |          0 |          0 |          0 |
+------------------------------------------+---------+------------+------------+------------+
+-----------------------------------------------+---------+------------+-----------+-----------+--------------+
|                     Event                     | Counter |     Sum    |    Min    |    Max    |      Avg     |
+-----------------------------------------------+---------+------------+-----------+-----------+--------------+
|             INSTR_RETIRED_ANY STAT            |  FIXC0  |  141081960 |  46977220 |  47074720 |     47027320 |
|           CPU_CLK_UNHALTED_CORE STAT          |  FIXC1  | 1165660900 | 382726500 | 399093000 | 3.885536e+08 |
|           CPU_CLK_UNHALTED_REF STAT           |  FIXC2  | 1133374500 | 343281800 | 403328100 |    377791500 |
| FP_ARITH_INST_RETIRED_128B_PACKED_SINGLE STAT |   PMC0  |          0 |         0 |         0 |            0 |
|    FP_ARITH_INST_RETIRED_SCALAR_SINGLE STAT   |   PMC1  |          0 |         0 |         0 |            0 |
| FP_ARITH_INST_RETIRED_256B_PACKED_SINGLE STAT |   PMC2  |   75000000 |  25000000 |  25000000 |     25000000 |
| FP_ARITH_INST_RETIRED_512B_PACKED_SINGLE STAT |   PMC3  |          0 |         0 |         0 |            0 |
+-----------------------------------------------+---------+------------+-----------+-----------+--------------+
+----------------------+------------+------------+------------+
|        Metric        | HWThread 0 | HWThread 1 | HWThread 2 |
+----------------------+------------+------------+------------+
|  Runtime (RDTSC) [s] |     0.1464 |     0.1993 |     0.1785 |
| Runtime unhalted [s] |     0.1163 |     0.1209 |     0.1160 |
|      Clock [MHz]     |  3689.9336 |  3265.3756 |  3265.5725 |
|          CPI         |     8.1708 |     8.4779 |     8.1379 |
|     SP [MFLOP/s]     |  1366.1725 |  1003.3472 |  1120.5229 |
|   AVX SP [MFLOP/s]   |  1366.1725 |  1003.3472 |  1120.5229 |
|  AVX512 SP [MFLOP/s] |          0 |          0 |          0 |
|   Packed [MUOPS/s]   |   170.7716 |   125.4184 |   140.0654 |
|   Scalar [MUOPS/s]   |          0 |          0 |          0 |
|  Vectorization ratio |        100 |        100 |        100 |
+----------------------+------------+------------+------------+
+---------------------------+------------+-----------+-----------+-----------+
|           Metric          |     Sum    |    Min    |    Max    |    Avg    |
+---------------------------+------------+-----------+-----------+-----------+
|  Runtime (RDTSC) [s] STAT |     0.5242 |    0.1464 |    0.1993 |    0.1747 |
| Runtime unhalted [s] STAT |     0.3532 |    0.1160 |    0.1209 |    0.1177 |
|      Clock [MHz] STAT     | 10220.8817 | 3265.3756 | 3689.9336 | 3406.9606 |
|          CPI STAT         |    24.7866 |    8.1379 |    8.4779 |    8.2622 |
|     SP [MFLOP/s] STAT     |  3490.0426 | 1003.3472 | 1366.1725 | 1163.3475 |
|   AVX SP [MFLOP/s] STAT   |  3490.0426 | 1003.3472 | 1366.1725 | 1163.3475 |
|  AVX512 SP [MFLOP/s] STAT |          0 |         0 |         0 |         0 |
|   Packed [MUOPS/s] STAT   |   436.2554 |  125.4184 |  170.7716 |  145.4185 |
|   Scalar [MUOPS/s] STAT   |          0 |         0 |         0 |         0 |
|  Vectorization ratio STAT |        300 |       100 |       100 |       100 |
+---------------------------+------------+-----------+-----------+-----------+
```