using LIKWID
using Octavian

const A = rand(1000, 1000)
const B = rand(1000, 1000)
const C = zeros(1000, 1000)

metrics, events = @perfmon "FLOPS_DP" begin for _ in 1:10
    matmul!(C, A, B)
end end

@show getindex.(events["FLOPS_DP"], "RETIRED_SSE_AVX_FLOPS_ALL");
@show getindex.(metrics["FLOPS_DP"], "DP [MFLOP/s]");
