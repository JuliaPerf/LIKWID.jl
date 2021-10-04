"Initialize LIKWIDs affinity domain module."
function init_affinity()
    LibLikwid.affinity_init()
    _affinity[] = unsafe_load(LibLikwid.get_affinityDomains())
    _build_jl_affinity()
    affinity_initialized[] = true
    return true
end

"Close and finalize LIKWIDs affinity domain module."
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

"Query affinity domain information"
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

"Transform a valid cpu string in LIKWID syntax into a list of CPU IDs"
function cpustr_to_cpulist(cpustr::AbstractString)
    if !config_initialized[]
        init_configuration() || error("Couldn't init configuration.")
    end
    config = get_configuration()
    cpulist = zeros(Int32, config.maxNumThreads)
    LibLikwid.cpustr_to_cpulist(cpustr, cpulist, length(cpulist))
    return cpulist
end

"""
Returns the ID of the currently executing CPU.
"""
get_processor_id() = Int(LibLikwid.likwid_getProcessorId())

"""
Returns the ID of the currently executing CPU via `glibc`s `sched_getcpu` function.
"""
get_processor_id_glibc() = Int(@ccall sched_getcpu()::Cint)

"""
Pins the current process to the CPU given as `cpuid`.
"""
function pinprocess(cpuid::Integer)
    ret = LibLikwid.likwid_pinProcess(cpuid)
    return ret == 0
end

"""
Pins the current thread to the CPU given as `cpuid`.
"""
function pinthread(cpuid::Integer)
    ret = LibLikwid.likwid_pinThread(cpuid)
    return ret == 0
end

"""
Get the CPU core IDs of the Julia threads.
"""
function get_processor_ids()
    N = Threads.nthreads()
    coreids = zeros(Int, N)
    Threads.@threads for i in 1:N
        coreids[i] = LIKWID.get_processor_id()
    end
    return coreids
end

"""
Pin all Julia threads to the CPU cores `coreids`.
Note that `length(coreids) == Threads.nthreads()` must hold!
"""
function pinthreads(coreids::AbstractVector{<:Integer})
    N = Threads.nthreads()
    @assert length(coreids) == N
    @assert minimum(coreids) ≥ 0
    Threads.@threads for i in 1:N
        LIKWID.pinthread(coreids[i])
    end
    return nothing
end