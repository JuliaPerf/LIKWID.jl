using Test
using LIKWID
using CUDA
using IterTools
using Libdl
using OrderedCollections
using Unitful
using Random

# check if we are a GitHub runner
const is_github_runner = haskey(ENV, "GITHUB_ACTIONS")
const isCI = is_github_runner || haskey(ENV, "CI")
const DEBUGINFO = isCI || get(ENV, "DEBUGINFO", false) # can turn on debug info with DEBUGINFO=true

# check if CUDA is available and functional
if CUDA.functional()
    @info("CUDA/GPU available.")
    const hascuda = true
else
    @info("No CUDA/GPU found.")
    const hascuda = false
    if isCI
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
end

# check if LIKWID has been compiled with NVIDIA GPU support
const haslikwidgpu = LIKWID.gpusupport()
@info("LIKWID NVIDIA GPU support:", haslikwidgpu)

# decide whether to run GPU tests
const TEST_GPU = haslikwidgpu && hascuda
if TEST_GPU
    @info("Running all tests (CPU + GPU).")
else
    @info("Running CPU tests only.")
    if haslikwidgpu && !hascuda
        @warn("LIKWID seems to have been compiled with NVIDIA GPU support but CUDA.jl isn't functional. Did you intend to test GPU functionality?")
    end
end

@show Threads.nthreads()
const TEST_THREADS = Threads.nthreads() > 1
TEST_THREADS || @warn("Threads.nthreads == 1 -> NOT running multithreading tests!")

const TEST_DAEMON = LIKWID.accessmode() == LIKWID.LibLikwid.ACCESSMODE_DAEMON

const likwidperfctr = `likwid-perfctr`
const likwidpin = `likwid-pin`
const julia = Base.julia_cmd()
const testdir = @__DIR__
const pkgdir = joinpath(@__DIR__, "..")
# On GitHub runners, FLOPS_SP doesn't seem to work...
const perfgrp = is_github_runner ? "MEM" : "FLOPS_SP"

exec(cmd::Cmd) = LIKWID._execute_test(cmd)

