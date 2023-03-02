using LIKWID
using Test

@testset "Topology" begin
    @test LIKWID.init_topology()
    cputopo = LIKWID.get_cpu_topology()
    @test typeof(cputopo) == LIKWID.CpuTopology
    cpuinfo = LIKWID.get_cpu_info()
    @test typeof(cpuinfo) == LIKWID.CpuInfo
    @test isnothing(LIKWID.print_supported_cpus())
    @test isnothing(LIKWID.finalize_topology())
end
