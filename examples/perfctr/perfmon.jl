# julia perfmon.jl
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

# ncpus = LIKWID.get_cpu_topology().numCoresPerSocket
ncpus = 1
cpus = collect(0:ncpus-1)
LIKWID.PerfMon.init(cpus)
groupid = LIKWID.PerfMon.add_event_set("FLOPS_DP")
LIKWID.PerfMon.setup_counters(groupid)
LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

LIKWID.PerfMon.start_counters()
for _ in 1:100
    mul!(C, A, B)
end
LIKWID.PerfMon.stop_counters()

for cpu in cpus
    @show cpu
    d = LIKWID.PerfMon.get_metric_results(groupid, cpu)
    display(d)
    println()
    d = LIKWID.PerfMon.get_event_results(groupid, cpu)
    display(d)
    println()
end
LIKWID.PerfMon.finalize()