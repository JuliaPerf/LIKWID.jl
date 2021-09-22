# mostly auto-generated with Clang.jl from likwid.h
module LibLikwid
using ..LIKWID: liblikwid

using CEnum

struct tagbstring
    mlen::Cint
    slen::Cint
    data::Ptr{Cuchar}
end

const bstring = Ptr{tagbstring}

const const_bstring = Ptr{tagbstring}

function bfromcstr(str)
    return ccall((:bfromcstr, liblikwid), bstring, (Ptr{Cchar},), str)
end

function bfromcstralloc(mlen, str)
    return ccall((:bfromcstralloc, liblikwid), bstring, (Cint, Ptr{Cchar}), mlen, str)
end

function blk2bstr(blk, len)
    return ccall((:blk2bstr, liblikwid), bstring, (Ptr{Cvoid}, Cint), blk, len)
end

function bstr2cstr(s, z)
    return ccall((:bstr2cstr, liblikwid), Ptr{Cchar}, (const_bstring, Cchar), s, z)
end

function bcstrfree(s)
    return ccall((:bcstrfree, liblikwid), Cint, (Ptr{Cchar},), s)
end

function bstrcpy(b1)
    return ccall((:bstrcpy, liblikwid), bstring, (const_bstring,), b1)
end

function bassign(a, b)
    return ccall((:bassign, liblikwid), Cint, (bstring, const_bstring), a, b)
end

function bassignmidstr(a, b, left, len)
    return ccall(
        (:bassignmidstr, liblikwid),
        Cint,
        (bstring, const_bstring, Cint, Cint),
        a,
        b,
        left,
        len,
    )
end

function bassigncstr(a, str)
    return ccall((:bassigncstr, liblikwid), Cint, (bstring, Ptr{Cchar}), a, str)
end

function bassignblk(a, s, len)
    return ccall((:bassignblk, liblikwid), Cint, (bstring, Ptr{Cvoid}, Cint), a, s, len)
end

function bdestroy(b)
    return ccall((:bdestroy, liblikwid), Cint, (bstring,), b)
end

function balloc(s, len)
    return ccall((:balloc, liblikwid), Cint, (bstring, Cint), s, len)
end

function ballocmin(b, len)
    return ccall((:ballocmin, liblikwid), Cint, (bstring, Cint), b, len)
end

function bmidstr(b, left, len)
    return ccall((:bmidstr, liblikwid), bstring, (const_bstring, Cint, Cint), b, left, len)
end

function bconcat(b0, b1)
    return ccall((:bconcat, liblikwid), Cint, (bstring, const_bstring), b0, b1)
end

function bconchar(b0, c)
    return ccall((:bconchar, liblikwid), Cint, (bstring, Cchar), b0, c)
end

function bcatcstr(b, s)
    return ccall((:bcatcstr, liblikwid), Cint, (bstring, Ptr{Cchar}), b, s)
end

function bcatblk(b, s, len)
    return ccall((:bcatblk, liblikwid), Cint, (bstring, Ptr{Cvoid}, Cint), b, s, len)
end

function binsert(s1, pos, s2, fill)
    return ccall(
        (:binsert, liblikwid),
        Cint,
        (bstring, Cint, const_bstring, Cuchar),
        s1,
        pos,
        s2,
        fill,
    )
end

function binsertch(s1, pos, len, fill)
    return ccall(
        (:binsertch, liblikwid), Cint, (bstring, Cint, Cint, Cuchar), s1, pos, len, fill
    )
end

function breplace(b1, pos, len, b2, fill)
    return ccall(
        (:breplace, liblikwid),
        Cint,
        (bstring, Cint, Cint, const_bstring, Cuchar),
        b1,
        pos,
        len,
        b2,
        fill,
    )
end

function bdelete(s1, pos, len)
    return ccall((:bdelete, liblikwid), Cint, (bstring, Cint, Cint), s1, pos, len)
end

function bsetstr(b0, pos, b1, fill)
    return ccall(
        (:bsetstr, liblikwid),
        Cint,
        (bstring, Cint, const_bstring, Cuchar),
        b0,
        pos,
        b1,
        fill,
    )
end

function btrunc(b, n)
    return ccall((:btrunc, liblikwid), Cint, (bstring, Cint), b, n)
end

function bstricmp(b0, b1)
    return ccall((:bstricmp, liblikwid), Cint, (const_bstring, const_bstring), b0, b1)
end

function bstrnicmp(b0, b1, n)
    return ccall(
        (:bstrnicmp, liblikwid), Cint, (const_bstring, const_bstring, Cint), b0, b1, n
    )
end

function biseqcaseless(b0, b1)
    return ccall((:biseqcaseless, liblikwid), Cint, (const_bstring, const_bstring), b0, b1)
end

function bisstemeqcaselessblk(b0, blk, len)
    return ccall(
        (:bisstemeqcaselessblk, liblikwid),
        Cint,
        (const_bstring, Ptr{Cvoid}, Cint),
        b0,
        blk,
        len,
    )
end

function biseq(b0, b1)
    return ccall((:biseq, liblikwid), Cint, (const_bstring, const_bstring), b0, b1)
end

function bisstemeqblk(b0, blk, len)
    return ccall(
        (:bisstemeqblk, liblikwid), Cint, (const_bstring, Ptr{Cvoid}, Cint), b0, blk, len
    )
end

function biseqcstr(b, s)
    return ccall((:biseqcstr, liblikwid), Cint, (const_bstring, Ptr{Cchar}), b, s)
end

function biseqcstrcaseless(b, s)
    return ccall((:biseqcstrcaseless, liblikwid), Cint, (const_bstring, Ptr{Cchar}), b, s)
end

function bstrcmp(b0, b1)
    return ccall((:bstrcmp, liblikwid), Cint, (const_bstring, const_bstring), b0, b1)
end

function bstrncmp(b0, b1, n)
    return ccall(
        (:bstrncmp, liblikwid), Cint, (const_bstring, const_bstring, Cint), b0, b1, n
    )
end

function binstr(s1, pos, s2)
    return ccall(
        (:binstr, liblikwid), Cint, (const_bstring, Cint, const_bstring), s1, pos, s2
    )
end

function binstrr(s1, pos, s2)
    return ccall(
        (:binstrr, liblikwid), Cint, (const_bstring, Cint, const_bstring), s1, pos, s2
    )
end

function binstrcaseless(s1, pos, s2)
    return ccall(
        (:binstrcaseless, liblikwid),
        Cint,
        (const_bstring, Cint, const_bstring),
        s1,
        pos,
        s2,
    )
end

function binstrrcaseless(s1, pos, s2)
    return ccall(
        (:binstrrcaseless, liblikwid),
        Cint,
        (const_bstring, Cint, const_bstring),
        s1,
        pos,
        s2,
    )
end

function bstrchrp(b, c, pos)
    return ccall((:bstrchrp, liblikwid), Cint, (const_bstring, Cint, Cint), b, c, pos)
end

function bstrrchrp(b, c, pos)
    return ccall((:bstrrchrp, liblikwid), Cint, (const_bstring, Cint, Cint), b, c, pos)
end

function binchr(b0, pos, b1)
    return ccall(
        (:binchr, liblikwid), Cint, (const_bstring, Cint, const_bstring), b0, pos, b1
    )
end

function binchrr(b0, pos, b1)
    return ccall(
        (:binchrr, liblikwid), Cint, (const_bstring, Cint, const_bstring), b0, pos, b1
    )
end

function bninchr(b0, pos, b1)
    return ccall(
        (:bninchr, liblikwid), Cint, (const_bstring, Cint, const_bstring), b0, pos, b1
    )
end

function bninchrr(b0, pos, b1)
    return ccall(
        (:bninchrr, liblikwid), Cint, (const_bstring, Cint, const_bstring), b0, pos, b1
    )
end

