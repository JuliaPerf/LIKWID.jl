# Marker API (CPU)

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr).)

```julia
# perfctr.jl
using LIKWID
using LinearAlgebra

Marker.init()

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

Marker.startregion("matmul")
for _ in 1:100
    mul!(C, A, B)
end
Marker.stopregion("matmul")

Marker.close()
```

Running this file with the command `likwid-perfctr -C 0 -g FLOPS_DP -m julia perfctr.jl` one should obtain something like the following:
```
--------------------------------------------------------------------------------
CPU name:	Intel(R) Xeon(R) Gold 6246 CPU @ 3.30GHz
CPU type:	Intel Cascadelake SP processor
CPU clock:	3.30 GHz
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Region matmul, Group 1: FLOPS_DP
+-------------------+------------+
|    Region Info    | HWThread 0 |
+-------------------+------------+
| RDTSC Runtime [s] |   0.621329 |
|     call count    |          1 |
+-------------------+------------+
+------------------------------------------+---------+------------+
|                   Event                  | Counter | HWThread 0 |
+------------------------------------------+---------+------------+
|             INSTR_RETIRED_ANY            |  FIXC0  | 4151839000 |
|           CPU_CLK_UNHALTED_CORE          |  FIXC1  | 2548859000 |
|           CPU_CLK_UNHALTED_REF           |  FIXC2  | 2004161000 |
| FP_ARITH_INST_RETIRED_128B_PACKED_DOUBLE |   PMC0  |          0 |
|    FP_ARITH_INST_RETIRED_SCALAR_DOUBLE   |   PMC1  |       1572 |
| FP_ARITH_INST_RETIRED_256B_PACKED_DOUBLE |   PMC2  |          0 |
| FP_ARITH_INST_RETIRED_512B_PACKED_DOUBLE |   PMC3  |   26624000 |
+------------------------------------------+---------+------------+
+----------------------+------------+
|        Metric        | HWThread 0 |
+----------------------+------------+
|  Runtime (RDTSC) [s] |     0.6213 |
| Runtime unhalted [s] |     0.7724 |
|      Clock [MHz]     |  4196.5492 |
|          CPI         |     0.6139 |
|     DP [MFLOP/s]     |   342.8031 |
|   AVX DP [MFLOP/s]   |   342.8006 |
|  AVX512 DP [MFLOP/s] |   342.8006 |
|   Packed [MUOPS/s]   |    42.8501 |
|   Scalar [MUOPS/s]   |     0.0025 |
|  Vectorization ratio |    99.9941 |
+----------------------+------------+
```

### Convenience macro

We provide (and export) the macro [`@region`](@ref) which can be used to write regions like

```julia
Marker.startregion("matmul")
for _ in 1:100
    mul!(C, A, B)
end
Marker.stopregion("matmul")
```

simply as

```julia
@region "matmul" for _ in 1:100
    mul!(C, A, B)
end
```

### SIMD / AVX

Let's run the same example as above on a Rocketlacke processor. We might get the following.
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

Given the absence of AVX calls, it seems like OpenBLAS is falling back to a suboptimal Nehalem kernel. If we install [MKL.jl](https://github.com/JuliaLinearAlgebra/MKL.jl) and add `using MKL` to the top of our script above, the metrics table becomes

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

## `likwid-perfctr` in a nutshell

**Most importantly**, you need to use the `-m` option to activate the marker API.

To list the available performance groups, run `likwid-perfctr -a`:
```
PerfMon group name	Description
--------------------------------------------------------------------------------
        MEM_SP	Overview of arithmetic and main memory performance
CYCLE_ACTIVITY	Cycle Activities
        ENERGY	Power and Energy consumption
   UOPS_RETIRE	UOPs retirement
           PMM	Intel Optane DC bandwidth in MBytes/s
     TLB_INSTR	L1 Instruction TLB miss rate/ratio
          DATA	Load to store ratio
    UOPS_ISSUE	UOPs issueing
       L2CACHE	L2 cache miss rate/ratio
            L2	L2 cache bandwidth in MBytes/s
     FLOPS_AVX	Packed AVX MFLOP/s
           MEM	Main memory bandwidth in MBytes/s
        BRANCH	Branch prediction miss rate/ratio
      FLOPS_SP	Single Precision MFLOP/s
        MEM_DP	Overview of arithmetic and main memory performance
       L3CACHE	L3 cache miss rate/ratio
           UPI	UPI data traffic
     UOPS_EXEC	UOPs execution
      TLB_DATA	L2 data TLB miss rate/ratio
        CACHES	Cache bandwidth in MBytes/s
        DIVIDE	Divide unit information
           TMA	Top down cycle allocation
         CLOCK	Power and Energy consumption
      FLOPS_DP	Double Precision MFLOP/s
  CYCLE_STALLS	Cycle Activities (Stalls)
            L3	L3 cache bandwidth in MBytes/s
           UPI	UPI traffic
         L3NEW	L3 cache bandwidth in MBytes/s
          L3PF	L3 cache bandwidth in MBytes/s
          L2L3	L3 cache bandwidth in MBytes/s
```
These groups can be passed to the command line option `-g`. Note that you can also query the available performance groups programmatically using [`LIKWID.PerfMon.get_groups()`](@ref).

Another important option is `-C <list>`:
> Processor ids to pin threads and measure, e.g. 1,2-4,8. For information about the `<list>` syntax, see `likwid-pin`.
Note that cpu ids start with zero (not one).

Combinding the points above, the full command could look like this: `likwid-perfctr -C 0 -g FLOPS_DP -m julia`.

For more information, check out the [official documentation](https://github.com/RRZE-HPC/likwid/wiki/likwid-perfctr).

!!! warning "Multithreading"
    It is important to note that `likwid-perfctr`s built-in threading pinning through `-C <cores>` doesn't work as expected for Julia when using multiple threads, i.e. `Threads.nthreads() > 1`.
    Instead, one should use a different mean of pinning threads, e.g. like [`JULIA_EXCLUSIVE=1`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_EXCLUSIVE) or [ThreadPinning.jl](https://github.com/carstenbauer/ThreadPinning.jl), and use `-c <cores>` (lowercase `c`!),
    which will instruct LIKWID to only measure on these cores (disables LIKWIDs pinning).

## API

```@index
Pages   = ["marker.md"]
Order   = [:function, :type]
```

### Functions

```@autodocs
Modules = [LIKWID.Marker]
```
