# perfctr_gpu.jl
using LIKWID
using LinearAlgebra
using CUDA

@assert CUDA.functional()

GPUMarker.init()

# Note: CUDA defaults to Float32
Agpu = CUDA.rand(128, 64)
Bgpu = CUDA.rand(64, 128)
Cgpu = CUDA.zeros(128, 128)

GPUMarker.startregion("matmul")
for _ in 1:100
    mul!(Cgpu, Agpu, Bgpu)
end
GPUMarker.stopregion("matmul")

GPUMarker.close()