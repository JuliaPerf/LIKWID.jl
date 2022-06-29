using LIKWID
using Test

if LIKWID.accessmode() != LIKWID.LibLikwid.ACCESSMODE_DAEMON
    @warn("Skipping access_test.jl (LIKWID daemon required)")
else
    @testset "Access / HPM" begin
        @test LIKWID.HPM.mode(0)
        @test LIKWID.HPM.mode(LIKWID.LibLikwid.ACCESSMODE_DIRECT)
        @test LIKWID.HPM.init()
        @test typeof(LIKWID.HPM.add_thread(0)) == Int
        # @test LIKWID.hpm_add_thread(0) != -1
        @test isnothing(LIKWID.HPM.finalize())
    end
end
