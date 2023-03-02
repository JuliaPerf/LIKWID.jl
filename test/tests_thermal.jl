using LIKWID
using Test
using Unitful

if LIKWID.accessmode() != LIKWID.LibLikwid.ACCESSMODE_DAEMON
    @warn("Skipping thermal_test.jl (LIKWID daemon required)")
else
    @testset "Thermal" begin
        @test LIKWID.init_thermal(0)
        @test isinteger(ustrip(LIKWID.get_temperature(0)))
        @test unit(LIKWID.get_temperature(0)) == u"°C"
    end
end
