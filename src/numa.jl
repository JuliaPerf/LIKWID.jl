function init_numa()
    ret = LibLikwid.numa_init()
    if ret == 0
        _numainfo[] = unsafe_load(LibLikwid.get_numaTopology())
        _build_jl_numa()
        _numa_initialized[] = true
        return true
    end
    return false
end

function finalize_numa()
    LibLikwid.numa_finalize()
    _numa_initialized[] = false
    _numainfo[] = nothing
    return nothing
end

function _build_jl_numa()
    ni = _numainfo[]

    nnodes = ni.numberOfNodes
    _nodes = unsafe_wrap(Array, ni.nodes, nnodes)
    nodes = Vector{NumaNode}(undef, nnodes)
    for (i, n) in enumerate(_nodes)
        nodes[i] = NumaNode(
            n.id,
            n.totalMemory,
            n.freeMemory,
            n.numberOfProcessors,
            unsafe_wrap(Array, n.processors, n.numberOfProcessors),
            n.numberOfDistances,
            unsafe_wrap(Array, n.distances, n.numberOfDistances),
        )
    end

    numainfo[] = NumaTopology(
        nnodes,
        nodes
    )
    return nothing
end

function get_numa_topology()
    if !_topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !_numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end
    # TODO: if (affinity_initialized == 0)
    # {
    #     affinity_init();
    #     affinity_initialized = 1;
    #     affinity = get_affinityDomains();
    # }
    # if ((affinity_initialized) && (affinity == NULL))
    # {
    #     affinity = get_affinityDomains();
    # }
    return numainfo[]
end