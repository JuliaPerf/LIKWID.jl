using LIKWID
using Test

const likwidperfctr = `likwid-perfctr`
const is_github_runner = haskey(ENV, "GITHUB_ACTIONS")
const perfgrp = is_github_runner ? "MEM" : "FLOPS_SP"
const julia = Base.julia_cmd()
const testdir = @__DIR__
const pkgdir = joinpath(@__DIR__, "../..")
exec(cmd::Cmd) = LIKWID._execute_test(cmd)

@testset "Marker File Reader (CLI)" begin
    f = "test_markerfile.jl"
    @test exec(`$likwidperfctr -C 0 -g $(perfgrp) -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
end
