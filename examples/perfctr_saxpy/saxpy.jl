# saxpy.jl
using LIKWID
using CUDA
using LinearAlgebra

@assert CUDA.functional()

N = 100_000_000
a = 3.141f0
z = zeros(Float32, N)
x = rand(Float32, N)
y = rand(Float32, N)

z_gpu = CUDA.zeros(Float32, N)
x_gpu = CUDA.rand(Float32, N)
y_gpu = CUDA.rand(Float32, N)

function saxpy_cpu!(z,a,x,y)
    z .= a .* x .+ y
end

function saxpy_gpu!(z,a,x,y)
    CUDA.@sync z .= a .* x .+ y
end

LIKWID.Marker.init()
LIKWID.GPUMarker.init()

saxpy_cpu!(z,a,x,y)
LIKWID.Marker.startregion("saxpy_cpu")
saxpy_cpu!(z,a,x,y)
LIKWID.Marker.stopregion("saxpy_cpu")

saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
LIKWID.GPUMarker.startregion("saxpy_gpu")
saxpy_gpu!(z_gpu,a,x_gpu,y_gpu)
LIKWID.GPUMarker.stopregion("saxpy_gpu")

LIKWID.Marker.close()
LIKWID.GPUMarker.close()
