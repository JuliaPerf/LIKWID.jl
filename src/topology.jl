function init_topology()
    ret = LibLikwid.topology_init()
    if ret == 0
        _cputopo[] = unsafe_load(LibLikwid.get_cpuTopology())
        _build_jl_cputopo()
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
            Int(tp.threadId),
            Int(tp.coreId),
            Int(tp.packageId),
            Int(tp.apicId),
            Int(tp.inCpuSet),
        )
    end
    cachelvls = unsafe_wrap(Array, ct.cacheLevels, ncachelvls)
    caches = Vector{CacheLevel}(undef, ncachelvls)
    for (i, clvl) in enumerate(cachelvls)
        caches[i] = CacheLevel(
            Int(clvl.level),
            clvl.type == LibLikwid.DATACACHE ? :data :
                          clvl.type == LibLikwid.INSTRUCTIONCACHE ? :instruction :
                          clvl.type == LibLikwid.UNIFIEDCACHE ? :unified :
                          clvl.type == LibLikwid.ITLB ? :itlb :
                          clvl.type == LibLikwid.DTLB ? :dtlb : :nocache,
            Int(clvl.associativity),
            Int(clvl.sets),
            Int(clvl.lineSize),
            Int(clvl.size),
            Int(clvl.threads),
            Int(clvl.inclusive),
        )
    end

    cputopo[] = CpuTopology(
        nhwthreads,
        Int(ct.activeHWThreads),
        Int(ct.numSockets),
        # Int(ct.numDies),
        Int(ct.numCoresPerSocket),
        Int(ct.numThreadsPerCore),
        ncachelvls,
        threads,
        caches,
    )
    return nothing
end

function finalize_topology()
    LibLikwid.topology_finalize()
    _topo_initialized[] = false
    cputopo[] = nothing
    cpuinfo[] = nothing
    return nothing
end

function get_cpu_topology()
    if !_topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !_numa_initialized[]
        init_numa() || error("Couldn't init numa.")
        _numainfo[] = unsafe_load(LibLikwid.get_numaTopology())
    end
    return cputopo[]
end