function bfindreplace(b, find, repl, pos)
    return ccall(
        (:bfindreplace, liblikwid),
        Cint,
        (bstring, const_bstring, const_bstring, Cint),
        b,
        find,
        repl,
        pos,
    )
end

function bfindreplacecaseless(b, find, repl, pos)
    return ccall(
        (:bfindreplacecaseless, liblikwid),
        Cint,
        (bstring, const_bstring, const_bstring, Cint),
        b,
        find,
        repl,
        pos,
    )
end

struct bstrList
    qty::Cint
    mlen::Cint
    entry::Ptr{bstring}
end

function bstrListCreate()
    return ccall((:bstrListCreate, liblikwid), Ptr{bstrList}, ())
end

function bstrListDestroy(sl)
    return ccall((:bstrListDestroy, liblikwid), Cint, (Ptr{bstrList},), sl)
end

function bstrListAlloc(sl, msz)
    return ccall((:bstrListAlloc, liblikwid), Cint, (Ptr{bstrList}, Cint), sl, msz)
end

function bstrListAllocMin(sl, msz)
    return ccall((:bstrListAllocMin, liblikwid), Cint, (Ptr{bstrList}, Cint), sl, msz)
end

function bsplit(str, splitChar)
    return ccall(
        (:bsplit, liblikwid), Ptr{bstrList}, (const_bstring, Cuchar), str, splitChar
    )
end

function bsplits(str, splitStr)
    return ccall(
        (:bsplits, liblikwid), Ptr{bstrList}, (const_bstring, const_bstring), str, splitStr
    )
end

function bsplitstr(str, splitStr)
    return ccall(
        (:bsplitstr, liblikwid),
        Ptr{bstrList},
        (const_bstring, const_bstring),
        str,
        splitStr,
    )
end

function bjoin(bl, sep)
    return ccall((:bjoin, liblikwid), bstring, (Ptr{bstrList}, const_bstring), bl, sep)
end

function bsplitcb(str, splitChar, pos, cb, parm)
    return ccall(
        (:bsplitcb, liblikwid),
        Cint,
        (const_bstring, Cuchar, Cint, Ptr{Cvoid}, Ptr{Cvoid}),
        str,
        splitChar,
        pos,
        cb,
        parm,
    )
end

function bsplitscb(str, splitStr, pos, cb, parm)
    return ccall(
        (:bsplitscb, liblikwid),
        Cint,
        (const_bstring, const_bstring, Cint, Ptr{Cvoid}, Ptr{Cvoid}),
        str,
        splitStr,
        pos,
        cb,
        parm,
    )
end

function bsplitstrcb(str, splitStr, pos, cb, parm)
    return ccall(
        (:bsplitstrcb, liblikwid),
        Cint,
        (const_bstring, const_bstring, Cint, Ptr{Cvoid}, Ptr{Cvoid}),
        str,
        splitStr,
        pos,
        cb,
        parm,
    )
end

function bpattern(b, len)
    return ccall((:bpattern, liblikwid), Cint, (bstring, Cint), b, len)
end

function btoupper(b)
    return ccall((:btoupper, liblikwid), Cint, (bstring,), b)
end

function btolower(b)
    return ccall((:btolower, liblikwid), Cint, (bstring,), b)
end

function bltrimws(b)
    return ccall((:bltrimws, liblikwid), Cint, (bstring,), b)
end

function brtrimws(b)
    return ccall((:brtrimws, liblikwid), Cint, (bstring,), b)
end

function btrimws(b)
    return ccall((:btrimws, liblikwid), Cint, (bstring,), b)
end

# typedef int ( * bNgetc ) ( void * parm )
const bNgetc = Ptr{Cvoid}

# typedef size_t ( * bNread ) ( void * buff , size_t elsize , size_t nelem , void * parm )
const bNread = Ptr{Cvoid}

function bgets(getcPtr, parm, terminator)
    return ccall(
        (:bgets, liblikwid), bstring, (bNgetc, Ptr{Cvoid}, Cchar), getcPtr, parm, terminator
    )
end

function bread(readPtr, parm)
    return ccall((:bread, liblikwid), bstring, (bNread, Ptr{Cvoid}), readPtr, parm)
end

function bgetsa(b, getcPtr, parm, terminator)
    return ccall(
        (:bgetsa, liblikwid),
        Cint,
        (bstring, bNgetc, Ptr{Cvoid}, Cchar),
        b,
        getcPtr,
        parm,
        terminator,
    )
end

function bassigngets(b, getcPtr, parm, terminator)
    return ccall(
        (:bassigngets, liblikwid),
        Cint,
        (bstring, bNgetc, Ptr{Cvoid}, Cchar),
        b,
        getcPtr,
        parm,
        terminator,
    )
end

function breada(b, readPtr, parm)
    return ccall(
        (:breada, liblikwid), Cint, (bstring, bNread, Ptr{Cvoid}), b, readPtr, parm
    )
end

mutable struct bStream end

function bsopen(readPtr, parm)
    return ccall((:bsopen, liblikwid), Ptr{bStream}, (bNread, Ptr{Cvoid}), readPtr, parm)
end

function bsclose(s)
    return ccall((:bsclose, liblikwid), Ptr{Cvoid}, (Ptr{bStream},), s)
end

function bsbufflength(s, sz)
    return ccall((:bsbufflength, liblikwid), Cint, (Ptr{bStream}, Cint), s, sz)
end

function bsreadln(b, s, terminator)
    return ccall(
        (:bsreadln, liblikwid), Cint, (bstring, Ptr{bStream}, Cchar), b, s, terminator
    )
end

function bsreadlns(r, s, term)
    return ccall(
        (:bsreadlns, liblikwid), Cint, (bstring, Ptr{bStream}, const_bstring), r, s, term
    )
end

function bsread(b, s, n)
    return ccall((:bsread, liblikwid), Cint, (bstring, Ptr{bStream}, Cint), b, s, n)
end

function bsreadlna(b, s, terminator)
    return ccall(
        (:bsreadlna, liblikwid), Cint, (bstring, Ptr{bStream}, Cchar), b, s, terminator
    )
end

function bsreadlnsa(r, s, term)
    return ccall(
        (:bsreadlnsa, liblikwid), Cint, (bstring, Ptr{bStream}, const_bstring), r, s, term
    )
end

function bsreada(b, s, n)
    return ccall((:bsreada, liblikwid), Cint, (bstring, Ptr{bStream}, Cint), b, s, n)
end

function bsunread(s, b)
    return ccall((:bsunread, liblikwid), Cint, (Ptr{bStream}, const_bstring), s, b)
end

function bspeek(r, s)
    return ccall((:bspeek, liblikwid), Cint, (bstring, Ptr{bStream}), r, s)
end

function bssplitscb(s, splitStr, cb, parm)
    return ccall(
        (:bssplitscb, liblikwid),
        Cint,
        (Ptr{bStream}, const_bstring, Ptr{Cvoid}, Ptr{Cvoid}),
        s,
        splitStr,
        cb,
        parm,
    )
end

function bssplitstrcb(s, splitStr, cb, parm)
    return ccall(
        (:bssplitstrcb, liblikwid),
        Cint,
        (Ptr{bStream}, const_bstring, Ptr{Cvoid}, Ptr{Cvoid}),
        s,
        splitStr,
        cb,
        parm,
    )
end

function bseof(s)
    return ccall((:bseof, liblikwid), Cint, (Ptr{bStream},), s)
end

function likwid_markerInit()
    return ccall((:likwid_markerInit, liblikwid), Cvoid, ())
end

function likwid_markerThreadInit()
    return ccall((:likwid_markerThreadInit, liblikwid), Cvoid, ())
end

function likwid_markerNextGroup()
    return ccall((:likwid_markerNextGroup, liblikwid), Cvoid, ())
end

function likwid_markerClose()
    return ccall((:likwid_markerClose, liblikwid), Cvoid, ())
end

