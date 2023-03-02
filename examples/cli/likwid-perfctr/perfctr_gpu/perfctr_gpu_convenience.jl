# perfctr_gpu_convenience.jl
using LIKWID
using LinearAlgebra
using CUDA

@assert CUDA.functional()

const N = 10_000
const a = 3.141
# Note: CUDA defaults to Float32
const x = CUDA.rand(N)
const y = CUDA.rand(N)
const z = CUDA.zeros(N)

GPUMarker.init()

@gpumarker "saxpy" begin z .= a .* x .* y end

GPUMarker.close()
