module GPUTopo

using ..LIKWID: LibLikwid, gputopo_initialized, GpuDevice, GpuTopology, _gputopo, gputopo

function init()
    ret = LibLikwid.topology_gpu_init()
    if ret == 0
        _gputopo[] = unsafe_load(LibLikwid.get_gpuTopology())
        _build_jl_gputopo()
        gputopo_initialized[] = true
        return true
    end
    return false
end

function _build_jl_gputopo()
    gt = _gputopo[]

    ndevices = gt.numDevices
    _devices = unsafe_wrap(Array, gt.devices, ndevices)

    devices = Vector{GpuDevice}(undef, ndevices)
    for (i, dev) in enumerate(_devices)
        devices[i] = GpuDevice(
            dev.devid,
            dev.numaNode,
            unsafe_string(dev.name),
            unsafe_string(dev.short_name),
            dev.mem,
            dev.ccapMajor,
            dev.ccapMinor,
            dev.maxThreadsPerBlock,
            convert(NTuple{3,Int}, dev.maxThreadsDim),
            convert(NTuple{3,Int}, dev.maxGridSize),
            dev.sharedMemPerBlock,
            dev.totalConstantMemory,
            dev.simdWidth,
            dev.memPitch,
            dev.regsPerBlock,
            dev.clockRatekHz,
            dev.textureAlign,
            dev.surfaceAlign,
            dev.l2Size,
            dev.memClockRatekHz,
            dev.pciBus,
            dev.pciDev,
            dev.pciDom,
            dev.maxBlockRegs,
            dev.numMultiProcs,
            dev.maxThreadPerMultiProc,
            dev.memBusWidth,
            dev.unifiedAddrSpace,
            dev.ecc,
            dev.asyncEngines,
            dev.mapHostMem,
            dev.integrated,
        )
    end

    gputopo[] = GpuTopology(ndevices, devices)
    return nothing
end

function get_gpu_topology()
    if !gputopo_initialized[]
        init() || error("Couldn't init gpu topology.")
    end
    return gputopo[]
end

function finalize()
    LibLikwid.topology_gpu_finalize()
    gputopo_initialized[] = false
    _gputopo[] = nothing
    gputopo[] = nothing
    return nothing
end

end # module
