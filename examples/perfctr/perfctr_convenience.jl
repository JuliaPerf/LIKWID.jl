# perfctr_convenience.jl
using LIKWID
using LinearAlgebra

Marker.init()

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

for _ in 1:100
    @region "scalar_add" 1+2
end

@region "matmul" begin
    for _ in 1:100
        mul!(C, A, B)
    end
end

Marker.close()
