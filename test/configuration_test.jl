using LIKWID
using Test

@testset "Configuration" begin
    @test LIKWID.init_configuration()
    config = LIKWID.get_configuration()
    @test typeof(config) == LIKWID.Likwid_Configuration
    @test typeof(config.daemonMode) == LIKWID.LibLikwid.AccessMode
    @test Int(config.daemonMode) in (-1, 0, 1)
    @test LIKWID.destroy_configuration()
end
