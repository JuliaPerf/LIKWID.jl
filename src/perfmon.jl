module PerfMon
    import ..LIKWID: LibLikwid

    # based on https://github.com/RRZE-HPC/pylikwid/blob/524221a0255cdf8b70a880c3dc6d0fbef1a98081/pylikwid.c#L1078
    function init(cpus::AbstractVector{<:Integer})
        if topo_initialized == 0
            LibLikwid.topology_init()
            topo_initialized = 1
            cpuinfo = LibLikwid.get_cpuInfo()
            cputopo = LibLikwid.get_cpuTopology()
        end
        if (topo_initialized) && (cpuinfo == C_NULL)
            cpuinfo = LibLikwid.get_cpuInfo()
        end
        if (topo_initialized) && (cputopo == C_NULL)
            cputopo = LibLikwid.get_cpuTopology()
        end
        if numa_initialized == 0
            LibLikwid.numa_init()
            numa_initialized = 1
            numainfo = LibLikwid.get_numaTopology()
        end
        if (numa_initialized) && (numainfo == C_NULL)
            numainfo = LibLikwid.get_numaTopology()
        end

        nrThreads = length(cpus)
        if perfmon_initialized == 0
            ret = LibLikwid.perfmon_init(nrThreads, cpus) # &(cpulist[0])
            ret != 0 && error("Initialization of PerfMon module failed.")
            perfmon_initialized = 1
            timer_initialized = 1
        end
    end
end