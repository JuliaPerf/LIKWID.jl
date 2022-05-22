# Translation of pylikwid example from https://github.com/RRZE-HPC/pylikwid
using Test
using Printf
using LIKWID

list = Int[]
cpus = [0,1]
@test PerfMon.init(cpus)
if PerfMon.isgroupsupported("FLOPS_SP")
    group = PerfMon.add_event_set("FLOPS_SP")
else
    group = PerfMon.add_event_set("CLOCK")
end
@test group == 1
@test PerfMon.setup_counters(group)
@test PerfMon.start_counters()
for i in 1:1_000_000
    push!(list,i)
end
@test PerfMon.stop_counters()
for thread in 1:length(cpus)
    @printf("Result CPU %d : %f\n", cpus[thread], PerfMon.get_result(group,1,thread))
end