using LIKWID
using Test

const likwidperfctr = `likwid-perfctr`
const julia = Base.julia_cmd()
const testdir = @__DIR__
const pkgdir = joinpath(@__DIR__, "../../..")
exec(cmd::Cmd) = LIKWID._execute_test(cmd)

NvMon.init([0])
const perfgrp_gpu = first(NvMon.supported_groups())[1]
NvMon.finalize()

@testset "Marker API GPU (CLI)" begin
    # without gpu marker api
    @testset "$f" for f in ["test_marker_gpu_noapi.jl"]
        @test exec(`$julia --project=$(testdir) $(joinpath(testdir, f))`)
    end
    # with active gpu marker api
    @testset "$f" for f in ["test_marker_gpu.jl", "test_marker_gpu_convenience.jl"]
        @test exec(`$likwidperfctr -G 0 -W $(perfgrp_gpu) -m $julia --project=$(testdir) $(joinpath(testdir, f))`)
    end
end
