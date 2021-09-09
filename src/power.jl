const POWER_DOMAIN_SUPPORT_STATUS = UInt64(1)<<0
const POWER_DOMAIN_SUPPORT_LIMIT = UInt64(1)<<1
const POWER_DOMAIN_SUPPORT_POLICY = UInt64(1)<<2
const POWER_DOMAIN_SUPPORT_PERF = UInt64(1)<<3
const POWER_DOMAIN_SUPPORT_INFO = UInt64(1)<<4

"""
Initialize energy measurements on specific CPU.
Returns the RAPL status, i.e. `false` (no RAPL) or `true` (RAPL working).
"""
function init_power(cpuid::Integer)
    RAPL = LibLikwid.power_init(cpuid)
    return Bool(RAPL)
end

function finalize_power()
    LibLikwid.power_finalize()
    return nothing
end

function get_power_info()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    hasRAPL = init_power(0)
    if !hasRAPL
        return nothing
    end
    _power = unsafe_load(LibLikwid.get_powerInfo())
    tb = TurboBoost(
        _power.turbo.numSteps,
        unsafe_wrap(Array, _power.turbo.steps, _power.turbo.numSteps)
    )
    pds = ntuple(i -> begin
            p = _power.domains[i]
            PowerDomain(
                p.type,
                p.type,
                p.supportFlags,
                p.energyUnit,
                p.tdp,
                p.minPower,
                p.maxPower,
                p.maxTimeWindow,
                !iszero(p.supportFlags & POWER_DOMAIN_SUPPORT_INFO),
                !iszero(p.supportFlags & POWER_DOMAIN_SUPPORT_STATUS),
                !iszero(p.supportFlags & POWER_DOMAIN_SUPPORT_PERF),
                !iszero(p.supportFlags & POWER_DOMAIN_SUPPORT_POLICY),
                !iszero(p.supportFlags & POWER_DOMAIN_SUPPORT_LIMIT),
            )
        end,
        5,
    )
    power = PowerInfo(
        _power.baseFrequency,
        _power.minFrequency,
        tb,
        _power.hasRAPL,
        _power.powerUnit,
        _power.timeUnit,
        _power.uncoreMinFreq,
        _power.uncoreMaxFreq,
        _power.perfBias,
        pds,
    )
    # necessary or otherwise returns nothing from second call on
    finalize_power()
    return power
end

# TODO... start_power, stop_power, get_power