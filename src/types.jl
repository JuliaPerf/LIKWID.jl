struct HWThread
    threadId::Int
    coreId::Int
    packageId::Int
    apicId::Int
    dieId::Int
    inCpuSet::Int
end

# function Base.show(io::IO, hwt::HWThread)
#     print("HWThread()")
# end

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

# function Base.show(io::IO, clvl::CacheLevel)
#     print(io, "CacheLevel($(clvl.level), ...)")
# end

struct CpuTopology
    numHWThreads::Int
    activeHWThreads::Int
    numSockets::Int
    numDies::Int
    numCoresPerSocket::Int
    numThreadsPerCore::Int
    numCacheLevels::Int
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
    family::Int
    model::Int
    stepping::Int
    vendor::Int
    part::Int
    clock::Int
    turbo::Bool
    osname::String
    name::String
    short_name::String
    features::String
    isIntel::Bool
    architecture::String
    supportUncore::Bool
    supportClientmem::Bool
    featureFlags::UInt
    perf_version::Int
    perf_num_ctr::Int
    perf_width_ctr::Int
    perf_num_fixed_ctr::Int
end

struct NumaNode
    id::Int
    totalMemory::Int # kB
    freeMemory::Int # kB
    numberOfProcessors::Int
    processors::Vector{Int}
    numberOfDistances::Int
    distances::Vector{Int}
end

function Base.show(io::IO, nn::NumaNode)
    print(io, "NumaNode()")
end

struct NumaTopology
    numberOfNodes::Int
    nodes::Vector{NumaNode}
end

struct AffinityDomain
    tag::String
    numberOfProcessors::Int
    numberOfCores::Int
    processorList::Vector{Int}
end

struct AffinityDomains
    numberOfSocketDomains::Int
    numberOfNumaDomains::Int
    numberOfProcessorsPerSocket::Int
    numberOfCacheDomains::Int
    numberOfCoresPerCache::Int
    numberOfProcessorsPerCache::Int
    numberOfAffinityDomains::Int
    domains::Vector{AffinityDomain}
end

const SHOW_TYPES = Union{CpuTopology, CpuInfo, NumaTopology, NumaNode, AffinityDomain, AffinityDomains}

function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, x::SHOW_TYPES)
    summary(io, x); println(io)
    T = typeof(x)
    nfields = length(fieldnames(T))
    for (i,field) in enumerate(fieldnames(T))
        char = i == nfields ? "└" : "├"
        if getproperty(x, field) isa AbstractVector && !(T in (NumaNode, AffinityDomain))
            print(io, char, " ", field, ": ... (", length(getproperty(x, field)), " elements)")
        elseif field == :totalMemory || field == :freeMemory
            print(io, char, " ", field, ": ", round(getproperty(x, field) / 1024 / 1024, digits=2), " GB")
        else
            print(io, char, " ", field, ": ", getproperty(x, field))
        end
        i !== nfields && println(io)
    end
end

# function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, x::LibLikwid.TimerData)
#     summary(io, x); println(io)
#     T = typeof(x)
#     nfields = length(fieldnames(T))
#     for (i,field) in enumerate(fieldnames(T))
#         char = i == nfields ? "└" : "├"
#         if getproperty(x, field) isa AbstractVector && !(T in (NumaNode, AffinityDomain))
#             print(io, char, " ", field, ": ... (", length(getproperty(x, field)), " elements)")
#         else
#             print(io, char, " ", field, ": ", getproperty(x, field))
#         end
#         i !== nfields && println(io)
#     end
# end

Base.show(io::IO, x::LibLikwid.TimerData) = print(io, "TimerData(cycles start: $(x.start.int64), cycles stop: $(x.stop.int64))")
Base.show(io::IO, x::LibLikwid.TscCounter) = print(io, x.int64, " (TscCounter)")