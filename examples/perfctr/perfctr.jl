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
