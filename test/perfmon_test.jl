using LIKWID
using Test

const is_github_runner = haskey(ENV, "GITHUB_ACTIONS")
const perfgrp = is_github_runner ? "MEM" : "FLOPS_SP"

@testset "PerfMon" begin
    @test PerfMon.init(0)
    @test PerfMon.init([0])
    @test PerfMon.get_number_of_threads() == 1
    @test PerfMon.get_number_of_groups() == 0
    groups = PerfMon.supported_groups()
    @test typeof(groups) == Dict{String,LIKWID.GroupInfoCompact}
    @show first(groups)
    grpinfo = first(groups)[2]
    gname = grpinfo.name
    gsinfo = grpinfo.shortinfo
    glinfo = grpinfo.longinfo
    @test PerfMon.isgroupsupported(gname)
    @test !PerfMon.isgroupsupported("loremipsum")
    # single group
    gid = PerfMon.add_event_set(gname)
    @test gid ≥ 1
    @test PerfMon.get_number_of_groups() == 1
    @test PerfMon.get_name_of_group(gid) == gname
    @test PerfMon.get_shortinfo_of_group(gid) == gsinfo
    @test strip(PerfMon.get_longinfo_of_group(gid)) == strip(glinfo)
    @test PerfMon.get_number_of_events(gid) ≥ 0
    @test PerfMon.get_number_of_metrics(gid) ≥ 0
    nevents = PerfMon.get_number_of_events(gid)
    @test isnothing(PerfMon.get_name_of_event(gid, -1))
    @test isnothing(PerfMon.get_name_of_event(gid, 0))
    @test isnothing(PerfMon.get_name_of_event(gid, nevents + 1))
    @test !isnothing(PerfMon.get_name_of_event(gid, 1))
    @test isnothing(PerfMon.get_name_of_counter(gid, 0))
    @test isnothing(PerfMon.get_name_of_counter(gid, nevents + 1))
    @test !isnothing(PerfMon.get_name_of_counter(gid, 1))
    nmetrics = PerfMon.get_number_of_metrics(gid)
    @test isnothing(PerfMon.get_name_of_metric(gid, 0))
    @test isnothing(PerfMon.get_name_of_metric(gid, nmetrics + 1))
    @test !isnothing(PerfMon.get_name_of_metric(gid, 1))

    @test PerfMon.setup_counters(gid)
    @test PerfMon.get_id_of_active_group() == gid
    @test !PerfMon.read_counters()
    @test PerfMon.start_counters()
    @test PerfMon.read_counters()
    @test PerfMon.read_counters()
    @test PerfMon.stop_counters()
    @test typeof(PerfMon.get_result(gid, 1, 1)) == Float64
    @test typeof(PerfMon.get_last_result(gid, 1, 1)) == Float64
    @test typeof(PerfMon.get_metric(gid, 1, 1)) == Float64
    @test typeof(PerfMon.get_last_metric(gid, 1, 1)) == Float64
    @test typeof(PerfMon.get_time_of_group(gid)) == Float64
    @test PerfMon.list_metrics(gid) isa Vector{String}
    @test PerfMon.get_metric_results(gid, 1) isa OrderedDict
    @test PerfMon.get_event_results(gid, 1) isa OrderedDict

    # multiple groups
    name_of_second_group = first(groups, 2)[2][1]
    gid2 = PerfMon.add_event_set(name_of_second_group)
    @test PerfMon.start_counters()
    @test PerfMon.get_id_of_active_group() == gid
    @test PerfMon.read_counters()
    @test PerfMon.switch_group(gid2)
    @test PerfMon.read_counters()
    @test PerfMon.get_id_of_active_group() == gid2
    @test PerfMon.switch_group(gid)
    @test PerfMon.get_id_of_active_group() == gid
    @test PerfMon.stop_counters()
    @test typeof(PerfMon.get_result(gid, 1, 1)) == Float64
    @test typeof(PerfMon.get_result(gid2, 1, 1)) == Float64
    @test typeof(PerfMon.get_metric(gid, 1, 1)) == Float64
    @test typeof(PerfMon.get_metric(gid2, 1, 1)) == Float64
    @test typeof(PerfMon.get_time_of_group(gid)) == Float64
    @test typeof(PerfMon.get_time_of_group(gid2)) == Float64
    @test isnothing(PerfMon.finalize())

    # high-level API
    x = rand(1000)
    y = rand(1000)
    metrics, events = perfmon(perfgrp) do
        x .+ y
    end
    @test metrics isa OrderedDict{String,Vector{OrderedDict{String,Float64}}}
    @test events isa OrderedDict{String,Vector{OrderedDict{String,Float64}}}
    metrics, events = perfmon((perfgrp, perfgrp)) do # TODO: don't use same here
        x .+ y
    end
    @test metrics isa OrderedDict{String,Vector{OrderedDict{String,Float64}}}
    @test events isa OrderedDict{String,Vector{OrderedDict{String,Float64}}}

    # @perfmon macro
    if is_github_runner
        metrics, events = @perfmon "MEM" begin
            x .+ y
        end
    else
        metrics, events = @perfmon "FLOPS_SP" begin
            x .+ y
        end
    end
    @test metrics isa OrderedDict{String,Vector{OrderedDict{String,Float64}}}
    @test events isa OrderedDict{String,Vector{OrderedDict{String,Float64}}}
end
