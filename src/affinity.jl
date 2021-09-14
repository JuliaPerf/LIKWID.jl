function init_affinity()
    LibLikwid.affinity_init()
    _affinity[] = unsafe_load(LibLikwid.get_affinityDomains())
    _build_jl_affinity()
    affinity_initialized[] = true
    return true
end

function finalize_affinity()
    LibLikwid.affinity_finalize()
    affinity_initialized[] = false
    _affinity[] = nothing
    return nothing
end

function _build_jl_affinity()
    af = _affinity[]

    ndomains = af.numberOfAffinityDomains
    _domains = unsafe_wrap(Array, af.domains, ndomains)
    domains = Vector{AffinityDomain}(undef, ndomains)
    for (i, d) in enumerate(_domains)
        # bstring: http://mike.steinert.ca/bstring/doc/
        bstr = unsafe_load(d.tag)
        domains[i] = AffinityDomain(
            unsafe_string(bstr.data),
            d.numberOfProcessors,
            d.numberOfCores,
            unsafe_wrap(Array, d.processorList, d.numberOfProcessors),
        )
    end

    affinity[] = AffinityDomains(
        af.numberOfSocketDomains,
        af.numberOfNumaDomains,
        af.numberOfProcessorsPerSocket,
        af.numberOfCacheDomains,
        af.numberOfCoresPerCache,
        af.numberOfProcessorsPerCache,
        ndomains,
        domains
    )
    return nothing
end

function get_affinity()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !numa_initialized[]
        init_numa() || error("Couldn't init numa.")
    end
    if !affinity_initialized[]
        init_affinity() || error("Couldn't init affinity.")
    end
    return affinity[]
end

function cpustr_to_cpulist(cpustr::AbstractString)
    if !config_initialized[]
        init_configuration() || error("Couldn't init configuration.")
    end
    config = get_configuration()
    cpulist = zeros(Int32, config.maxNumThreads)
    LibLikwid.cpustr_to_cpulist(cpustr, cpulist, length(cpulist))
    return cpulist
end