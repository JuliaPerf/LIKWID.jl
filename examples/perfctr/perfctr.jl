# likwid-perfctr -C 0 -g FLOPS_DP -m julia perfctr.jl
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
