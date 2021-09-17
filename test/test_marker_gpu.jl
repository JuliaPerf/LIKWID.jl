using Test
using LIKWID
using LinearAlgebra
using CUDA

@assert CUDA.functional()

@test LIKWID.GPUMarker.isactive()

N = 100_000_000
a = 3.141f0
z_gpu = CUDA.zeros(Float32, N)
x_gpu = CUDA.rand(Float32, N)
y_gpu = CUDA.rand(Float32, N)

saxpy_gpu!(z,a,x,y) = CUDA.@sync z .= a .* x .+ y

# regular workflow
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
@test LIKWID.GPUMarker.startregion("saxpy_gpu!")
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
@test LIKWID.GPUMarker.stopregion("saxpy_gpu!") 

# init
@test isnothing(LIKWID.GPUMarker.init())

# nextgroup
@test isnothing(LIKWID.GPUMarker.nextgroup())

# registerregion
A = CUDA.rand(100,100)
B = CUDA.rand(100,100)
@test_broken LIKWID.GPUMarker.registerregion("mul")
@test LIKWID.GPUMarker.startregion("mul")
for _ in 1:10
    A * B
end
@test LIKWID.GPUMarker.stopregion("mul")

# TODO: fix!
# # getregion
# LIKWID.Nvmon.init([0])
# x = LIKWID.GPUMarker.getregion("mul")
# @test typeof(x) == Tuple{Int32, Vector{Float64}, Float64, Int32}

# # resetregion
# @test LIKWID.GPUMarker.resetregion("mul")
# y = LIKWID.GPUMarker.getregion("mul")
# @test x != y
# @test y[3] == 0
# @test y[4] == 0

# close
@test isnothing(LIKWID.GPUMarker.close())


