push!(LOAD_PATH, "../..")
using LIKWID
LIKWID.gpusupport()
NvMon.init([0])
gid = NvMon.add_event_set("FLOPS_DP")
NvMon.setup_counters(gid)
NvMon.start_counters()
NvMon.stop_counters()