function likwid_markerRegisterRegion(regionTag)
    return ccall((:likwid_markerRegisterRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_markerStartRegion(regionTag)
    return ccall((:likwid_markerStartRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_markerStopRegion(regionTag)
    return ccall((:likwid_markerStopRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_markerResetRegion(regionTag)
    return ccall((:likwid_markerResetRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_markerGetRegion(regionTag, nr_events, events, time, count)
    return ccall(
        (:likwid_markerGetRegion, liblikwid),
        Cvoid,
        (Ptr{Cchar}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}),
        regionTag,
        nr_events,
        events,
        time,
        count,
    )
end

# no prototype is found for this function at likwid.h:158:13, please use with caution
function likwid_getProcessorId()
    return ccall((:likwid_getProcessorId, liblikwid), Cint, ())
end

function likwid_pinProcess(processorId)
    return ccall((:likwid_pinProcess, liblikwid), Cint, (Cint,), processorId)
end

function likwid_pinThread(processorId)
    return ccall((:likwid_pinThread, liblikwid), Cint, (Cint,), processorId)
end

@cenum AccessMode::Int32 begin
    ACCESSMODE_PERF = -1
    ACCESSMODE_DIRECT = 0
    ACCESSMODE_DAEMON = 1
end

function HPMmode(mode)
    return ccall((:HPMmode, liblikwid), Cvoid, (Cint,), mode)
end

# no prototype is found for this function at likwid.h:210:12, please use with caution
function HPMinit()
    return ccall((:HPMinit, liblikwid), Cint, ())
end

function HPMaddThread(cpu_id)
    return ccall((:HPMaddThread, liblikwid), Cint, (Cint,), cpu_id)
end

# no prototype is found for this function at likwid.h:222:13, please use with caution
function HPMfinalize()
    return ccall((:HPMfinalize, liblikwid), Cvoid, ())
end

struct Likwid_Configuration
    configFileName::Ptr{Cchar}
    topologyCfgFileName::Ptr{Cchar}
    daemonPath::Ptr{Cchar}
    groupPath::Ptr{Cchar}
    daemonMode::AccessMode
    maxNumThreads::Cint
    maxNumNodes::Cint
end

const Configuration_t = Ptr{Likwid_Configuration}

function init_configuration()
    return ccall((:init_configuration, liblikwid), Cint, ())
end

function destroy_configuration()
    return ccall((:destroy_configuration, liblikwid), Cint, ())
end

function get_configuration()
    return ccall((:get_configuration, liblikwid), Configuration_t, ())
end

function config_setGroupPath(path)
    return ccall((:config_setGroupPath, liblikwid), Cint, (Ptr{Cchar},), path)
end

struct CpuInfo
    family::UInt32
    model::UInt32
    stepping::UInt32
    vendor::UInt32
    part::UInt32
    clock::UInt64
    turbo::Cint
    osname::Ptr{Cchar}
    name::Ptr{Cchar}
    short_name::Ptr{Cchar}
    features::Ptr{Cchar}
    isIntel::Cint
    architecture::NTuple{20,Cchar}
    supportUncore::Cint
    supportClientmem::Cint
    featureFlags::UInt64
    perf_version::UInt32
    perf_num_ctr::UInt32
    perf_width_ctr::UInt32
    perf_num_fixed_ctr::UInt32
end

struct HWThread
    threadId::UInt32
    coreId::UInt32
    packageId::UInt32
    apicId::UInt32
    dieId::UInt32
    inCpuSet::UInt32
end

@cenum CacheType::UInt32 begin
    NOCACHE = 0
    DATACACHE = 1
    INSTRUCTIONCACHE = 2
    UNIFIEDCACHE = 3
    ITLB = 4
    DTLB = 5
end

struct CacheLevel
    level::UInt32
    type::CacheType
    associativity::UInt32
    sets::UInt32
    lineSize::UInt32
    size::UInt32
    threads::UInt32
    inclusive::UInt32
end

mutable struct treeNode end

struct CpuTopology
    numHWThreads::UInt32
    activeHWThreads::UInt32
    numSockets::UInt32
    numDies::UInt32
    numCoresPerSocket::UInt32
    numThreadsPerCore::UInt32
    numCacheLevels::UInt32
    threadPool::Ptr{HWThread}
    cacheLevels::Ptr{CacheLevel}
    topologyTree::Ptr{treeNode}
end

const CpuInfo_t = Ptr{CpuInfo}

const CpuTopology_t = Ptr{CpuTopology}

function topology_init()
    return ccall((:topology_init, liblikwid), Cint, ())
end

function get_cpuTopology()
    return ccall((:get_cpuTopology, liblikwid), CpuTopology_t, ())
end

function get_cpuInfo()
    return ccall((:get_cpuInfo, liblikwid), CpuInfo_t, ())
end

function topology_finalize()
    return ccall((:topology_finalize, liblikwid), Cvoid, ())
end

function print_supportedCPUs()
    return ccall((:print_supportedCPUs, liblikwid), Cvoid, ())
end

struct NumaNode
    id::UInt32
    totalMemory::UInt64
    freeMemory::UInt64
    numberOfProcessors::UInt32
    processors::Ptr{UInt32}
    numberOfDistances::UInt32
    distances::Ptr{UInt32}
end

struct NumaTopology
    numberOfNodes::UInt32
    nodes::Ptr{NumaNode}
end

const NumaTopology_t = Ptr{NumaTopology}

function numa_init()
    return ccall((:numa_init, liblikwid), Cint, ())
end

function get_numaTopology()
    return ccall((:get_numaTopology, liblikwid), NumaTopology_t, ())
end

function numa_setInterleaved(processorList, numberOfProcessors)
    return ccall(
        (:numa_setInterleaved, liblikwid),
        Cvoid,
        (Ptr{Cint}, Cint),
        processorList,
        numberOfProcessors,
    )
end

function numa_membind(ptr, size, domainId)
    return ccall(
        (:numa_membind, liblikwid), Cvoid, (Ptr{Cvoid}, Csize_t, Cint), ptr, size, domainId
    )
end

function numa_setMembind(processorList, numberOfProcessors)
    return ccall(
        (:numa_setMembind, liblikwid),
        Cvoid,
        (Ptr{Cint}, Cint),
        processorList,
        numberOfProcessors,
    )
end

function numa_finalize()
    return ccall((:numa_finalize, liblikwid), Cvoid, ())
end

function likwid_getNumberOfNodes()
    return ccall((:likwid_getNumberOfNodes, liblikwid), Cint, ())
end

struct AffinityDomain
    tag::bstring
    numberOfProcessors::UInt32
    numberOfCores::UInt32
    processorList::Ptr{Cint}
end

struct AffinityDomains
    numberOfSocketDomains::UInt32
    numberOfNumaDomains::UInt32
    numberOfProcessorsPerSocket::UInt32
    numberOfCacheDomains::UInt32
    numberOfCoresPerCache::UInt32
    numberOfProcessorsPerCache::UInt32
    numberOfAffinityDomains::UInt32
    domains::Ptr{AffinityDomain}
end

const AffinityDomains_t = Ptr{AffinityDomains}

# no prototype is found for this function at likwid.h:564:13, please use with caution
function affinity_init()
    return ccall((:affinity_init, liblikwid), Cvoid, ())
end

function get_affinityDomains()
    return ccall((:get_affinityDomains, liblikwid), AffinityDomains_t, ())
end

function affinity_pinProcess(processorId)
    return ccall((:affinity_pinProcess, liblikwid), Cvoid, (Cint,), processorId)
end

function affinity_pinProcesses(cpu_count, processorIds)
    return ccall(
        (:affinity_pinProcesses, liblikwid),
        Cvoid,
        (Cint, Ptr{Cint}),
        cpu_count,
        processorIds,
    )
end

function affinity_pinThread(processorId)
    return ccall((:affinity_pinThread, liblikwid), Cvoid, (Cint,), processorId)
end

# no prototype is found for this function at likwid.h:595:12, please use with caution
function affinity_processGetProcessorId()
    return ccall((:affinity_processGetProcessorId, liblikwid), Cint, ())
end

# no prototype is found for this function at likwid.h:600:12, please use with caution
function affinity_threadGetProcessorId()
    return ccall((:affinity_threadGetProcessorId, liblikwid), Cint, ())
end

# no prototype is found for this function at likwid.h:607:13, please use with caution
function affinity_finalize()
    return ccall((:affinity_finalize, liblikwid), Cvoid, ())
end

function cpustr_to_cpulist(cpustring, cpulist, length)
    return ccall(
        (:cpustr_to_cpulist, liblikwid),
        Cint,
        (Ptr{Cchar}, Ptr{Cint}, Cint),
        cpustring,
        cpulist,
        length,
    )
end

function nodestr_to_nodelist(nodestr, nodes, length)
    return ccall(
        (:nodestr_to_nodelist, liblikwid),
        Cint,
        (Ptr{Cchar}, Ptr{Cint}, Cint),
        nodestr,
        nodes,
        length,
    )
end

function sockstr_to_socklist(sockstr, sockets, length)
    return ccall(
        (:sockstr_to_socklist, liblikwid),
        Cint,
        (Ptr{Cchar}, Ptr{Cint}, Cint),
        sockstr,
        sockets,
        length,
    )
end

function perfmon_getGroups(groups, shortinfos, longinfos)
    return ccall(
        (:perfmon_getGroups, liblikwid),
        Cint,
        (Ptr{Ptr{Ptr{Cchar}}}, Ptr{Ptr{Ptr{Cchar}}}, Ptr{Ptr{Ptr{Cchar}}}),
        groups,
        shortinfos,
        longinfos,
    )
end

function perfmon_returnGroups(nrgroups, groups, shortinfos, longinfos)
    return ccall(
        (:perfmon_returnGroups, liblikwid),
        Cvoid,
        (Cint, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}),
        nrgroups,
        groups,
        shortinfos,
        longinfos,
    )
end

function perfmon_init(nrThreads, threadsToCpu)
    return ccall(
        (:perfmon_init, liblikwid), Cint, (Cint, Ptr{Cint}), nrThreads, threadsToCpu
    )
end

function perfmon_init_maps()
    return ccall((:perfmon_init_maps, liblikwid), Cvoid, ())
end

function perfmon_check_counter_map(cpu_id)
    return ccall((:perfmon_check_counter_map, liblikwid), Cvoid, (Cint,), cpu_id)
end

function perfmon_addEventSet(eventCString)
    return ccall((:perfmon_addEventSet, liblikwid), Cint, (Ptr{Cchar},), eventCString)
end

function perfmon_setupCounters(groupId)
    return ccall((:perfmon_setupCounters, liblikwid), Cint, (Cint,), groupId)
end

function perfmon_startCounters()
    return ccall((:perfmon_startCounters, liblikwid), Cint, ())
end

function perfmon_stopCounters()
    return ccall((:perfmon_stopCounters, liblikwid), Cint, ())
end

function perfmon_readCounters()
    return ccall((:perfmon_readCounters, liblikwid), Cint, ())
end

function perfmon_readCountersCpu(cpu_id)
    return ccall((:perfmon_readCountersCpu, liblikwid), Cint, (Cint,), cpu_id)
end

function perfmon_readGroupCounters(groupId)
    return ccall((:perfmon_readGroupCounters, liblikwid), Cint, (Cint,), groupId)
end

function perfmon_readGroupThreadCounters(groupId, threadId)
    return ccall(
        (:perfmon_readGroupThreadCounters, liblikwid), Cint, (Cint, Cint), groupId, threadId
    )
end

function perfmon_switchActiveGroup(new_group)
    return ccall((:perfmon_switchActiveGroup, liblikwid), Cint, (Cint,), new_group)
end

function perfmon_finalize()
    return ccall((:perfmon_finalize, liblikwid), Cvoid, ())
end

function perfmon_getResult(groupId, eventId, threadId)
    return ccall(
        (:perfmon_getResult, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        groupId,
        eventId,
        threadId,
    )
end

function perfmon_getLastResult(groupId, eventId, threadId)
    return ccall(
        (:perfmon_getLastResult, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        groupId,
        eventId,
        threadId,
    )
end

function perfmon_getMetric(groupId, metricId, threadId)
    return ccall(
        (:perfmon_getMetric, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        groupId,
        metricId,
        threadId,
    )
end

function perfmon_getLastMetric(groupId, metricId, threadId)
    return ccall(
        (:perfmon_getLastMetric, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        groupId,
        metricId,
        threadId,
    )
end

function perfmon_getNumberOfGroups()
    return ccall((:perfmon_getNumberOfGroups, liblikwid), Cint, ())
end

function perfmon_getNumberOfEvents(groupId)
    return ccall((:perfmon_getNumberOfEvents, liblikwid), Cint, (Cint,), groupId)
end

function perfmon_getTimeOfGroup(groupId)
    return ccall((:perfmon_getTimeOfGroup, liblikwid), Cdouble, (Cint,), groupId)
end

function perfmon_getIdOfActiveGroup()
    return ccall((:perfmon_getIdOfActiveGroup, liblikwid), Cint, ())
end

function perfmon_getNumberOfThreads()
    return ccall((:perfmon_getNumberOfThreads, liblikwid), Cint, ())
end

function perfmon_setVerbosity(verbose)
    return ccall((:perfmon_setVerbosity, liblikwid), Cvoid, (Cint,), verbose)
end

function perfmon_getEventName(groupId, eventId)
    return ccall(
        (:perfmon_getEventName, liblikwid), Ptr{Cchar}, (Cint, Cint), groupId, eventId
    )
end

function perfmon_getCounterName(groupId, eventId)
    return ccall(
        (:perfmon_getCounterName, liblikwid), Ptr{Cchar}, (Cint, Cint), groupId, eventId
    )
end

function perfmon_getGroupName(groupId)
    return ccall((:perfmon_getGroupName, liblikwid), Ptr{Cchar}, (Cint,), groupId)
end

function perfmon_getMetricName(groupId, metricId)
    return ccall(
        (:perfmon_getMetricName, liblikwid), Ptr{Cchar}, (Cint, Cint), groupId, metricId
    )
end

function perfmon_getGroupInfoShort(groupId)
    return ccall((:perfmon_getGroupInfoShort, liblikwid), Ptr{Cchar}, (Cint,), groupId)
end

function perfmon_getGroupInfoLong(groupId)
    return ccall((:perfmon_getGroupInfoLong, liblikwid), Ptr{Cchar}, (Cint,), groupId)
end

function perfmon_getNumberOfMetrics(groupId)
    return ccall((:perfmon_getNumberOfMetrics, liblikwid), Cint, (Cint,), groupId)
end

function perfmon_getLastTimeOfGroup(groupId)
    return ccall((:perfmon_getLastTimeOfGroup, liblikwid), Cdouble, (Cint,), groupId)
end

function perfmon_readMarkerFile(filename)
    return ccall((:perfmon_readMarkerFile, liblikwid), Cint, (Ptr{Cchar},), filename)
end

# no prototype is found for this function at likwid.h:942:13, please use with caution
function perfmon_destroyMarkerResults()
    return ccall((:perfmon_destroyMarkerResults, liblikwid), Cvoid, ())
end

# no prototype is found for this function at likwid.h:947:12, please use with caution
function perfmon_getNumberOfRegions()
    return ccall((:perfmon_getNumberOfRegions, liblikwid), Cint, ())
end

function perfmon_getGroupOfRegion(region)
    return ccall((:perfmon_getGroupOfRegion, liblikwid), Cint, (Cint,), region)
end

function perfmon_getTagOfRegion(region)
    return ccall((:perfmon_getTagOfRegion, liblikwid), Ptr{Cchar}, (Cint,), region)
end

function perfmon_getEventsOfRegion(region)
    return ccall((:perfmon_getEventsOfRegion, liblikwid), Cint, (Cint,), region)
end

function perfmon_getMetricsOfRegion(region)
    return ccall((:perfmon_getMetricsOfRegion, liblikwid), Cint, (Cint,), region)
end

function perfmon_getThreadsOfRegion(region)
    return ccall((:perfmon_getThreadsOfRegion, liblikwid), Cint, (Cint,), region)
end

function perfmon_getCpulistOfRegion(region, count, cpulist)
    return ccall(
        (:perfmon_getCpulistOfRegion, liblikwid),
        Cint,
        (Cint, Cint, Ptr{Cint}),
        region,
        count,
        cpulist,
    )
end

function perfmon_getTimeOfRegion(region, thread)
    return ccall(
        (:perfmon_getTimeOfRegion, liblikwid), Cdouble, (Cint, Cint), region, thread
    )
end

function perfmon_getCountOfRegion(region, thread)
    return ccall((:perfmon_getCountOfRegion, liblikwid), Cint, (Cint, Cint), region, thread)
end

function perfmon_getResultOfRegionThread(region, event, thread)
    return ccall(
        (:perfmon_getResultOfRegionThread, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        region,
        event,
        thread,
    )
end

function perfmon_getMetricOfRegionThread(region, metricId, threadId)
    return ccall(
        (:perfmon_getMetricOfRegionThread, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        region,
        metricId,
        threadId,
    )
end

struct GroupInfo
    groupname::Ptr{Cchar}
    shortinfo::Ptr{Cchar}
    nevents::Cint
    events::Ptr{Ptr{Cchar}}
    counters::Ptr{Ptr{Cchar}}
    nmetrics::Cint
    metricnames::Ptr{Ptr{Cchar}}
    metricformulas::Ptr{Ptr{Cchar}}
    longinfo::Ptr{Cchar}
end

function perfgroup_new(ginfo)
    return ccall((:perfgroup_new, liblikwid), Cint, (Ptr{GroupInfo},), ginfo)
end

function perfgroup_addEvent(ginfo, counter, event)
    return ccall(
        (:perfgroup_addEvent, liblikwid),
        Cint,
        (Ptr{GroupInfo}, Ptr{Cchar}, Ptr{Cchar}),
        ginfo,
        counter,
        event,
    )
end

function perfgroup_removeEvent(ginfo, counter)
    return ccall(
        (:perfgroup_removeEvent, liblikwid),
        Cvoid,
        (Ptr{GroupInfo}, Ptr{Cchar}),
        ginfo,
        counter,
    )
end

function perfgroup_addMetric(ginfo, mname, mcalc)
    return ccall(
        (:perfgroup_addMetric, liblikwid),
        Cint,
        (Ptr{GroupInfo}, Ptr{Cchar}, Ptr{Cchar}),
        ginfo,
        mname,
        mcalc,
    )
end

function perfgroup_removeMetric(ginfo, mname)
    return ccall(
        (:perfgroup_removeMetric, liblikwid),
        Cvoid,
        (Ptr{GroupInfo}, Ptr{Cchar}),
        ginfo,
        mname,
    )
end

function perfgroup_getEventStr(ginfo)
    return ccall((:perfgroup_getEventStr, liblikwid), Ptr{Cchar}, (Ptr{GroupInfo},), ginfo)
end

function perfgroup_returnEventStr(eventStr)
    return ccall((:perfgroup_returnEventStr, liblikwid), Cvoid, (Ptr{Cchar},), eventStr)
end

function perfgroup_getGroupName(ginfo)
    return ccall((:perfgroup_getGroupName, liblikwid), Ptr{Cchar}, (Ptr{GroupInfo},), ginfo)
end

function perfgroup_setGroupName(ginfo, groupName)
    return ccall(
        (:perfgroup_setGroupName, liblikwid),
        Cint,
        (Ptr{GroupInfo}, Ptr{Cchar}),
        ginfo,
        groupName,
    )
end

function perfgroup_returnGroupName(gname)
    return ccall((:perfgroup_returnGroupName, liblikwid), Cvoid, (Ptr{Cchar},), gname)
end

function perfgroup_setShortInfo(ginfo, shortInfo)
    return ccall(
        (:perfgroup_setShortInfo, liblikwid),
        Cint,
        (Ptr{GroupInfo}, Ptr{Cchar}),
        ginfo,
        shortInfo,
    )
end

function perfgroup_getShortInfo(ginfo)
    return ccall((:perfgroup_getShortInfo, liblikwid), Ptr{Cchar}, (Ptr{GroupInfo},), ginfo)
end

function perfgroup_returnShortInfo(sinfo)
    return ccall((:perfgroup_returnShortInfo, liblikwid), Cvoid, (Ptr{Cchar},), sinfo)
end

function perfgroup_setLongInfo(ginfo, longInfo)
    return ccall(
        (:perfgroup_setLongInfo, liblikwid),
        Cint,
        (Ptr{GroupInfo}, Ptr{Cchar}),
        ginfo,
        longInfo,
    )
end

function perfgroup_getLongInfo(ginfo)
    return ccall((:perfgroup_getLongInfo, liblikwid), Ptr{Cchar}, (Ptr{GroupInfo},), ginfo)
end

function perfgroup_returnLongInfo(linfo)
    return ccall((:perfgroup_returnLongInfo, liblikwid), Cvoid, (Ptr{Cchar},), linfo)
end

function perfgroup_mergeGroups(grp1, grp2)
    return ccall(
        (:perfgroup_mergeGroups, liblikwid),
        Cint,
        (Ptr{GroupInfo}, Ptr{GroupInfo}),
        grp1,
        grp2,
    )
end

function perfgroup_readGroup(grouppath, architecture, groupname, ginfo)
    return ccall(
        (:perfgroup_readGroup, liblikwid),
        Cint,
        (Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{GroupInfo}),
        grouppath,
        architecture,
        groupname,
        ginfo,
    )
end

function perfgroup_customGroup(eventStr, ginfo)
    return ccall(
        (:perfgroup_customGroup, liblikwid),
        Cint,
        (Ptr{Cchar}, Ptr{GroupInfo}),
        eventStr,
        ginfo,
    )
end

function perfgroup_returnGroup(ginfo)
    return ccall((:perfgroup_returnGroup, liblikwid), Cvoid, (Ptr{GroupInfo},), ginfo)
end

function perfgroup_getGroups(grouppath, architecture, groupnames, groupshort, grouplong)
    return ccall(
        (:perfgroup_getGroups, liblikwid),
        Cint,
        (
            Ptr{Cchar},
            Ptr{Cchar},
            Ptr{Ptr{Ptr{Cchar}}},
            Ptr{Ptr{Ptr{Cchar}}},
            Ptr{Ptr{Ptr{Cchar}}},
        ),
        grouppath,
        architecture,
        groupnames,
        groupshort,
        grouplong,
    )
end

function perfgroup_returnGroups(groups, groupnames, groupshort, grouplong)
    return ccall(
        (:perfgroup_returnGroups, liblikwid),
        Cvoid,
        (Cint, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}),
        groups,
        groupnames,
        groupshort,
        grouplong,
    )
end

struct TscCounter
    data::NTuple{8,UInt8}

    TscCounter() = new(ntuple(i -> zero(UInt8), 8))
end

Base.Int64(t::TscCounter) = Int64(t.int64)
Base.iszero(t::TscCounter) = iszero(t.int64)
Base.:-(t1::TscCounter, t2::TscCounter) = Int64(t1.int64) - Int64(t2.int64)
Base.:+(t1::TscCounter, t2::TscCounter) = Int64(t1.int64) + Int64(t2.int64)

function Base.getproperty(x::Ptr{TscCounter}, f::Symbol)
    f === :int64 && return Ptr{UInt64}(x + 0)
    f === :int32 && return Ptr{Ctag279}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::TscCounter, f::Symbol)
    r = Ref{TscCounter}(x)
    ptr = Base.unsafe_convert(Ptr{TscCounter}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{TscCounter}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct TimerData
    start::TscCounter
    stop::TscCounter

    TimerData() = new(TscCounter(), TscCounter())
end

function timer_init()
    return ccall((:timer_init, liblikwid), Cvoid, ())
end

function timer_print(time)
    return ccall((:timer_print, liblikwid), Cdouble, (Ptr{TimerData},), time)
end

function timer_printCycles(time)
    return ccall((:timer_printCycles, liblikwid), UInt64, (Ptr{TimerData},), time)
end

function timer_reset(time)
    return ccall((:timer_reset, liblikwid), Cvoid, (Ptr{TimerData},), time)
end

function timer_getCpuClock()
    return ccall((:timer_getCpuClock, liblikwid), UInt64, ())
end

function timer_getCpuClockCurrent(cpu_id)
    return ccall((:timer_getCpuClockCurrent, liblikwid), UInt64, (Cint,), cpu_id)
end

function timer_getCycleClock()
    return ccall((:timer_getCycleClock, liblikwid), UInt64, ())
end

function timer_getBaseline()
    return ccall((:timer_getBaseline, liblikwid), UInt64, ())
end

function timer_start(time)
    return ccall((:timer_start, liblikwid), Cvoid, (Ptr{TimerData},), time)
end

function timer_stop(time)
    return ccall((:timer_stop, liblikwid), Cvoid, (Ptr{TimerData},), time)
end

function timer_sleep(usec)
    return ccall((:timer_sleep, liblikwid), Cint, (Culong,), usec)
end

function timer_finalize()
    return ccall((:timer_finalize, liblikwid), Cvoid, ())
end

struct TurboBoost
    numSteps::Cint
    steps::Ptr{Cdouble}
end

@cenum PowerType::UInt32 begin
    PKG = 0
    PP0 = 1
    PP1 = 2
    DRAM = 3
    PLATFORM = 4
end

struct PowerDomain
    type::PowerType
    supportFlags::UInt32
    energyUnit::Cdouble
    tdp::Cdouble
    minPower::Cdouble
    maxPower::Cdouble
    maxTimeWindow::Cdouble
end

struct PowerInfo
    baseFrequency::Cdouble
    minFrequency::Cdouble
    turbo::TurboBoost
    hasRAPL::Cint
    powerUnit::Cdouble
    timeUnit::Cdouble
    uncoreMinFreq::Cdouble
    uncoreMaxFreq::Cdouble
    perfBias::UInt8
    domains::NTuple{5,PowerDomain}
end

struct PowerData
    domain::Cint
    before::UInt32
    after::UInt32
end

const PowerInfo_t = Ptr{PowerInfo}

const PowerData_t = Ptr{PowerData}

function power_init(cpuId)
    return ccall((:power_init, liblikwid), Cint, (Cint,), cpuId)
end

function get_powerInfo()
    return ccall((:get_powerInfo, liblikwid), PowerInfo_t, ())
end

function power_read(cpuId, reg, data)
    return ccall(
        (:power_read, liblikwid), Cint, (Cint, UInt64, Ptr{UInt32}), cpuId, reg, data
    )
end

function power_tread(socket_fd, cpuId, reg, data)
    return ccall(
        (:power_tread, liblikwid),
        Cint,
        (Cint, Cint, UInt64, Ptr{UInt32}),
        socket_fd,
        cpuId,
        reg,
        data,
    )
end

function power_start(data, cpuId, type)
    return ccall(
        (:power_start, liblikwid), Cint, (PowerData_t, Cint, PowerType), data, cpuId, type
    )
end

function power_stop(data, cpuId, type)
    return ccall(
        (:power_stop, liblikwid), Cint, (PowerData_t, Cint, PowerType), data, cpuId, type
    )
end

function power_printEnergy(data)
    return ccall((:power_printEnergy, liblikwid), Cdouble, (Ptr{PowerData},), data)
end

function power_getEnergyUnit(domain)
    return ccall((:power_getEnergyUnit, liblikwid), Cdouble, (Cint,), domain)
end

function power_limitGet(cpuId, domain, power, time)
    return ccall(
        (:power_limitGet, liblikwid),
        Cint,
        (Cint, PowerType, Ptr{Cdouble}, Ptr{Cdouble}),
        cpuId,
        domain,
        power,
        time,
    )
end

function power_limitSet(cpuId, domain, power, time, doClamping)
    return ccall(
        (:power_limitSet, liblikwid),
        Cint,
        (Cint, PowerType, Cdouble, Cdouble, Cint),
        cpuId,
        domain,
        power,
        time,
        doClamping,
    )
end

function power_limitState(cpuId, domain)
    return ccall((:power_limitState, liblikwid), Cint, (Cint, PowerType), cpuId, domain)
end

function power_finalize()
    return ccall((:power_finalize, liblikwid), Cvoid, ())
end

function thermal_init(cpuId)
    return ccall((:thermal_init, liblikwid), Cvoid, (Cint,), cpuId)
end

function thermal_read(cpuId, data)
    return ccall((:thermal_read, liblikwid), Cint, (Cint, Ptr{UInt32}), cpuId, data)
end

function thermal_tread(socket_fd, cpuId, data)
    return ccall(
        (:thermal_tread, liblikwid), Cint, (Cint, Cint, Ptr{UInt32}), socket_fd, cpuId, data
    )
end

function memsweep_domain(domainId)
    return ccall((:memsweep_domain, liblikwid), Cvoid, (Cint,), domainId)
end

function memsweep_threadGroup(processorList, numberOfProcessors)
    return ccall(
        (:memsweep_threadGroup, liblikwid),
        Cvoid,
        (Ptr{Cint}, Cint),
        processorList,
        numberOfProcessors,
    )
end

@cenum CpuFeature::UInt32 begin
    FEAT_HW_PREFETCHER = 0
    FEAT_CL_PREFETCHER = 1
    FEAT_DCU_PREFETCHER = 2
    FEAT_IP_PREFETCHER = 3
    FEAT_FAST_STRINGS = 4
    FEAT_THERMAL_CONTROL = 5
    FEAT_PERF_MON = 6
    FEAT_FERR_MULTIPLEX = 7
    FEAT_BRANCH_TRACE_STORAGE = 8
    FEAT_XTPR_MESSAGE = 9
    FEAT_PEBS = 10
    FEAT_SPEEDSTEP = 11
    FEAT_MONITOR = 12
    FEAT_SPEEDSTEP_LOCK = 13
    FEAT_CPUID_MAX_VAL = 14
    FEAT_XD_BIT = 15
    FEAT_DYN_ACCEL = 16
    FEAT_TURBO_MODE = 17
    FEAT_TM2 = 18
    CPUFEATURES_MAX = 19
end

# no prototype is found for this function at likwid.h:1602:13, please use with caution
function cpuFeatures_init()
    return ccall((:cpuFeatures_init, liblikwid), Cvoid, ())
end

function cpuFeatures_print(cpu)
    return ccall((:cpuFeatures_print, liblikwid), Cvoid, (Cint,), cpu)
end

function cpuFeatures_get(cpu, type)
    return ccall((:cpuFeatures_get, liblikwid), Cint, (Cint, CpuFeature), cpu, type)
end

function cpuFeatures_name(type)
    return ccall((:cpuFeatures_name, liblikwid), Ptr{Cchar}, (CpuFeature,), type)
end

function cpuFeatures_enable(cpu, type, print)
    return ccall(
        (:cpuFeatures_enable, liblikwid), Cint, (Cint, CpuFeature, Cint), cpu, type, print
    )
end

function cpuFeatures_disable(cpu, type, print)
    return ccall(
        (:cpuFeatures_disable, liblikwid), Cint, (Cint, CpuFeature, Cint), cpu, type, print
    )
end

function freq_init()
    return ccall((:freq_init, liblikwid), Cint, ())
end

function freq_getCpuClockBase(cpu_id)
    return ccall((:freq_getCpuClockBase, liblikwid), UInt64, (Cint,), cpu_id)
end

function freq_getCpuClockCurrent(cpu_id)
    return ccall((:freq_getCpuClockCurrent, liblikwid), UInt64, (Cint,), cpu_id)
end

function freq_getCpuClockMax(cpu_id)
    return ccall((:freq_getCpuClockMax, liblikwid), UInt64, (Cint,), cpu_id)
end

function freq_getConfCpuClockMax(cpu_id)
    return ccall((:freq_getConfCpuClockMax, liblikwid), UInt64, (Cint,), cpu_id)
end

function freq_setCpuClockMax(cpu_id, freq)
    return ccall((:freq_setCpuClockMax, liblikwid), UInt64, (Cint, UInt64), cpu_id, freq)
end

function freq_getCpuClockMin(cpu_id)
    return ccall((:freq_getCpuClockMin, liblikwid), UInt64, (Cint,), cpu_id)
end

function freq_getConfCpuClockMin(cpu_id)
    return ccall((:freq_getConfCpuClockMin, liblikwid), UInt64, (Cint,), cpu_id)
end

function freq_setCpuClockMin(cpu_id, freq)
    return ccall((:freq_setCpuClockMin, liblikwid), UInt64, (Cint, UInt64), cpu_id, freq)
end

function freq_setTurbo(cpu_id, turbo)
    return ccall((:freq_setTurbo, liblikwid), Cint, (Cint, Cint), cpu_id, turbo)
end

function freq_getTurbo(cpu_id)
    return ccall((:freq_getTurbo, liblikwid), Cint, (Cint,), cpu_id)
end

function freq_getGovernor(cpu_id)
    return ccall((:freq_getGovernor, liblikwid), Ptr{Cchar}, (Cint,), cpu_id)
end

function freq_setGovernor(cpu_id, gov)
    return ccall((:freq_setGovernor, liblikwid), Cint, (Cint, Ptr{Cchar}), cpu_id, gov)
end

function freq_getAvailFreq(cpu_id)
    return ccall((:freq_getAvailFreq, liblikwid), Ptr{Cchar}, (Cint,), cpu_id)
end

function freq_getAvailGovs(cpu_id)
    return ccall((:freq_getAvailGovs, liblikwid), Ptr{Cchar}, (Cint,), cpu_id)
end

function freq_setUncoreFreqMin(socket_id, freq)
    return ccall((:freq_setUncoreFreqMin, liblikwid), Cint, (Cint, UInt64), socket_id, freq)
end

function freq_getUncoreFreqMin(socket_id)
    return ccall((:freq_getUncoreFreqMin, liblikwid), UInt64, (Cint,), socket_id)
end

function freq_setUncoreFreqMax(socket_id, freq)
    return ccall((:freq_setUncoreFreqMax, liblikwid), Cint, (Cint, UInt64), socket_id, freq)
end

function freq_getUncoreFreqMax(socket_id)
    return ccall((:freq_getUncoreFreqMax, liblikwid), UInt64, (Cint,), socket_id)
end

function freq_getUncoreFreqCur(socket_id)
    return ccall((:freq_getUncoreFreqCur, liblikwid), UInt64, (Cint,), socket_id)
end

function freq_finalize()
    return ccall((:freq_finalize, liblikwid), Cvoid, ())
end

struct GpuDevice
    devid::Cint
    numaNode::Cint
    name::Ptr{Cchar}
    short_name::Ptr{Cchar}
    mem::UInt64
    ccapMajor::Cint
    ccapMinor::Cint
    maxThreadsPerBlock::Cint
    maxThreadsDim::NTuple{3,Cint}
    maxGridSize::NTuple{3,Cint}
    sharedMemPerBlock::Cint
    totalConstantMemory::Cint
    simdWidth::Cint
    memPitch::Cint
    regsPerBlock::Cint
    clockRatekHz::Cint
    textureAlign::Cint
    surfaceAlign::Cint
    l2Size::Cint
    memClockRatekHz::Cint
    pciBus::Cint
    pciDev::Cint
    pciDom::Cint
    maxBlockRegs::Cint
    numMultiProcs::Cint
    maxThreadPerMultiProc::Cint
    memBusWidth::Cint
    unifiedAddrSpace::Cint
    ecc::Cint
    asyncEngines::Cint
    mapHostMem::Cint
    integrated::Cint
end

struct GpuTopology
    numDevices::Cint
    devices::Ptr{GpuDevice}
end

const GpuTopology_t = Ptr{GpuTopology}

function topology_gpu_init()
    return ccall((:topology_gpu_init, liblikwid), Cint, ())
end

function topology_gpu_finalize()
    return ccall((:topology_gpu_finalize, liblikwid), Cvoid, ())
end

function get_gpuTopology()
    return ccall((:get_gpuTopology, liblikwid), GpuTopology_t, ())
end

function likwid_gpuMarkerInit()
    return ccall((:likwid_gpuMarkerInit, liblikwid), Cvoid, ())
end

function likwid_gpuMarkerNextGroup()
    return ccall((:likwid_gpuMarkerNextGroup, liblikwid), Cvoid, ())
end

function likwid_gpuMarkerClose()
    return ccall((:likwid_gpuMarkerClose, liblikwid), Cvoid, ())
end

function likwid_gpuMarkerRegisterRegion(regionTag)
    return ccall(
        (:likwid_gpuMarkerRegisterRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag
    )
end

function likwid_gpuMarkerStartRegion(regionTag)
    return ccall((:likwid_gpuMarkerStartRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_gpuMarkerStopRegion(regionTag)
    return ccall((:likwid_gpuMarkerStopRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_gpuMarkerResetRegion(regionTag)
    return ccall((:likwid_gpuMarkerResetRegion, liblikwid), Cint, (Ptr{Cchar},), regionTag)
end

function likwid_gpuMarkerGetRegion(regionTag, nr_gpus, nr_events, events, time, count)
    return ccall(
        (:likwid_gpuMarkerGetRegion, liblikwid),
        Cvoid,
        (Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}, Ptr{Ptr{Cdouble}}, Ptr{Cdouble}, Ptr{Cint}),
        regionTag,
        nr_gpus,
        nr_events,
        events,
        time,
        count,
    )
end

function nvmon_readMarkerFile(filename)
    return ccall((:nvmon_readMarkerFile, liblikwid), Cint, (Ptr{Cchar},), filename)
end

# no prototype is found for this function at likwid.h:1977:6, please use with caution
function nvmon_destroyMarkerResults()
    return ccall((:nvmon_destroyMarkerResults, liblikwid), Cvoid, ())
end

# no prototype is found for this function at likwid.h:1982:5, please use with caution
function nvmon_getNumberOfRegions()
    return ccall((:nvmon_getNumberOfRegions, liblikwid), Cint, ())
end

function nvmon_getMetricsOfRegion(region)
    return ccall((:nvmon_getMetricsOfRegion, liblikwid), Cint, (Cint,), region)
end

function nvmon_getGpusOfRegion(region)
    return ccall((:nvmon_getGpusOfRegion, liblikwid), Cint, (Cint,), region)
end

function nvmon_getGpulistOfRegion(region, count, gpulist)
    return ccall(
        (:nvmon_getGpulistOfRegion, liblikwid),
        Cint,
        (Cint, Cint, Ptr{Cint}),
        region,
        count,
        gpulist,
    )
end

function nvmon_getTimeOfRegion(region, gpu)
    return ccall((:nvmon_getTimeOfRegion, liblikwid), Cdouble, (Cint, Cint), region, gpu)
end

function nvmon_getCountOfRegion(region, gpu)
    return ccall((:nvmon_getCountOfRegion, liblikwid), Cint, (Cint, Cint), region, gpu)
end

function nvmon_getGroupOfRegion(region)
    return ccall((:nvmon_getGroupOfRegion, liblikwid), Cint, (Cint,), region)
end

function nvmon_getTagOfRegion(region)
    return ccall((:nvmon_getTagOfRegion, liblikwid), Ptr{Cchar}, (Cint,), region)
end

function nvmon_getEventsOfRegion(region)
    return ccall((:nvmon_getEventsOfRegion, liblikwid), Cint, (Cint,), region)
end

function nvmon_getResultOfRegionGpu(region, eventId, gpuId)
    return ccall(
        (:nvmon_getResultOfRegionGpu, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        region,
        eventId,
        gpuId,
    )
end

function nvmon_getMetricOfRegionGpu(region, metricId, gpuId)
    return ccall(
        (:nvmon_getMetricOfRegionGpu, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        region,
        metricId,
        gpuId,
    )
end

struct NvmonEventListEntry
    name::Ptr{Cchar}
    desc::Ptr{Cchar}
    limit::Ptr{Cchar}
end

struct NvmonEventList
    numEvents::Cint
    events::Ptr{NvmonEventListEntry}
end

const NvmonEventList_t = Ptr{NvmonEventList}

function nvmon_getEventsOfGpu(gpuId, list)
    return ccall(
        (:nvmon_getEventsOfGpu, liblikwid), Cint, (Cint, Ptr{NvmonEventList_t}), gpuId, list
    )
end

function nvmon_returnEventsOfGpu(list)
    return ccall((:nvmon_returnEventsOfGpu, liblikwid), Cvoid, (NvmonEventList_t,), list)
end

function nvmon_init(nrGpus, gpuIds)
    return ccall((:nvmon_init, liblikwid), Cint, (Cint, Ptr{Cint}), nrGpus, gpuIds)
end

function nvmon_finalize()
    return ccall((:nvmon_finalize, liblikwid), Cvoid, ())
end

function nvmon_addEventSet(eventCString)
    return ccall((:nvmon_addEventSet, liblikwid), Cint, (Ptr{Cchar},), eventCString)
end

function nvmon_setupCounters(gid)
    return ccall((:nvmon_setupCounters, liblikwid), Cint, (Cint,), gid)
end

function nvmon_startCounters()
    return ccall((:nvmon_startCounters, liblikwid), Cint, ())
end

function nvmon_stopCounters()
    return ccall((:nvmon_stopCounters, liblikwid), Cint, ())
end

function nvmon_readCounters()
    return ccall((:nvmon_readCounters, liblikwid), Cint, ())
end

function nvmon_switchActiveGroup(new_group)
    return ccall((:nvmon_switchActiveGroup, liblikwid), Cint, (Cint,), new_group)
end

function nvmon_setVerbosity(level)
    return ccall((:nvmon_setVerbosity, liblikwid), Cvoid, (Cint,), level)
end

function nvmon_getResult(groupId, eventId, gpuId)
    return ccall(
        (:nvmon_getResult, liblikwid), Cdouble, (Cint, Cint, Cint), groupId, eventId, gpuId
    )
end

function nvmon_getLastResult(groupId, eventId, gpuId)
    return ccall(
        (:nvmon_getLastResult, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        groupId,
        eventId,
        gpuId,
    )
end

function nvmon_getMetric(groupId, metricId, gpuId)
    return ccall(
        (:nvmon_getMetric, liblikwid), Cdouble, (Cint, Cint, Cint), groupId, metricId, gpuId
    )
end

function nvmon_getLastMetric(groupId, metricId, gpuId)
    return ccall(
        (:nvmon_getLastMetric, liblikwid),
        Cdouble,
        (Cint, Cint, Cint),
        groupId,
        metricId,
        gpuId,
    )
end

function nvmon_getNumberOfGroups()
    return ccall((:nvmon_getNumberOfGroups, liblikwid), Cint, ())
end

function nvmon_getIdOfActiveGroup()
    return ccall((:nvmon_getIdOfActiveGroup, liblikwid), Cint, ())
end

function nvmon_getNumberOfGPUs()
    return ccall((:nvmon_getNumberOfGPUs, liblikwid), Cint, ())
end

function nvmon_getNumberOfEvents(groupId)
    return ccall((:nvmon_getNumberOfEvents, liblikwid), Cint, (Cint,), groupId)
end

function nvmon_getNumberOfMetrics(groupId)
    return ccall((:nvmon_getNumberOfMetrics, liblikwid), Cint, (Cint,), groupId)
end

function nvmon_getTimeOfGroup(groupId)
    return ccall((:nvmon_getTimeOfGroup, liblikwid), Cdouble, (Cint,), groupId)
end

function nvmon_getLastTimeOfGroup(groupId)
    return ccall((:nvmon_getLastTimeOfGroup, liblikwid), Cdouble, (Cint,), groupId)
end

function nvmon_getEventName(groupId, eventId)
    return ccall(
        (:nvmon_getEventName, liblikwid), Ptr{Cchar}, (Cint, Cint), groupId, eventId
    )
end

function nvmon_getCounterName(groupId, eventId)
    return ccall(
        (:nvmon_getCounterName, liblikwid), Ptr{Cchar}, (Cint, Cint), groupId, eventId
    )
end

function nvmon_getMetricName(groupId, metricId)
    return ccall(
        (:nvmon_getMetricName, liblikwid), Ptr{Cchar}, (Cint, Cint), groupId, metricId
    )
end

function nvmon_getGroupName(groupId)
    return ccall((:nvmon_getGroupName, liblikwid), Ptr{Cchar}, (Cint,), groupId)
end

function nvmon_getGroupInfoShort(groupId)
    return ccall((:nvmon_getGroupInfoShort, liblikwid), Ptr{Cchar}, (Cint,), groupId)
end

function nvmon_getGroupInfoLong(groupId)
    return ccall((:nvmon_getGroupInfoLong, liblikwid), Ptr{Cchar}, (Cint,), groupId)
end

function nvmon_getGroups(gpuId, groups, shortinfos, longinfos)
    return ccall(
        (:nvmon_getGroups, liblikwid),
        Cint,
        (Cint, Ptr{Ptr{Ptr{Cchar}}}, Ptr{Ptr{Ptr{Cchar}}}, Ptr{Ptr{Ptr{Cchar}}}),
        gpuId,
        groups,
        shortinfos,
        longinfos,
    )
end

function nvmon_returnGroups(nrgroups, groups, shortinfos, longinfos)
    return ccall(
        (:nvmon_returnGroups, liblikwid),
        Cint,
        (Cint, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}),
        nrgroups,
        groups,
        shortinfos,
        longinfos,
    )
end

struct Ctag279
    lo::UInt32
    hi::UInt32
end
function Base.getproperty(x::Ptr{Ctag279}, f::Symbol)
    f === :lo && return Ptr{UInt32}(x + 0)
    f === :hi && return Ptr{UInt32}(x + 4)
    return getfield(x, f)
end

function Base.getproperty(x::Ctag279, f::Symbol)
    r = Ref{Ctag279}(x)
    ptr = Base.unsafe_convert(Ptr{Ctag279}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{Ctag279}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

const BSTR_ERR = -1

const BSTR_OK = 0

const BSTR_BS_BUFF_LENGTH_GET = 0

const cstr2bstr = bfromcstr

# const cstr2tbstr = btfromcstr

const DEBUGLEV_ONLY_ERROR = 0

const DEBUGLEV_INFO = 1

const DEBUGLEV_DETAIL = 2

const DEBUGLEV_DEVELOP = 3

const LIKWID_VERSION = "5.2.0"

# const LIKWID_COMMIT = GITCOMMIT

const NUM_POWER_DOMAINS = 5

const POWER_DOMAIN_SUPPORT_STATUS = Culonglong(1) << 0

const POWER_DOMAIN_SUPPORT_LIMIT = Culonglong(1) << 1

const POWER_DOMAIN_SUPPORT_POLICY = Culonglong(1) << 2

const POWER_DOMAIN_SUPPORT_PERF = Culonglong(1) << 3

const POWER_DOMAIN_SUPPORT_INFO = Culonglong(1) << 4

end # module
