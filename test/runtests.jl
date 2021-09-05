using Test
using LIKWID

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
        run(`$perfctr -C 0 -g MEM -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        @test true
    end
end