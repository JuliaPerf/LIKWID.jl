# perfctr_convenience.jl
using LIKWID
using LinearAlgebra

const N = 10_000
const a = 3.141
const x = rand(N)
const y = rand(N)
const z = zeros(N)

Marker.init()

@marker "saxpy" begin for i in eachindex(x, y)
    z[i] = a * x[i] * y[i]
end end

Marker.close()
