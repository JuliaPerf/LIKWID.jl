using LIKWID
using Test
using Unitful

if LIKWID.accessmode() != LIKWID.LibLikwid.ACCESSMODE_DAEMON
    @warn("Skipping power_test.jl (LIKWID daemon required)")
else
    @testset "Power / Energy" begin
        @test LIKWID.Power.init(0)
        @test isnothing(LIKWID.Power.finalize())
        @test LIKWID.Power.init()
        pinfo = LIKWID.Power.get_power_info()
        @test typeof(pinfo) == LIKWID.PowerInfo
        @test typeof(pinfo.turbo) == LIKWID.TurboBoost
        @test pinfo.turbo.numSteps == length(pinfo.turbo.steps)
        @test length(pinfo.domains) == 5
        pd = pinfo.domains[1]
        @test typeof(pd) == LIKWID.PowerDomain
        @test isinteger(pd.id)
        @test 0 ≤ pd.id ≤ 4
        @test 0 ≤ Int(pd.type) ≤ 4
        @test typeof(pd.supportInfo) == Bool
        @test typeof(pd.supportStatus) == Bool
        @test typeof(pd.supportPerf) == Bool
        @test typeof(pd.supportPolicy) == Bool
        @test typeof(pd.supportLimit) == Bool

        p_start = LIKWID.Power.start_power(0, 0)
        @test typeof(p_start) == Int64
        sleep(0.5)
        p_stop = LIKWID.Power.stop_power(0, 0)
        @test typeof(p_stop) == Int64
        res = LIKWID.Power.get_power(p_start, p_stop, 0)
        @test unit(res) == u"μJ"

        # convenience functions / macros
        res = LIKWID.Power.measure(; cpuid=0, domainid=0) do
            sleep(0.5)
        end
        @test unit(res) == u"μJ"
        @test typeof(ustrip(res)) == Float64

        @test isnothing(LIKWID.Power.finalize())
    end
end
