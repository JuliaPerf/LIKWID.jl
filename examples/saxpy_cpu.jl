# saxpy_cpu.jl
# To be run as e.g. `likwid-perfctr -C 0 -g FLOPS_SP -m julia saxpy_cpu.jl`
using LIKWID
using LinearAlgebra

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

function saxpy!(z,a,x,y)
    z .= a .* x .+ y
end

saxpy!(z,a,x,y)
LIKWID.Marker.startregion("saxpy!")
saxpy!(z,a,x,y)
LIKWID.Marker.stopregion("saxpy!")