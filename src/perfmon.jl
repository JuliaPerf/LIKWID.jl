module PerfMon
    import ..LIKWID: LibLikwid

    # based on https://github.com/RRZE-HPC/pylikwid/blob/524221a0255cdf8b70a880c3dc6d0fbef1a98081/pylikwid.c#L1078
    function init(cpus::AbstractVector{<:Integer})
        if !topo_initialized[]
            LibLikwid.topology_init()
            topo_initialized[] = true
            cpuinfo[] = LibLikwid.get_cpuInfo()
            cputopo[] = LibLikwid.get_cpuTopology()
        end
        if topo_initialized[] && (cpuinfo[] == C_NULL)
            cpuinfo[] = LibLikwid.get_cpuInfo()
        end
        if topo_initialized[] && (cputopo[] == C_NULL)
            cputopo[] = LibLikwid.get_cpuTopology()
        end
        if !numa_initialized[]
            LibLikwid.numa_init()
            numa_initialized[] = true
            numainfo[] = LibLikwid.get_numaTopology()
        end
        if numa_initialized[] && (numainfo[] == C_NULL)
            numainfo[] = LibLikwid.get_numaTopology()
        end

        nrThreads = length(cpus)
        if !perfmon_initialized[]
            ret = LibLikwid.perfmon_init(nrThreads, cpus) # &(cpulist[0])
            ret == 0 || error("Initialization of PerfMon module failed.")
            perfmon_initialized[] = true
            timer_initialized[] = true
        end
    end
end