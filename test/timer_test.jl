using LIKWID
using Test

@testset "Timer" begin
    @test LIKWID.Timer.init()
    @test isinteger(LIKWID.Timer.get_cpu_clock())
    @test isinteger(LIKWID.Timer.get_cpu_clock_current(0))
    t = LIKWID.Timer.start_clock()
    @test !isnothing(t)
    @test !iszero(t.start)
    @test iszero(t.stop)
    t = LIKWID.Timer.stop_clock(t)
    @test !iszero(t.start)
    @test !iszero(t.stop)
    @test typeof(LIKWID.Timer.get_clock(t)) == Float64
    @test isinteger(LIKWID.Timer.get_clock_cycles(t))

    # convenience functions / macros
    @test typeof(LIKWID.Timer.@timeit 1 + 3) == NamedTuple{(:clock, :cycles),Tuple{Float64,Int64}}
    @test typeof(LIKWID.Timer.timeit(() -> 1 + 3)) == NamedTuple{(:clock, :cycles),Tuple{Float64,Int64}}
    @test typeof(
        LIKWID.Timer.timeit() do
            1 + 3
        end
    ) == NamedTuple{(:clock, :cycles),Tuple{Float64,Int64}}

    @test isnothing(LIKWID.Timer.finalize())
end
