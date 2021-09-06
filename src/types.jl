struct HWThread
    threadId::Int32
    coreId::Int32
    packageId::Int32
    apicId::Int32
    # dieId::Int32
    inCpuSet::Int32
end

struct CacheLevel
    level::Int32
    type::Symbol
    associativity::Int32
    sets::Int32
    lineSize::Int32
    size::Int32
    threads::Int32
    inclusive::Int32
end


struct CpuTopology
    numHWThreads::Int32
    activeHWThreads::Int32
    numSockets::Int32
    # numDies::Int32
    numCoresPerSocket::Int32
    numThreadsPerCore::Int32
    numCacheLevels::Int32
    threadPool::Vector{HWThread}
    cacheLevels::Vector{CacheLevel}
    # topologyTree::Vector{LibLikwid.treeNode} # useless?
end

# struct Likwid_Configuration
#     configFileName::String
#     topologyCfgFileName::String
#     daemonPath::String
#     groupPath::String
#     daemonMode::AccessMode
#     maxNumThreads::Cint
#     maxNumNodes::Cint
# end

struct CpuInfo
    family::Int32
    model::Int32
    stepping::Int32
    vendor::Int32
    part::Int32
    clock::Int64
    turbo::Bool
    osname::String
    name::String
    short_name::String
    features::String
    isIntel::Bool
    architecture::String
    supportUncore::Bool
    supportClientmem::Bool
    featureFlags::UInt64
    perf_version::Int32
    perf_num_ctr::Int32
    perf_width_ctr::Int32
    perf_num_fixed_ctr::Int32
end

struct NumaNode
    id::Int32
    totalMemory::Int64
    freeMemory::Int64
    numberOfProcessors::Int32
    processors::Vector{Int32}
    numberOfDistances::UInt32
    distances::Vector{Int32}
end

struct NumaTopology
    numberOfNodes::Int32
    nodes::Vector{NumaNode}
end