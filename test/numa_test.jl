using LIKWID
using Test

@testset "NUMA" begin
    @test LIKWID.init_topology() # needed before init_numa()
    @test LIKWID.init_numa()
    numinfo = LIKWID.get_numa_topology()
    @test typeof(numinfo) == LIKWID.NumaTopology
    @test numinfo.numberOfNodes ≥ 0
    numanode = first(numinfo.nodes)
    @test typeof(numanode) == LIKWID.NumaNode
    @test numanode.totalMemory ≥ 0
    @test numanode.numberOfProcessors ≥ 0
    @test typeof(numanode.processors) == Vector{Int}
    @test length(numanode.processors) == numanode.numberOfProcessors
    @test isnothing(LIKWID.finalize_numa())
end