@testset "LIKWID.jl" begin # ------- Regular -------
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
        @test LIKWID.Timer.init()
        @test isinteger(LIKWID.Timer.get_cpu_clock())
        @test isinteger(LIKWID.Timer.get_cpu_clock_current(0))
        t = LIKWID.Timer.start_clock()
        @test !isnothing(t)
        @test !iszero(t.start)
        @test iszero(t.stop)
        t = LIKWID.Timer.stop_clock(t)
        @test !iszero(t.start)
        @test !iszero(t.stop)
        @test typeof(LIKWID.Timer.get_clock(t)) == Float64
        @test isinteger(LIKWID.Timer.get_clock_cycles(t))

        # convenience functions / macros
        @test typeof(LIKWID.Timer.@timeit 1 + 3) ==
              NamedTuple{(:clock, :cycles), Tuple{Float64, Int64}}
        @test typeof(LIKWID.Timer.timeit(() -> 1 + 3)) ==
              NamedTuple{(:clock, :cycles), Tuple{Float64, Int64}}
        @test typeof(LIKWID.Timer.timeit() do
                         1 + 3
                     end) == NamedTuple{(:clock, :cycles), Tuple{Float64, Int64}}

        @test isnothing(LIKWID.Timer.finalize())
    end

    if TEST_DAEMON
        @testset "Thermal" begin
            @test LIKWID.init_thermal(0)
            @test isinteger(ustrip(LIKWID.get_temperature(0)))
            @test unit(LIKWID.get_temperature(0)) == u"°C"
        end
    end

    if TEST_DAEMON
        @testset "Power / Energy" begin
            @test LIKWID.Power.init(0)
            @test isnothing(LIKWID.Power.finalize())
            @test LIKWID.Power.init()
            pinfo = LIKWID.Power.get_power_info()
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

            p_start = LIKWID.Power.start_power(0, 0)
            @test typeof(p_start) == Int64
            sleep(0.5)
            p_stop = LIKWID.Power.stop_power(0, 0)
            @test typeof(p_stop) == Int64
            res = LIKWID.Power.get_power(p_start, p_stop, 0)
            @test unit(res) == u"μJ"

            # convenience functions / macros
            res = LIKWID.Power.measure(; cpuid = 0, domainid = 0) do
                sleep(0.5)
            end
            @test unit(res) == u"μJ"
            @test typeof(ustrip(res)) == Float64

            @test isnothing(LIKWID.Power.finalize())
        end
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
        @test LIKWID.HPM.mode(0)
        @test LIKWID.HPM.mode(LIKWID.LibLikwid.ACCESSMODE_DIRECT)
        @test LIKWID.HPM.init()
        @test typeof(LIKWID.HPM.add_thread(0)) == Int
        # @test LIKWID.hpm_add_thread(0) != -1
        @test isnothing(LIKWID.HPM.finalize())
    end

    @testset "PerfMon" begin
        @test PerfMon.init(0)
        @test PerfMon.init([0])
        @test PerfMon.get_number_of_threads() == 1
        @test PerfMon.get_number_of_groups() == 0
        groups = PerfMon.supported_groups()
        @test typeof(groups) == Dict{String, LIKWID.GroupInfoCompact}
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
        @test metrics isa OrderedDict{String, Vector{OrderedDict{String, Float64}}}
        @test events isa OrderedDict{String, Vector{OrderedDict{String, Float64}}}
        metrics, events = perfmon((perfgrp, perfgrp)) do # TODO: don't use same here
            x .+ y
        end
        @test metrics isa OrderedDict{String, Vector{OrderedDict{String, Float64}}}
        @test events isa OrderedDict{String, Vector{OrderedDict{String, Float64}}}

        # @perfmon macro
        if is_github_runner
            metrics, events = @perfmon "MEM" begin x .+ y end
        else
            metrics, events = @perfmon "FLOPS_SP" begin x .+ y end
        end
        @test metrics isa OrderedDict{String, Vector{OrderedDict{String, Float64}}}
        @test events isa OrderedDict{String, Vector{OrderedDict{String, Float64}}}
    end

    @testset "Misc" begin
        @test LIKWID.setverbosity(0)
        @test LIKWID.pinmask(8) == "0xfffffffffffffe01"
        d = LIKWID.env()
        @test typeof(d) == Dict{String, String}
        for k in keys(d)
            @test startswith(k, "LIKWID")
        end
        LIKWID.clearenv()
        @test isempty(LIKWID.env())
        LIKWID.LIKWID_FORCE(true)
        @test LIKWID.LIKWID_FORCE() == "1"
        @test ENV["LIKWID_FORCE"] == "1"
        LIKWID.LIKWID_NO_ACCESS(true)
        @test LIKWID.LIKWID_NO_ACCESS() == "1"
        @test ENV["LIKWID_NO_ACCESS"] == "1"
        LIKWID.LIKWID_PIN("0,1,2,3")
        @test LIKWID.LIKWID_PIN() == "0,1,2,3"
        @test ENV["LIKWID_PIN"] == "0,1,2,3"
        LIKWID.LIKWID_SILENT(true)
        @test LIKWID.LIKWID_SILENT() == "1"
        @test ENV["LIKWID_SILENT"] == "1"
        LIKWID.LIKWID_SKIP(LIKWID.pinmask(8))
        @test LIKWID.LIKWID_SKIP() == LIKWID.pinmask(8)
        @test ENV["LIKWID_SKIP"] == LIKWID.pinmask(8)
        LIKWID.LIKWID_DEBUG(3)
        @test LIKWID.LIKWID_DEBUG() == "3"
        @test ENV["LIKWID_DEBUG"] == "3"
        LIKWID.LIKWID_IGNORE_CPUSET(true)
        @test LIKWID.LIKWID_IGNORE_CPUSET() == "1"
        @test ENV["LIKWID_IGNORE_CPUSET"] == "1"
        LIKWID.LIKWID_FILEPATH("asd")
        @test LIKWID.LIKWID_FILEPATH() == "asd"
        @test ENV["LIKWID_FILEPATH"] == "asd"
        LIKWID.LIKWID_MODE(1)
        @test LIKWID.LIKWID_MODE() == "1"
        @test ENV["LIKWID_MODE"] == "1"
        LIKWID.LIKWID_EVENTS("FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0")
        @test LIKWID.LIKWID_EVENTS() == "FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0"
        @test ENV["LIKWID_EVENTS"] == "FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0"
        LIKWID.LIKWID_THREADS("0,1,2,3")
        @test LIKWID.LIKWID_THREADS() == "0,1,2,3"
        @test ENV["LIKWID_THREADS"] == "0,1,2,3"
        LIKWID.LIKWID_MPI_CONNECT("asd")
        @test LIKWID.LIKWID_MPI_CONNECT() == "asd"
        @test ENV["LIKWID_MPI_CONNECT"] == "asd"
        LIKWID.clearenv()
        # restore original values
        for (k, v) in d
            ENV[k] = v
        end
    end

    @testset "Marker API (CPU)" begin
        # with active marker api
        @testset "$f" for f in ["test_marker.jl", "test_marker_convenience.jl"]
            @test exec(`$likwidperfctr -C 0 -g $(perfgrp) -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        end
        # without marker api
        @testset "$f" for f in ["test_marker_noapi.jl"]
            @test exec(`$julia --project=$(pkgdir) $(joinpath(testdir, f))`)
        end
    end

    @testset "Marker File Reader" begin
        f = "test_markerfile.jl"
        @test exec(`$likwidperfctr -C 0 -g $(perfgrp) -m $julia --project=$(pkgdir) $(joinpath(testdir, f))`)
    end

    @testset "Pylikwid Example" begin
        @test exec(`$julia --project=$(pkgdir) $(joinpath(testdir, "test_pylikwid.jl"))`)
    end

    # ------- Multithreading -------
    if TEST_THREADS
        # LIKWID.finalize() # reset liblikwid
        topo = LIKWID.get_cpu_topology()
        ncores = topo.numCoresPerSocket * topo.numSockets
        N = Threads.nthreads()

        @testset "likwid-pin" begin
            # N==8: 0xfffffffffffffe01
            maskstr = LIKWID.pinmask(N)
            cores_firstN = string("0-", N - 1)
            cores_firstN_shuffled = join(shuffle(0:(N - 1)), ",")
            cores_rand = join(shuffle(0:(ncores - 1))[1:N], ",")

            @testset "$f" for f in ["test_pin.jl"]
                withenv("OPENBLAS_NUM_THREADS" => 1) do
                    @test_broken exec(`$likwidpin -s $(maskstr) -C $(cores_firstN) -m $julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, f)) $(cores_firstN)`)
                    @test_broken exec(`$likwidpin -s $(maskstr) -C $(cores_firstN_shuffled) -m $julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, f)) $(cores_firstN_shuffled)`)
                    @test_broken exec(`$likwidpin -s $(maskstr) -C $(cores_rand) -m $julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, f)) $(cores_rand)`)
                end
            end
        end

        @testset "dynamic pinning" begin
            @test exec(`$julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, "test_pin_dynamic.jl"))`)
        end
    end

    # ------- GPU -------
    if TEST_GPU
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

        @testset "Marker API (GPU)" begin
            # print perf groups
            # LIKWID._execute_test(`likwid-perfctr -a`; print_only_on_fail=false)
            # read gpu perf group
            NvMon.init([0])
            perfgrp_gpu = first(NvMon.supported_groups())[1]
            NvMon.finalize()
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
            @testset "$f" for f in ["test_marker_gpu.jl", "test_marker_gpu_convenience.jl"]
                @test exec(`$likwidperfctr -G 0 -W $(perfgrp_gpu) -m $julia --project=$(testdir) $(joinpath(testdir, f))`)
            end
        end
    end
end
