using Test
using LIKWID
using LinearAlgebra

# julia should NOT have been started with `likwid-perfctr -C ... -g ... -m` for this test file
@assert !Marker.isactive()

# init
@test isnothing(Marker.init())

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

saxpy!(z, a, x, y) = z .= a .* x .+ y

# regular workflow
saxpy!(z, a, x, y)
@test !Marker.startregion("saxpy!")
saxpy!(z, a, x, y)
@test !Marker.stopregion("saxpy!")

# nextgroup
@test isnothing(Marker.nextgroup())

# registerregion
A = rand(100, 100)
B = rand(100, 100)
@test !Marker.registerregion("mul")
@test !Marker.startregion("mul")
for _ in 1:10
    A * B
end
@test !Marker.stopregion("mul")

# close
@test isnothing(Marker.close())
