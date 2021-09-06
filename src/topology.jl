function init_topology()
    ret = LibLikwid.topology_init()
    if ret == 0
        topo_initialized[] = true
        return true
    end
    return false
end

function finalize_topology()
    LibLikwid.topology_finalize()
    topo_initialized[] = false
    cputopo[] = nothing
    cpuinfo[] = nothing
    nothing
end

function get_cpu_topology()
    d = Dict{Symbol, Any}()
    if !topo_initialized[]
        if !init_topology()
            # TODO: Better throw an error here?
            return d
        end
    end
    if topo_initialized[] && isnothing(cputopo[])
        cputopo[] = unsafe_load(LibLikwid.get_cpuTopology())
    end
    if !numa_initialized[]
        if LibLikwid.numa_init() == 0
            numa_initialized[] = true
            numainfo[] = unsafe_load(LibLikwid.get_numaTopology())
        end
    end
    if numa_initialized[] && isnothing(numainfo[])
        numainfo[] = unsafe_load(LibLikwid.get_numaTopology())
    end
    
    threads = Dict{Int, Dict{Symbol, Int}}()
    ncachelvls = Int(cputopo[].numCacheLevels)
    nhwthreads = Int(cputopo[].numHWThreads)
    d[:numHWThreads] = nhwthreads
    d[:activeHWThreads] = Int(cputopo[].activeHWThreads)
    d[:numSockets] = Int(cputopo[].numSockets)
    # d[:numDies] = Int(cputopo[].numDies)
    d[:numCoresPerSocket] = Int(cputopo[].numCoresPerSocket)
    d[:numThreadsPerCore] = Int(cputopo[].numThreadsPerCore)
    d[:numCacheLevels] = ncachelvls
    threadpools = unsafe_wrap(Array, cputopo[].threadPool, nhwthreads)
    for (i, tp) in enumerate(threadpools)
        tmp = Dict{Symbol, Int}()
        tmp[:threadId] = Int(tp.threadId)
        tmp[:coreId] = Int(tp.coreId)
        tmp[:packageId] = Int(tp.packageId)
        tmp[:apicId] = Int(tp.apicId)
        threads[i] = tmp
    end
    d[:threadPool] = threads
    caches = Dict{Int, Dict{Symbol, Union{Int, String}}}()
    cachelvls = unsafe_wrap(Array, cputopo[].cacheLevels, ncachelvls)
    for clvl in cachelvls
        tmp = Dict{Symbol, Union{Int, String}}()
        tmp[:level] = Int(clvl.level)
        tmp[:associativity] = Int(clvl.associativity)
        tmp[:sets] = Int(clvl.sets)
        tmp[:lineSize] = Int(clvl.lineSize)
        tmp[:size] = Int(clvl.size)
        tmp[:threads] = Int(clvl.threads)
        tmp[:inclusive] = Int(clvl.inclusive)
        tmp[:type] = clvl.type == LibLikwid.DATACACHE ? "data" :
                      clvl.type == LibLikwid.INSTRUCTIONCACHE ? "instruction" :
                      clvl.type == LibLikwid.UNIFIEDCACHE ? "unified" :
                      clvl.type == LibLikwid.ITLB ? "itlb" :
                      clvl.type == LibLikwid.DTLB ? "dtlb" : "nocache"
        caches[Int(clvl.level)] = tmp
    end
    d[:cacheLevels] = caches
    return d
end