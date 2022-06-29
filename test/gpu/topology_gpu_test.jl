using LIKWID
using Test
using CUDA

@assert CUDA.functional()
@assert LIKWID.gpusupport()

@testset "Topology (GPU)" begin
    @test LIKWID.init_topology_gpu()
    gputopo = LIKWID.get_gpu_topology()
    @test typeof(gputopo) == LIKWID.GpuTopology
    gpu = gputopo.devices[1]
    @test typeof(gpu) == LIKWID.GpuDevice
    @test typeof(gpu.name) == String
    @test typeof(gpu.mem) == Int
    @test typeof(gpu.maxThreadsDim) == NTuple{3,Int}
    @test typeof(gpu.maxGridSize) == NTuple{3,Int}
    @test isnothing(LIKWID.finalize_topology_gpu())
end
