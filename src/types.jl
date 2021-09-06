struct HWThread
    threadId::Int
    coreId::Int
    packageId::Int
    apicId::Int
    # dieId::Int
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
    # numDies::Int
    numCoresPerSocket::Int
    numThreadsPerCore::Int
    numCacheLevels::Int
    threadPool::Vector{HWThread}
    cacheLevels::Vector{CacheLevel}
    # topologyTree::Vector{LibLikwid.treeNode} # useless?
end

function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, ct::CpuTopology)
    summary(io, ct); println(io)
    T = typeof(ct)
    nfields = length(fieldnames(T))
    for (i,field) in enumerate(fieldnames(T))
        char = i == nfields ? "└" : "├"
        if field == :threadPool || field == :cacheLevels
            print(io, char, " ", field, ": ... (", length(getproperty(ct, field)), " elements)")
        else
            print(io, char, " ", field, ": ", getproperty(ct, field))
        end
        i !== nfields && println(io)
    end
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

function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, ci::CpuInfo)
    summary(io, ci); println(io)
    T = typeof(ci)
    nfields = length(fieldnames(T))
    for (i,field) in enumerate(fieldnames(T))
        char = i == nfields ? "└" : "├"
        print(io, char, " ", field, ": ", getproperty(ci, field))
        i !== nfields && println(io)
    end
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
function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, nn::NumaNode)
    summary(io, nn); println(io)
    T = typeof(nn)
    nfields = length(fieldnames(T))
    for (i,field) in enumerate(fieldnames(T))
        char = i == nfields ? "└" : "├"
        if field == :totalMemory || field == :freeMemory
            # print(io, char, " ", field, ": ", round(getproperty(nn, field) / 1024, digits=2), " MB")
            print(io, char, " ", field, ": ", round(getproperty(nn, field) / 1024 / 1024, digits=2), " GB")
        else
            print(io, char, " ", field, ": ", getproperty(nn, field))
        end
        i !== nfields && println(io)
    end
end

struct NumaTopology
    numberOfNodes::Int
    nodes::Vector{NumaNode}
end

function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, nt::NumaTopology)
    summary(io, nt); println(io)
    T = typeof(nt)
    nfields = length(fieldnames(T))
    for (i,field) in enumerate(fieldnames(T))
        char = i == nfields ? "└" : "├"
        if field == :nodes
            print(io, char, " ", field, ": ... (", length(getproperty(nt, field)), " elements)")
        else
            print(io, char, " ", field, ": ", getproperty(nt, field))
        end
        i !== nfields && println(io)
    end
end
