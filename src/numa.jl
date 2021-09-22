"Initialize LIKWIDs NUMA module."
function init_numa()
    ret = LibLikwid.numa_init()
    if ret == 0
        _numainfo[] = unsafe_load(LibLikwid.get_numaTopology())
        _build_jl_numa()
        numa_initialized[] = true
        return true
    end
    return false
end

"Close and finalize LIKWIDs NUMA module."
function finalize_numa()
    LibLikwid.numa_finalize()
    numa_initialized[] = false
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
            n.totalMemory, # kB
            n.freeMemory, # kB
            n.numberOfProcessors,
            unsafe_wrap(Array, n.processors, n.numberOfProcessors),
            n.numberOfDistances,
            unsafe_wrap(Array, n.distances, n.numberOfDistances),
        )
    end

    numainfo[] = NumaTopology(nnodes, nodes)
    return nothing
end

"""
    get_numa_topology() -> NumaTopology
Get the NUMA topology of the machine.

Automatically initializes the topology, NUMA, and affinity modules,
i.e. calls [`init_topology`](@ref), [`init_numa`](@ref), and [`init_affinity`](@ref).
"""
function get_numa_topology()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end
    if !affinity_initialized[]
        init_affinity() || error("Couldn't init affinity.")
    end
    return numainfo[]
end