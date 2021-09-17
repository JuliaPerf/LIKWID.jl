using Test
using LIKWID
using LinearAlgebra

# julia must have been started with `likwid-perfctr -C ... -g ... -m`
@assert LIKWID.Marker.isactive()

# init
@test isnothing(LIKWID.Marker.init())

LIKWID.init_perfmon() # required for getregion below

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

saxpy!(z,a,x,y) = z .= a .* x .+ y

# regular workflow
saxpy!(z,a,x,y)
@test LIKWID.Marker.startregion("saxpy!")
saxpy!(z,a,x,y)
@test LIKWID.Marker.stopregion("saxpy!")

# nextgroup
@test isnothing(LIKWID.Marker.nextgroup())

# registerregion
A = rand(100,100)
B = rand(100,100)
@test LIKWID.Marker.registerregion("mul")
@test LIKWID.Marker.startregion("mul")
for _ in 1:10
    A * B
end
@test LIKWID.Marker.stopregion("mul")

# getregion
x = LIKWID.Marker.getregion("mul")
@test typeof(x) == Tuple{Int32, Vector{Float64}, Float64, Int32}

# resetregion
@test LIKWID.Marker.resetregion("mul")
y = LIKWID.Marker.getregion("mul")
@test x != y
@test y[3] == 0
@test y[4] == 0

# close
@test isnothing(LIKWID.Marker.close())