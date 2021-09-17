using Test
using LIKWID
using CUDA
using Libdl

# check if we are a GitHub runner
const is_github_runner = haskey(ENV, "GITHUB_ACTIONS")

# check if CUDA is available and functional
if CUDA.functional()
    @info("CUDA/GPU available.")
    const hascuda = true
else
    @info("No CUDA/GPU found.")
    const hascuda = false
    # debug information
    @show Libdl.find_library("libcuda")
    @show filter(contains("cuda"), lowercase.(Libdl.dllist()))
    try
        @info("CUDA.versioninfo():")
        CUDA.versioninfo()
        @info("Successful!")
    catch ex
        @warn("Unsuccessful!")
        println(ex)
        println()
    end
end

# check if LIKWID has been compiled with NVIDIA GPU support
@info("LIKWID NVIDIA GPU support:", LIKWID.gpusupport())

# decide whether to run GPU tests
const TEST_GPU = LIKWID.gpusupport() && hascuda
if TEST_GPU
    @info("Running all tests (CPU + GPU).")
else
    @info("Running CPU tests only.")
    if LIKWID.gpusupport() && !hascuda
        @warn("LIKWID seems to have been compiled with NVIDIA GPU support but CUDA.jl isn't functional. Did you intend to test GPU functionality?")
    end
end

const perfctr = `likwid-perfctr`
const julia = Base.julia_cmd()
const testdir = @__DIR__
const pkgdir = joinpath(@__DIR__, "..")
# On GitHub runners, FLOPS_SP doesn't seem to work...
const perfgrp = is_github_runner ? "MEM" : "FLOPS_SP"

exec(cmd::Cmd) = LIKWID._execute_test(cmd)

