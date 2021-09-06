struct HWThread
    threadId::Int
    coreId::Int
    packageId::Int
    apicId::Int
    # dieId::Int
    inCpuSet::Int
end

struct CacheLevel
    level::Int
    type::Symbol
    associativity::Int
    sets::Int
    lineSize::Int
    size::Int
    threads::Int
    inclusive::Int
end


struct CpuTopology
    numHWThreads::Int
    activeHWThreads::Int
    numSockets::Int
    # numDies::Int
    numCoresPerSocket::Int
    numThreadsPerCore::Int
    numCacheLevels::Int
    threadPool::Vector{HWThread}
    cacheLevels::Vector{CacheLevel}
    # topologyTree::Vector{LibLikwid.treeNode}
end

# struct Likwid_Configuration
#     configFileName::Ptr{Cchar}
#     topologyCfgFileName::Ptr{Cchar}
#     daemonPath::Ptr{Cchar}
#     groupPath::Ptr{Cchar}
#     daemonMode::AccessMode
#     maxNumThreads::Cint
#     maxNumNodes::Cint
# end

# struct CpuInfo
#     family::UInt32
#     model::UInt32
#     stepping::UInt32
#     vendor::UInt32
#     part::UInt32
#     clock::UInt64
#     turbo::Cint
#     osname::Ptr{Cchar}
#     name::Ptr{Cchar}
#     short_name::Ptr{Cchar}
#     features::Ptr{Cchar}
#     isIntel::Cint
#     architecture::NTuple{20, Cchar}
#     supportUncore::Cint
#     supportClientmem::Cint
#     featureFlags::UInt64
#     perf_version::UInt32
#     perf_num_ctr::UInt32
#     perf_width_ctr::UInt32
#     perf_num_fixed_ctr::UInt32
# end
