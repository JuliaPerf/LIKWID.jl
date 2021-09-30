# perfctr_gpu_convenience.jl
using LIKWID
using LinearAlgebra
using CUDA

@assert CUDA.functional()

LIKWID.GPUMarker.init()

# Note: CUDA defaults to Float32
Agpu = CUDA.rand(128, 64)
Bgpu = CUDA.rand(64, 128)
Cgpu = CUDA.zeros(128, 128)

@gpuregion "matmul" for _ in 1:100
    mul!(Cgpu, Agpu, Bgpu)
end

LIKWID.GPUMarker.close()