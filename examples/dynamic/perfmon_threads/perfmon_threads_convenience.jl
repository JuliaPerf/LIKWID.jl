using LIKWID
using LinearAlgebra

const N = 10_000
const a = 3.141
const x = rand(N)
const y = rand(N)
const z = zeros(N)

metrics, events = @perfmon "FLOPS_DP" begin
    Threads.@threads for i in eachindex(x, y)
        z[i] = a * x[i] * y[i]
    end
end

@show getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL");
@show getindex.(metrics, "DP [MFLOP/s]");