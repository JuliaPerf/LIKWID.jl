using LIKWID
using Test
using IterTools

@assert CUDA.functional()
@assert LIKWID.gpusupport()

@testset "NvMon (GPU)" begin
    @test NvMon.init([0])
    @test NvMon.init()
    @test NvMon.get_number_of_gpus() ≥ 1
    @test NvMon.get_number_of_groups() == 0
    groups = NvMon.supported_groups(0)
    @test typeof(groups) == Dict{String, LIKWID.GroupInfoCompact}
    grpinfo = first(groups)[2]
    gname = grpinfo.name
    gsinfo = grpinfo.shortinfo
    glinfo = grpinfo.longinfo
    @test NvMon.isgroupsupported(gname, 0)
    @test !NvMon.isgroupsupported("loremipsum", 0)
    # single group
    gid = NvMon.add_event_set(gname)
    @test gid ≥ 1
    @test NvMon.get_number_of_groups() == 1
    @test NvMon.get_name_of_group(gid) == gname
    @test NvMon.get_shortinfo_of_group(gid) == gsinfo
    @test strip(NvMon.get_longinfo_of_group(gid)) == strip(glinfo)
    @test NvMon.get_number_of_events(gid) ≥ 0
    @test NvMon.get_number_of_metrics(gid) ≥ 0
    nevents = NvMon.get_number_of_events(gid)
    @test isnothing(NvMon.get_name_of_event(gid, -1))
    @test isnothing(NvMon.get_name_of_event(gid, 0))
    @test isnothing(NvMon.get_name_of_event(gid, nevents + 1))
    @test !isnothing(NvMon.get_name_of_event(gid, 1))
    @test isnothing(NvMon.get_name_of_counter(gid, 0))
    @test isnothing(NvMon.get_name_of_counter(gid, nevents + 1))
    @test !isnothing(NvMon.get_name_of_counter(gid, 1))
    nmetrics = NvMon.get_number_of_metrics(gid)
    @test isnothing(NvMon.get_name_of_metric(gid, 0))
    @test isnothing(NvMon.get_name_of_metric(gid, nmetrics + 1))
    @test !isnothing(NvMon.get_name_of_metric(gid, 1))

    @test NvMon.setup_counters(gid)
    @test NvMon.get_id_of_active_group() == gid
    @test_broken !NvMon.read_counters() # error 7
    @test_broken NvMon.start_counters() # error 1
    @test NvMon.read_counters()
    @test NvMon.read_counters()
    @test NvMon.stop_counters()
    @test typeof(NvMon.get_result(gid, 1, 1)) == Float64
    @test typeof(NvMon.get_last_result(gid, 1, 1)) == Float64
    @test_broken typeof(NvMon.get_metric(gid, 1, 1)) == Float64 # undefined symbol nvmon_getMetric
    @test_broken typeof(NvMon.get_last_metric(gid, 1, 1)) == Float64 # undefined symbol nvmon_getLastMetric
    @test typeof(NvMon.get_time_of_group(gid)) == Float64

    # multiple groups
    gid2 = NvMon.add_event_set(nth(groups, 2)[1])
    @test NvMon.start_counters()
    @test NvMon.get_id_of_active_group() == gid
    @test NvMon.read_counters()
    @test NvMon.switch_group(gid2)
    @test NvMon.read_counters()
    @test NvMon.get_id_of_active_group() == gid2
    @test NvMon.switch_group(gid)
    @test NvMon.get_id_of_active_group() == gid
    @test NvMon.stop_counters()
    @test typeof(NvMon.get_result(gid, 1, 1)) == Float64
    @test typeof(NvMon.get_result(gid2, 1, 1)) == Float64
    @test_broken typeof(NvMon.get_metric(gid, 1, 1)) == Float64 # undefined symbol nvmon_getMetric
    @test_broken typeof(NvMon.get_metric(gid2, 1, 1)) == Float64 # undefined symbol nvmon_getMetric
    @test typeof(NvMon.get_time_of_group(gid)) == Float64
    @test typeof(NvMon.get_time_of_group(gid2)) == Float64
end
