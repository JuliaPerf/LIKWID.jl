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

# TODO
# likwid_cpustr_to_cpulist(PyObject *self, PyObject *args)
# {
#     int ret = 0, j = 0;
#     const char *cpustr;
#     if (!PyArg_ParseTuple(args, "s", &cpustr))
#     {
#         Py_RETURN_NONE;
#     }
#     if (configfile == NULL)
#     {
#         init_configuration();
#         configfile = get_configuration();
#     }
#     int* cpulist = (int*) malloc(configfile->maxNumThreads * sizeof(int));
#     if (!cpulist)
#     {
#         Py_RETURN_NONE;
#     }
#     ret = cpustr_to_cpulist((char *)cpustr, cpulist, configfile->maxNumThreads);
#     if (ret < 0)
#     {
#         free(cpulist);
#         Py_RETURN_NONE;
#     }
#     PyObject *l = PyList_New(ret);
#     for(j=0;j<ret;j++)
#     {
#         PyList_SET_ITEM(l, (Py_ssize_t)j, PYINT(cpulist[j]));
#     }
#     free(cpulist);
#     return l;
# }