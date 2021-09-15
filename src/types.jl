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

Base.show(io::IO, nn::NumaNode) = print(io, "NumaNode()")

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

struct TurboBoost
    numSteps::Int
    steps::Vector{Float64}
end

Base.show(io::IO, t::TurboBoost) = print(io, "TurboBoost()")

# @cenum PowerType::UInt32 begin
#     PKG = 0
#     PP0 = 1
#     PP1 = 2
#     DRAM = 3
#     PLATFORM = 4
# end

struct PowerDomain
    id::Int
    type::LibLikwid.PowerType
    supportFlags::UInt32
    energyUnit::Float64
    tdp::Float64
    minPower::Float64
    maxPower::Float64
    maxTimeWindow::Float64
    supportInfo::Bool
    supportStatus::Bool
    supportPerf::Bool
    supportPolicy::Bool
    supportLimit::Bool
end

Base.show(io::IO, pd::PowerDomain) = print(io, "PowerDomain($(pd.type), ...)")

struct PowerInfo
    baseFrequency::Float64
    minFrequency::Float64
    turbo::TurboBoost
    hasRAPL::Bool
    powerUnit::Float64
    timeUnit::Float64
    uncoreMinFreq::Float64
    uncoreMaxFreq::Float64
    perfBias::Int
    domains::NTuple{5,PowerDomain}
end

# struct PowerData
#     domain::Int
#     before::UInt32
#     after::UInt32
# end

struct Likwid_Configuration
    configFileName::String
    topologyCfgFileName::String
    daemonPath::String
    groupPath::String
    daemonMode::LibLikwid.AccessMode
    maxNumThreads::Int
    maxNumNodes::Int
end

struct GroupInfoCompact
    name::String
    shortinfo::String
    longinfo::String
end

Base.show(io::IO, gi::GroupInfoCompact) = print(io, "GroupInfoCompact($(gi.name), ...)")

struct GpuDevice
    devid::Int
    numaNode::Int
    name::String
    short_name::String
    mem::Int
    compute_capability_major::Int
    compute_capability_minor::Int
    maxThreadsPerBlock::Int
    maxThreadsDim::NTuple{3, Int}
    maxGridSize::NTuple{3, Int}
    sharedMemPerBlock::Int
    totalConstantMemory::Int
    simdWidth::Int
    memPitch::Int
    regsPerBlock::Int
    clockRatekHz::Int
    textureAlign::Int
    surfaceAlign::Int
    l2Size::Int
    memClockRatekHz::Int
    pciBus::Int
    pciDev::Int
    pciDom::Int
    maxBlockRegs::Int
    numMultiProcs::Int
    maxThreadPerMultiProc::Int
    memBusWidth::Int
    unifiedAddrSpace::Bool
    ecc::Bool
    asyncEngines::Int
    mapHostMem::Bool
    integrated::Bool
end

Base.show(io::IO, d::GpuDevice) = print(io, "GpuDevice($(d.name), ...)")

struct GpuTopology
    numDevices::Int
    devices::Vector{GpuDevice}
end

# SHOW
const SHOW_TYPES = Union{
    CpuTopology,
    CpuInfo,
    NumaTopology,
    NumaNode,
    AffinityDomain,
    AffinityDomains,
    PowerInfo,
    PowerDomain,
    TurboBoost,
    Likwid_Configuration,
    GroupInfoCompact,
    GpuTopology,
    GpuDevice
}

function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, x::SHOW_TYPES)
    summary(io, x)
    println(io)
    T = typeof(x)
    nfields = length(fieldnames(T))
    for (i, field) in enumerate(fieldnames(T))
        char = i == nfields ? "└" : "├"
        xfield = getproperty(x, field)
        if (xfield isa AbstractVector || xfield isa NTuple) &&
           !(T in (NumaNode, AffinityDomain, TurboBoost, GpuDevice))
            print(io, char, " ", field, ": ... (", length(xfield), " elements)")
        elseif field == :totalMemory || field == :freeMemory
            print(io, char, " ", field, ": ", round(xfield / 1024 / 1024; digits=2), " GB")
        elseif T == GpuDevice && field == :mem
            print(io, char, " ", field, ": ", round(xfield / 1024 / 1024 / 1024; digits=2), " GB")
        elseif field in (:baseFrequency, :minFrequency, :uncoreMinFreq, :uncoreMaxFreq)
            print(io, char, " ", field, ": ", xfield, " MHz")
        else
            print(io, char, " ", field, ": ", xfield)
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

function Base.show(io::IO, x::LibLikwid.TimerData)
    return print(
        io, "TimerData(cycles start: $(x.start.int64), cycles stop: $(x.stop.int64))"
    )
end
Base.show(io::IO, x::LibLikwid.TscCounter) = print(io, x.int64, " (TscCounter)")
