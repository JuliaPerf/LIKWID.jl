using LIKWID
using LinearAlgebra

const A = rand(1000, 1000)
const B = rand(1000, 1000)
const C = zeros(1000, 1000)

nvcores = LIKWID.num_virtual_cores()

LIKWID.pinthread(nvcores - 1) # pinning the single Julia thread

PerfMon.init(0:(nvcores - 1))
groupid = PerfMon.add_event_set("FLOPS_DP")
PerfMon.setup_counters(groupid)

PerfMon.start_counters()
for _ in 1:10
    mul!(C, A, B)
end
PerfMon.stop_counters()

@show PerfMon.get_event_results("FLOPS_DP", "RETIRED_SSE_AVX_FLOPS_ALL");
@show PerfMon.get_metric_results("FLOPS_DP", "DP [MFLOP/s]");