@testset "LIKWID.jl" begin
    @testset "Topology" begin
        @test LIKWID.init_topology()
        cputopo = LIKWID.get_cpu_topology()
        @test typeof(cputopo) == LIKWID.CpuTopology
        cpuinfo = LIKWID.get_cpu_info()
        @test typeof(cpuinfo) == LIKWID.CpuInfo
        @test isnothing(LIKWID.print_supported_cpus())
        @test isnothing(LIKWID.finalize_topology())
    end

    @testset "NUMA" begin
        @test LIKWID.init_numa()
        numinfo = LIKWID.get_numa_topology()
        @test typeof(numinfo) == LIKWID.NumaTopology
        @test numinfo.numberOfNodes ≥ 0
        numanode = first(numinfo.nodes)
        @test typeof(numanode) == LIKWID.NumaNode
        @test numanode.totalMemory ≥ 0
        @test numanode.numberOfProcessors ≥ 0
        @test typeof(numanode.processors) == Vector{Int}
        @test length(numanode.processors) == numanode.numberOfProcessors
        @test isnothing(LIKWID.finalize_numa())
    end

    @testset "Affinity" begin
        @test LIKWID.init_affinity()
        affinity = LIKWID.get_affinity()
        @test typeof(affinity) == LIKWID.AffinityDomains
        @test affinity.numberOfSocketDomains ≥ 1
        @test affinity.numberOfNumaDomains ≥ 1
        @test affinity.numberOfProcessorsPerSocket ≥ 1
        @test affinity.numberOfAffinityDomains ≥ 1
        @test typeof(affinity.domains) == Vector{LIKWID.AffinityDomain}
        @test length(affinity.domains) == affinity.numberOfAffinityDomains
        d = first(affinity.domains)
        @test typeof(d) == LIKWID.AffinityDomain
        @test typeof(d.tag) == String
        @test typeof(d.processorList) == Vector{Int}
        @test length(d.processorList) == d.numberOfProcessors
        @test isnothing(LIKWID.finalize_affinity())
    end

    @testset "Timer" begin
        @test LIKWID.init_timer()
        @test isinteger(LIKWID.get_cpu_clock())
        @test isinteger(LIKWID.get_cpu_clock_current(0))
        t = LIKWID.start_clock()
        @test !isnothing(t)
        @test !iszero(t.start)
        @test iszero(t.stop)
        t = LIKWID.stop_clock(t)
        @test !iszero(t.start)
        @test !iszero(t.stop)
        @test typeof(LIKWID.get_clock(t)) == Float64
        @test isinteger(LIKWID.get_clock_cycles(t))
        @test isnothing(LIKWID.finalize_timer())
    end

    @testset "Thermal" begin
        @test LIKWID.init_thermal(0)
        @test isinteger(LIKWID.read_thermal(0))
    end

    @testset "Power / Energy" begin
        @test LIKWID.init_power(0)
        @test isnothing(LIKWID.finalize_power())
        @test LIKWID.init_power()
        pinfo = LIKWID.get_power_info()
        @test typeof(pinfo) == LIKWID.PowerInfo
        @test typeof(pinfo.turbo) == LIKWID.TurboBoost
        @test pinfo.turbo.numSteps == length(pinfo.turbo.steps)
        @test length(pinfo.domains) == 5
        pd = pinfo.domains[1]
        @test typeof(pd) == LIKWID.PowerDomain
        @test isinteger(pd.id)
        @test 0 ≤ pd.id ≤ 4
        @test 0 ≤ Int(pd.type) ≤ 4
        @test typeof(pd.supportInfo) == Bool
        @test typeof(pd.supportStatus) == Bool
        @test typeof(pd.supportPerf) == Bool
        @test typeof(pd.supportPolicy) == Bool
        @test typeof(pd.supportLimit) == Bool
        @test isnothing(LIKWID.finalize_power())
    end

    @testset "Configuration" begin
        @test LIKWID.init_configuration()
        config = LIKWID.get_configuration()
        @test typeof(config) == LIKWID.Likwid_Configuration
        @test typeof(config.daemonMode) == LIKWID.LibLikwid.AccessMode
        @test Int(config.daemonMode) in (-1, 0, 1)
        @test LIKWID.destroy_configuration()
    end

    @testset "Access / HPM" begin
        @test LIKWID.hpmmode(0)
        @test LIKWID.hpmmode(LIKWID.LibLikwid.ACCESSMODE_DIRECT)
        @test LIKWID.init_hpm()
        @test typeof(LIKWID.hpm_add_thread(0)) == Int
        # @test LIKWID.hpm_add_thread(0) != -1
        @test isnothing(LIKWID.finalize_hpm())
    end

    @testset "PerfMon" begin
        @test LIKWID.init_perfmon([0])
        @test LIKWID.get_number_of_threads() == 1
        @test LIKWID.get_number_of_groups() == 0
        groups = LIKWID.get_groups()
        @test typeof(groups) == Vector{LIKWID.GroupInfoCompact}
        gname = groups[1].name
        gsinfo = groups[1].shortinfo
        glinfo = groups[1].longinfo
        # single group
        gid = LIKWID.add_event_set(gname)
        @test gid ≥ 0
        @test LIKWID.get_number_of_groups() == 1
        @test LIKWID.get_name_of_group(gid) == gname
        @test LIKWID.get_shortinfo_of_group(gid) == gsinfo
        @test strip(LIKWID.get_longinfo_of_group(gid)) == strip(glinfo)
        @test LIKWID.get_number_of_events(gid) ≥ 0
        @test LIKWID.get_number_of_metrics(gid) ≥ 0
        nevents = LIKWID.get_number_of_events(gid)
        @test isnothing(LIKWID.get_name_of_event(gid, -1))
        @test isnothing(LIKWID.get_name_of_event(gid, nevents))
        @test isnothing(LIKWID.get_name_of_event(gid, nevents+1))
        @test !isnothing(LIKWID.get_name_of_event(gid, 0))
        @test isnothing(LIKWID.get_name_of_counter(gid, -1))
        @test isnothing(LIKWID.get_name_of_counter(gid, nevents))
        @test !isnothing(LIKWID.get_name_of_counter(gid, 0))
        nmetrics = LIKWID.get_number_of_metrics(gid)
        @test isnothing(LIKWID.get_name_of_metric(gid, -1))
        @test isnothing(LIKWID.get_name_of_metric(gid, nmetrics))
        @test !isnothing(LIKWID.get_name_of_metric(gid, 0))

        @test LIKWID.setup_counters(gid)
        @test LIKWID.get_id_of_active_group() == gid
        @test !LIKWID.read_counters()
        @test LIKWID.start_counters()
        @test LIKWID.read_counters()
        @test LIKWID.read_counters()
        @test LIKWID.stop_counters()
        @test typeof(LIKWID.get_result(gid, 0, 0)) == Float64
        @test typeof(LIKWID.get_last_result(gid, 0, 0)) == Float64
        @test typeof(LIKWID.get_metric(gid, 0, 0)) == Float64
        @test typeof(LIKWID.get_last_metric(gid, 0, 0)) == Float64
        @test typeof(LIKWID.get_time_of_group(gid)) == Float64
        
        # multiple groups
        gid2 = LIKWID.add_event_set(groups[2].name)
        @test LIKWID.start_counters()
        @test LIKWID.get_id_of_active_group() == gid
        @test LIKWID.read_counters()
        @test LIKWID.switch_group(gid2)
        @test LIKWID.read_counters()
        @test LIKWID.get_id_of_active_group() == gid2
        @test LIKWID.switch_group(gid)
        @test LIKWID.get_id_of_active_group() == gid
        @test LIKWID.stop_counters()
        @test typeof(LIKWID.get_result(gid, 0, 0)) == Float64
        @test typeof(LIKWID.get_result(gid2, 0, 0)) == Float64
        @test typeof(LIKWID.get_metric(gid, 0, 0)) == Float64
        @test typeof(LIKWID.get_metric(gid2, 0, 0)) == Float64
        @test typeof(LIKWID.get_time_of_group(gid)) == Float64
        @test typeof(LIKWID.get_time_of_group(gid2)) == Float64
    end

    @testset "Misc" begin
        @test LIKWID.setverbosity(0)
        @test typeof(LIKWID.get_processor_id()) == Int
        @test typeof(LIKWID.pinprocess(0)) == Bool
        @test typeof(LIKWID.pinthread(0)) == Bool
    end

    @testset "Marker API (CPU)" begin
        # with active marker api
        @testset "$f" for f in ["test_marker.jl"]
            @test exec(`$perfctr -C 0 -g $(perfgrp) -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        end
        # without marker api
        @testset "$f" for f in ["test_marker_noapi.jl"]
           @test exec(`$julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        end
    end

    @testset "Marker File Reader" begin
        f = "test_markerfile.jl"
        @test exec(`$perfctr -C 0 -g $(perfgrp) -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
    end

    @testset "Pylikwid Example" begin
        include("test_pylikwid.jl")
    end

    # ------- GPU -------
    if hascuda
        @testset "GPU Topology" begin
            @test LIKWID.init_topology_gpu()
            gputopo = LIKWID.get_gpu_topology()
            @test typeof(gputopo) == LIKWID.GpuTopology
            gpu = gputopo.devices[1]
            @test typeof(gpu) == LIKWID.GpuDevice
            @test typeof(gpu.name) == String
            @test typeof(gpu.mem) == Int
            @test typeof(gpu.maxThreadsDim) == NTuple{3, Int}
            @test typeof(gpu.maxGridSize) == NTuple{3, Int}
            @test isnothing(LIKWID.finalize_topology_gpu())
        end
        
        # According to @TomTheBear, this shouldn't be used yet
        @testset "GPU PerfMon / NvMon" begin
            @test_throws MethodError LIKWID.Nvmon.init()
            @test LIKWID.Nvmon.init([0])
            @test LIKWID.Nvmon.get_number_of_gpus() == 1
            @test LIKWID.Nvmon.get_number_of_groups() == 0
            groups = LIKWID.Nvmon.get_groups(0)
            @test typeof(groups) == Vector{LIKWID.GroupInfoCompact}
            gname = groups[1].name
            gsinfo = groups[1].shortinfo
            glinfo = groups[1].longinfo
            # single group
            gid = LIKWID.Nvmon.add_event_set(gname)
            @test gid ≥ 0
            @test LIKWID.Nvmon.get_number_of_groups() == 1
            @test LIKWID.Nvmon.get_name_of_group(gid) == gname
            @test LIKWID.Nvmon.get_shortinfo_of_group(gid) == gsinfo
            @test strip(LIKWID.Nvmon.get_longinfo_of_group(gid)) == strip(glinfo)
            @test LIKWID.Nvmon.get_number_of_events(gid) ≥ 0
            @test LIKWID.Nvmon.get_number_of_metrics(gid) ≥ 0
            nevents = LIKWID.Nvmon.get_number_of_events(gid)
            @test isnothing(LIKWID.Nvmon.get_name_of_event(gid, -1))
            @test isnothing(LIKWID.Nvmon.get_name_of_event(gid, nevents))
            @test isnothing(LIKWID.Nvmon.get_name_of_event(gid, nevents+1))
            @test !isnothing(LIKWID.Nvmon.get_name_of_event(gid, 0))
            @test isnothing(LIKWID.Nvmon.get_name_of_counter(gid, -1))
            @test isnothing(LIKWID.Nvmon.get_name_of_counter(gid, nevents))
            @test !isnothing(LIKWID.Nvmon.get_name_of_counter(gid, 0))
            nmetrics = LIKWID.Nvmon.get_number_of_metrics(gid)
            @test isnothing(LIKWID.Nvmon.get_name_of_metric(gid, -1))
            @test isnothing(LIKWID.Nvmon.get_name_of_metric(gid, nmetrics))
            @test !isnothing(LIKWID.Nvmon.get_name_of_metric(gid, 0))
        
            @test LIKWID.Nvmon.setup_counters(gid)
            @test LIKWID.Nvmon.get_id_of_active_group() == gid
            @test_broken !LIKWID.Nvmon.read_counters() # error 7
            @test_broken LIKWID.Nvmon.start_counters() # error 1
            @test LIKWID.Nvmon.read_counters()
            @test LIKWID.Nvmon.read_counters()
            @test LIKWID.Nvmon.stop_counters()
            @test typeof(LIKWID.Nvmon.get_result(gid, 0, 0)) == Float64
            @test typeof(LIKWID.Nvmon.get_last_result(gid, 0, 0)) == Float64
            @test_broken typeof(LIKWID.Nvmon.get_metric(gid, 0, 0)) == Float64 # undefined symbol nvmon_getMetric
            @test_broken typeof(LIKWID.Nvmon.get_last_metric(gid, 0, 0)) == Float64 # undefined symbol nvmon_getLastMetric
            @test typeof(LIKWID.Nvmon.get_time_of_group(gid)) == Float64
            
            # multiple groups
            gid2 = LIKWID.Nvmon.add_event_set(groups[2].name)
            @test LIKWID.Nvmon.start_counters()
            @test LIKWID.Nvmon.get_id_of_active_group() == gid
            @test LIKWID.Nvmon.read_counters()
            @test LIKWID.Nvmon.switch_group(gid2)
            @test LIKWID.Nvmon.read_counters()
            @test LIKWID.Nvmon.get_id_of_active_group() == gid2
            @test LIKWID.Nvmon.switch_group(gid)
            @test LIKWID.Nvmon.get_id_of_active_group() == gid
            @test LIKWID.Nvmon.stop_counters()
            @test typeof(LIKWID.Nvmon.get_result(gid, 0, 0)) == Float64
            @test typeof(LIKWID.Nvmon.get_result(gid2, 0, 0)) == Float64
            @test_broken typeof(LIKWID.Nvmon.get_metric(gid, 0, 0)) == Float64 # undefined symbol nvmon_getMetric
            @test_broken typeof(LIKWID.Nvmon.get_metric(gid2, 0, 0)) == Float64 # undefined symbol nvmon_getMetric
            @test typeof(LIKWID.Nvmon.get_time_of_group(gid)) == Float64
            @test typeof(LIKWID.Nvmon.get_time_of_group(gid2)) == Float64
        end

        @testset "Marker API (GPU)" begin
            # print perf groups
            # LIKWID._execute_test(`likwid-perfctr -a`; print_only_on_fail=false)
            # read gpu perf group
            LIKWID.Nvmon.init([0])
            perfgrp_gpu = LIKWID.Nvmon.get_groups()[1].name
            LIKWID.Nvmon.finalize()
            # # dev LIKWID.jl + add CUDA
            # withenv("JULIA_CUDA_USE_BINARYBUILDER" => false) do
            #     rm(joinpath(testdir, "Manifest.toml"), force=true)
            #     rm(joinpath(testdir, "Project.toml"), force=true)
            #     @test exec(`$julia --project=$(testdir) -e 'using Pkg; Pkg.develop(path="$(joinpath(testdir, "../"))"); Pkg.add("CUDA"); Pkg.precompile();'`)
            #     @test exec(`$julia --project=$(testdir) -e 'using CUDA; CUDA.functional()'`)
            # end
            # without gpu marker api
            @testset "$f" for f in ["test_marker_gpu_noapi.jl"]
                @test exec(`$julia --project=$(testdir) $(joinpath(testdir, f))`)
            end
            # with active gpu marker api
            @testset "$f" for f in ["test_marker_gpu.jl"]
                @test exec(`$perfctr -G 0 -W $(perfgrp_gpu) -m $julia --project=$(testdir) $(joinpath(testdir, f))`)
            end
        end
    end

end