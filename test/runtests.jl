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
    @test isnothing(LIKWID.finalize_numa())
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