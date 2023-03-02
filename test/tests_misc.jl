using LIKWID
using Test

@testset "Misc" begin
    @test LIKWID.setverbosity(0)
    @test LIKWID.pinmask(8) == "0xfffffffffffffe01"
    d = LIKWID.env()
    @test typeof(d) == Dict{String, String}
    for k in keys(d)
        @test startswith(k, "LIKWID")
    end
    LIKWID.clearenv()
    @test isempty(LIKWID.env())
    LIKWID.LIKWID_FORCE(true)
    @test LIKWID.LIKWID_FORCE() == "1"
    @test ENV["LIKWID_FORCE"] == "1"
    LIKWID.LIKWID_NO_ACCESS(true)
    @test LIKWID.LIKWID_NO_ACCESS() == "1"
    @test ENV["LIKWID_NO_ACCESS"] == "1"
    LIKWID.LIKWID_PIN("0,1,2,3")
    @test LIKWID.LIKWID_PIN() == "0,1,2,3"
    @test ENV["LIKWID_PIN"] == "0,1,2,3"
    LIKWID.LIKWID_SILENT(true)
    @test LIKWID.LIKWID_SILENT() == "1"
    @test ENV["LIKWID_SILENT"] == "1"
    LIKWID.LIKWID_SKIP(LIKWID.pinmask(8))
    @test LIKWID.LIKWID_SKIP() == LIKWID.pinmask(8)
    @test ENV["LIKWID_SKIP"] == LIKWID.pinmask(8)
    LIKWID.LIKWID_DEBUG(3)
    @test LIKWID.LIKWID_DEBUG() == "3"
    @test ENV["LIKWID_DEBUG"] == "3"
    LIKWID.LIKWID_IGNORE_CPUSET(true)
    @test LIKWID.LIKWID_IGNORE_CPUSET() == "1"
    @test ENV["LIKWID_IGNORE_CPUSET"] == "1"
    LIKWID.LIKWID_FILEPATH("asd")
    @test LIKWID.LIKWID_FILEPATH() == "asd"
    @test ENV["LIKWID_FILEPATH"] == "asd"
    LIKWID.LIKWID_MODE(1)
    @test LIKWID.LIKWID_MODE() == "1"
    @test ENV["LIKWID_MODE"] == "1"
    LIKWID.LIKWID_EVENTS("FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0")
    @test LIKWID.LIKWID_EVENTS() == "FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0"
    @test ENV["LIKWID_EVENTS"] == "FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0"
    LIKWID.LIKWID_THREADS("0,1,2,3")
    @test LIKWID.LIKWID_THREADS() == "0,1,2,3"
    @test ENV["LIKWID_THREADS"] == "0,1,2,3"
    LIKWID.LIKWID_MPI_CONNECT("asd")
    @test LIKWID.LIKWID_MPI_CONNECT() == "asd"
    @test ENV["LIKWID_MPI_CONNECT"] == "asd"
    LIKWID.clearenv()
    # restore original values
    for (k, v) in d
        ENV[k] = v
    end
end
