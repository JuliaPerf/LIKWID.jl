using Test
using LIKWID
using LinearAlgebra
using CUDA

@assert CUDA.functional()

# julia must have been started with `likwid-perfctr -G ... -W ... -m`
@assert GPUMarker.isactive()

# init
@test isnothing(GPUMarker.init())

N = 100_000_000
a = 3.141f0
z_gpu = CUDA.zeros(Float32, N)
x_gpu = CUDA.rand(Float32, N)
y_gpu = CUDA.rand(Float32, N)

saxpy_gpu!(z,a,x,y) = CUDA.@sync z .= a .* x .+ y

# regular workflow
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
@test GPUMarker.startregion("saxpy_gpu!")
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
@test GPUMarker.stopregion("saxpy_gpu!")


# nextgroup
@test isnothing(GPUMarker.nextgroup())

# registerregion
A = CUDA.rand(100,100)
B = CUDA.rand(100,100)
@test_broken GPUMarker.registerregion("mul")
@test GPUMarker.startregion("mul")
for _ in 1:10
    A * B
end
@test GPUMarker.stopregion("mul")

# TODO: fix!
# # getregion
# LIKWID.NvMon.init([0])
# x = GPUMarker.getregion("mul")
# @test typeof(x) == Tuple{Int32, Vector{Float64}, Float64, Int32}

# # resetregion
# @test GPUMarker.resetregion("mul")
# y = GPUMarker.getregion("mul")
# @test x != y
# @test y[3] == 0
# @test y[4] == 0

# close
@test isnothing(GPUMarker.close())


