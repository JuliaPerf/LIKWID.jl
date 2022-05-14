# perfmon.jl
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

cpu = 0 # starts with zero!
LIKWID.PerfMon.init(cpu)
groupid = LIKWID.PerfMon.add_event_set("FLOPS_DP")
LIKWID.PerfMon.setup_counters(groupid)

LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

mdict = LIKWID.PerfMon.get_metric_results(groupid, 1)
display(mdict)
println(); flush(stdout);
edict = LIKWID.PerfMon.get_event_results(groupid, 1)
display(edict)

LIKWID.PerfMon.finalize()