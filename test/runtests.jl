using Test
using LIKWID

@testset "Topology" begin
    @test LIKWID.init_topology()
    cputopo = LIKWID.get_cpu_topology()
    @test typeof(cputopo) == LIKWID.CpuTopology
    cpuinfo = LIKWID.get_cpu_info()
    @test typeof(cpuinfo) == LIKWID.CpuInfo
    @test isnothing(LIKWID.print_supported_cpus())
    @test isnothing(LIKWID.finalize_topology())
end

@testset "NUMA" begin
    @test LIKWID.init_numa()
    numinfo = LIKWID.get_numa_topology()
    @test typeof(numinfo) == LIKWID.NumaTopology
    @test numinfo.numberOfNodes ≥ 1
    numanode = first(numinfo.nodes)
    @test typeof(numanode) == LIKWID.NumaNode
    @test numanode.totalMemory ≥ 0
    @test numanode.numberOfProcessors ≥ 1
    @test typeof(numanode.processors) == Vector{Int}
    @test length(numanode.processors) == numanode.numberOfProcessors
    @test isnothing(LIKWID.finalize_numa())
end

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

@testset "Timer" begin
    @test LIKWID.init_timer()
    @test isinteger(LIKWID.get_cpu_clock())
    @test isinteger(LIKWID.get_cpu_clock_current(0))
    t = LIKWID.start_clock()
    @test !isnothing(t)
    @test !iszero(t.start)
    @test iszero(t.stop)
    t = LIKWID.stop_clock(t)
    @test !iszero(t.start)
    @test !iszero(t.stop)
    @test typeof(LIKWID.get_clock(t)) == Float64
    @test isinteger(LIKWID.get_clock_cycles(t))
end

const perfctr = `likwid-perfctr`
const julia = Base.julia_cmd()
const testdir = @__DIR__
const pkgdir = joinpath(@__DIR__, "..")

@testset "Marker API (CPU)" begin
    @testset "$f" for f in ["test_marker.jl"]
        # without marker api
        run(`$julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        @test true
        # with marker api
        run(`$perfctr -C 0 -g FLOPS_SP -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        @test true
    end
end