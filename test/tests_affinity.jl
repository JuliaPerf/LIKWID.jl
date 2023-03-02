using LIKWID
using Test

@testset "Affinity" begin
    @test LIKWID.init_affinity()
    affinity = LIKWID.get_affinity()
    @test typeof(affinity) == LIKWID.AffinityDomains
    @test affinity.numberOfSocketDomains ≥ 1
    @test affinity.numberOfNumaDomains ≥ 1
    @test affinity.numberOfProcessorsPerSocket ≥ 1
    @test affinity.numberOfAffinityDomains ≥ 1
    @test typeof(affinity.domains) == Vector{LIKWID.AffinityDomain}
    @test length(affinity.domains) == affinity.numberOfAffinityDomains
    d = first(affinity.domains)
    @test typeof(d) == LIKWID.AffinityDomain
    @test typeof(d.tag) == String
    @test typeof(d.processorList) == Vector{Int}
    @test length(d.processorList) == d.numberOfProcessors
    @test isnothing(LIKWID.finalize_affinity())
end
