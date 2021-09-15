function init_topology_gpu()
    ret = LibLikwid.topology_gpu_init()
    if ret == 0
        _gputopo[] = unsafe_load(LibLikwid.get_gpuTopology())
        # _cpuinfo[] = unsafe_load(LibLikwid.get_cpuInfo())
        # _build_jl_cputopo()
        # _build_jl_cpuinfo()
        gputopo_initialized[] = true
        return true
    end
    return false
end

function _build_jl_gputopo()
    gt = _gputopo[]
    
    ndevices = gt.numDevices
    _devices = unsafe_wrap(Array, gt.devices, ndevices)

    # gputopo[] = GpuTopology(
    #     ...
    # )
    return nothing
end

function finalize_topology_gpu()
    LibLikwid.topology_gpu_finalize()
    gputopo_initialized[] = false
    # _cputopo[] = nothing
    # _cpuinfo[] = nothing
    # cputopo[] = nothing
    # cpuinfo[] = nothing
    return nothing
end