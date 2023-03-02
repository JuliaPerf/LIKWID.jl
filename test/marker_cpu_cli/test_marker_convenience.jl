using Test
using LIKWID
using LinearAlgebra

# julia must have been started with `likwid-perfctr -C ... -g ... -m`
@assert Marker.isactive()

# init
@test isnothing(Marker.init())

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

saxpy!(z, a, x, y) = z .= a .* x .+ y

@test @marker "saxpy!" saxpy!(z, a, x, y)
@test @marker "saxpy!" saxpy!(z, a, x, y)

A = rand(100, 100)
B = rand(100, 100)

@test @marker "mul" for _ in 1:10
    A * B
end

# close
@test isnothing(Marker.close())
