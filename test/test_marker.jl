using Test
using LIKWID
using LinearAlgebra

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)
saxpy!(z,a,x,y) = z .= a .* x .+ y

saxpy!(z,a,x,y)
LIKWID.Marker.startregion("saxpy!")
saxpy!(z,a,x,y)
LIKWID.Marker.stopregion("saxpy!")

# TODO: add tests for remaining functions