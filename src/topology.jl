"Initialize LIKWIDs topology module."
function init_topology()
    ret = LibLikwid.topology_init()
    if ret == 0
        _cputopo[] = unsafe_load(LibLikwid.get_cpuTopology())
        _cpuinfo[] = unsafe_load(LibLikwid.get_cpuInfo())
        _build_jl_cputopo()
        _build_jl_cpuinfo()
        topo_initialized[] = true
        return true
    end
    return false
end

function _build_jl_cputopo()
    ct = _cputopo[]
    ncachelvls = Int(ct.numCacheLevels)
    nhwthreads = Int(ct.numHWThreads)
    threadpools = unsafe_wrap(Array, ct.threadPool, nhwthreads)
    threads = Vector{HWThread}(undef, nhwthreads)
    for (i, tp) in enumerate(threadpools)
        threads[i] = HWThread(
            tp.threadId,
            tp.coreId,
            tp.packageId,
            tp.apicId,
            tp.dieId,
            tp.inCpuSet,
        )
    end
    cachelvls = unsafe_wrap(Array, ct.cacheLevels, ncachelvls)
    caches = Vector{CacheLevel}(undef, ncachelvls)
    for (i, clvl) in enumerate(cachelvls)
        caches[i] = CacheLevel(
            clvl.level,
            clvl.type == LibLikwid.DATACACHE ? :data :
                          clvl.type == LibLikwid.INSTRUCTIONCACHE ? :instruction :
                          clvl.type == LibLikwid.UNIFIEDCACHE ? :unified :
                          clvl.type == LibLikwid.ITLB ? :itlb :
                          clvl.type == LibLikwid.DTLB ? :dtlb : :nocache,
            clvl.associativity,
            clvl.sets,
            clvl.lineSize,
            clvl.size,
            clvl.threads,
            clvl.inclusive,
        )
    end

    cputopo[] = CpuTopology(
        nhwthreads,
        ct.activeHWThreads,
        ct.numSockets,
        ct.numDies,
        ct.numCoresPerSocket,
        ct.numThreadsPerCore,
        ncachelvls,
        threads,
        caches,
    )
    return nothing
end

"Close and finalize LIKWIDs topology module."
function finalize_topology()
    LibLikwid.topology_finalize()
    topo_initialized[] = false
    _cputopo[] = nothing
    _cpuinfo[] = nothing
    cputopo[] = nothing
    cpuinfo[] = nothing
    return nothing
end

function _build_jl_cpuinfo()
    ci = _cpuinfo[]
    cpuinfo[] = CpuInfo(
        ci.family,
        ci.model,
        ci.stepping,
        ci.vendor,
        ci.part,
        ci.clock,
        ci.turbo,
        unsafe_string(ci.osname),
        unsafe_string(ci.name),
        unsafe_string(ci.short_name),
        unsafe_string(ci.features),
        ci.isIntel,
        join(Char(c) for c in ci.architecture if !iszero(c)),
        ci.supportUncore,
        ci.supportClientmem,
        ci.featureFlags,
        ci.perf_version,
        ci.perf_num_ctr,
        ci.perf_width_ctr,
        ci.perf_num_fixed_ctr,
    )
    return nothing
end

"""
    get_cpu_topology() -> CpuTopology
Get the CPU topology of the machine.

Automatically initializes the topology and NUMA modules,
i.e. calls [`LIKWID.init_topology`](@ref) and [`LIKWID.init_numa`](@ref).
"""
function get_cpu_topology()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end
    return cputopo[]
end

"""
    get_cpu_info() -> CpuInfo
Get detailed information about the CPU.

Automatically initializes the topology and NUMA modules,
i.e. calls [`LIKWID.init_topology`](@ref) and [`LIKWID.init_numa`](@ref).
"""
function get_cpu_info()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end
    return cpuinfo[]
end

"""
    print_supported_cpus(; cprint=true)
Print a list of all supported CPUs.

If `cprint=false`, LIKWID.jl
will first capture the stdout and then `print` the list.
"""
function print_supported_cpus(; cprint=true)
    if cprint
        LibLikwid.print_supportedCPUs()
    else
        buf = IOBuffer()
        capture_stdout!(LibLikwid.print_supportedCPUs, buf)
        s = String(take!(buf))
        print(s)
    end
    return nothing
end

"""
Graphical visualization of the CPU topology. Extracts the corresponding output of `likwid-topology -g`.
"""
function print_cpu_topology()
    out = _execute(`likwid-topology -g`)
    if out[:stderr] != ""
        @warn out[:stderr]
    end
    stdout = out[:stdout]
    idcs = findfirst("Graphical Topology", stdout)
    print(stdout[first(idcs):end])
    return nothing
end

function num_physical_cores()
    topo = get_cpu_topology()
    topo.numCoresPerSocket * topo.numSockets
end

function num_virtual_cores()
    topo = get_cpu_topology()
    topo.numCoresPerSocket * topo.numSockets * topo.numThreadsPerCore
end