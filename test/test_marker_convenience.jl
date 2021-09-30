using Test
using LIKWID
using LinearAlgebra

# julia must have been started with `likwid-perfctr -C ... -g ... -m`
@assert LIKWID.Marker.isactive()

# init
@test isnothing(LIKWID.Marker.init())

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

saxpy!(z,a,x,y) = z .= a .* x .+ y

@test @region "saxpy!" saxpy!(z,a,x,y)
@test @region "saxpy!" saxpy!(z,a,x,y)

A = rand(100,100)
B = rand(100,100)

@test @region "mul" for _ in 1:10
    A * B
end

# close
@test isnothing(LIKWID.Marker.close())