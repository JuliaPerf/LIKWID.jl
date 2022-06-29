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

We provide (and export) the macro [`@marker`](@ref) which can be used to write regions like

```julia
Marker.startregion("matmul")
for _ in 1:100
    mul!(C, A, B)
end
Marker.stopregion("matmul")
```

simply as

```julia
@marker "matmul" for _ in 1:100
    mul!(C, A, B)
end
```
