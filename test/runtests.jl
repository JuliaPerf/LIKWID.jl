using Test
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

LIKWID.Marker.startregion("matmul")
mul!(C, A, B)
LIKWID.Marker.stopregion("matmul")