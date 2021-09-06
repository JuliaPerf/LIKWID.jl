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
    cputopo[] = C_NULL
    cpuinfo[] = C_NULL
    nothing
end

# function get_cpu_topology()
#     d = Dict()
#     if !topo_initialized[]
#         ret = init_topology()
#         if ret != 0
#             # TODO: Better throw an error here?
#             return d
#         end
#     end
#     threads = Dict()
#     caches = Dict()
#     if topo_initialized[] && (cputopo[] == C_NULL)
#         cputopo[] = LibLikwid.get_cpuTopology()
#     end
#     if !numa_initialized[]
#         if LibLikwid.numa_init() == 0
#             numa_initialized[] = true
#             numainfo[] = LibLikwid.get_numaTopology()
#         end
#     end
#     if numa_initialized[] && (numainfo[] == C_NULL)
#         numainfo[] = LibLikwid.get_numaTopology()
#     end
#     PyDict_SetItem(d, PYSTR("numHWThreads"), PYINT(cputopo->numHWThreads))
#     PyDict_SetItem(d, PYSTR("activeHWThreads"), PYINT(cputopo->activeHWThreads))
#     PyDict_SetItem(d, PYSTR("numSockets"), PYINT(cputopo->numSockets))
#     PyDict_SetItem(d, PYSTR("numCoresPerSocket"), PYINT(cputopo->numCoresPerSocket))
#     PyDict_SetItem(d, PYSTR("numThreadsPerCore"), PYINT(cputopo->numThreadsPerCore))
#     PyDict_SetItem(d, PYSTR("numCacheLevels"), PYINT(cputopo->numCacheLevels))
#     for (i = 0 i < (int)cputopo->numHWThreads i++)
#         tmp = PyDict_New()
#         PyDict_SetItem(tmp, PYSTR("threadId"), PYUINT(cputopo->threadPool[i].threadId))
#         PyDict_SetItem(tmp, PYSTR("coreId"), PYUINT(cputopo->threadPool[i].coreId))
#         PyDict_SetItem(tmp, PYSTR("packageId"), PYUINT(cputopo->threadPool[i].packageId))
#         PyDict_SetItem(tmp, PYSTR("apicId"), PYUINT(cputopo->threadPool[i].apicId))
#         PyDict_SetItem(threads, PYINT(i), tmp)
#     end
#     PyDict_SetItem(d, PYSTR("threadPool"), threads)
#     for (i = 0 i < (int)cputopo->numCacheLevels i++)
#         tmp = PyDict_New()
#         PyDict_SetItem(tmp, PYSTR("level"), PYUINT(cputopo->cacheLevels[i].level))
#         PyDict_SetItem(tmp, PYSTR("associativity"), PYUINT(cputopo->cacheLevels[i].associativity))
#         PyDict_SetItem(tmp, PYSTR("sets"), PYUINT(cputopo->cacheLevels[i].sets))
#         PyDict_SetItem(tmp, PYSTR("lineSize"), PYUINT(cputopo->cacheLevels[i].lineSize))
#         PyDict_SetItem(tmp, PYSTR("size"), PYUINT(cputopo->cacheLevels[i].size))
#         PyDict_SetItem(tmp, PYSTR("threads"), PYUINT(cputopo->cacheLevels[i].threads))
#         PyDict_SetItem(tmp, PYSTR("inclusive"), PYUINT(cputopo->cacheLevels[i].inclusive))
#         switch(cputopo->cacheLevels[i].type)
#             case DATACACHE:
#                 PyDict_SetItem(tmp, PYSTR("type"), PYSTR("data"))
#                 break
#             case INSTRUCTIONCACHE:
#                 PyDict_SetItem(tmp, PYSTR("type"), PYSTR("instruction"))
#                 break
#             case UNIFIEDCACHE:
#                 PyDict_SetItem(tmp, PYSTR("type"), PYSTR("unified"))
#                 break
#             case ITLB:
#                 PyDict_SetItem(tmp, PYSTR("type"), PYSTR("itlb"))
#                 break
#             case DTLB:
#                 PyDict_SetItem(tmp, PYSTR("type"), PYSTR("dtlb"))
#                 break
#             case NOCACHE:
#                 break
#         end
#         PyDict_SetItem(caches, PYUINT(cputopo->cacheLevels[i].level), tmp)
#     end
#     PyDict_SetItem(d, PYSTR("cacheLevels"), caches)
#     return d
# end