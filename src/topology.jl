function init_topology()
    ret = LibLikwid.topology_init()
    if ret == 0
        _cputopo[] = unsafe_load(LibLikwid.get_cpuTopology())
        _cpuinfo[] = unsafe_load(LibLikwid.get_cpuInfo())
        _build_jl_cputopo()
        _build_jl_cpuinfo()
        _topo_initialized[] = true
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
        # ct.numDies,
        ct.numCoresPerSocket,
        ct.numThreadsPerCore,
        ncachelvls,
        threads,
        caches,
    )
    return nothing
end

function finalize_topology()
    LibLikwid.topology_finalize()
    _topo_initialized[] = false
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

function get_cpu_topology()
    if !_topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !_numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end
    return cputopo[]
end

print_supported_cpus() = LibLikwid.print_supportedCPUs()