# perfmon.jl
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

cpu = 0 # starts with zero!
LIKWID.pinthread(cpu) # pin your thread!
PerfMon.init(cpu)
groupid = PerfMon.add_event_set("FLOPS_DP")
PerfMon.setup_counters(groupid)

PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
PerfMon.stop_counters()

mdict = PerfMon.get_metric_results(groupid, 1)
display(mdict)
println();
flush(stdout);
edict = PerfMon.get_event_results(groupid, 1)
display(edict)

PerfMon.finalize()
