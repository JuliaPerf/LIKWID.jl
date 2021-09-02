using Test
using LIKWID
using LinearAlgebra

@testset "Marker API" begin
    N = 100_000_000
    a = 3.141f0
    z = zeros(Float32, N)
    x = rand(Float32, N)
    y = rand(Float32, N)

    function saxpy_cpu!(z,a,x,y)
        z .= a .* x .+ y
    end

    saxpy_cpu!(z,a,x,y)
    LIKWID.Marker.startregion("saxpy_cpu!")
    saxpy_cpu!(z,a,x,y)
    LIKWID.Marker.stopregion("saxpy_cpu!")
end