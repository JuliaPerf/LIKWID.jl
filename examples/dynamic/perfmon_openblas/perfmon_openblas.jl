using LIKWID
using LinearAlgebra

nvcores = LIKWID.num_virtual_cores()
LIKWID.pinthread(nvcores - 1) # pinning the single Julia thread

const A = rand(1000, 1000)
const B = rand(1000, 1000)
const C = zeros(1000, 1000)

metrics, events = perfmon("FLOPS_DP"; cpuids=0:nvcores-1, autopin=false) do
    for _ in 1:10
        mul!(C, A, B)
    end
end

@show getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL");
@show getindex.(metrics, "DP [MFLOP/s]");