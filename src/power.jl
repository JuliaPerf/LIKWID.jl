const POWER_DOMAIN_SUPPORT_STATUS = UInt64(1) << 0
const POWER_DOMAIN_SUPPORT_LIMIT = UInt64(1) << 1
const POWER_DOMAIN_SUPPORT_POLICY = UInt64(1) << 2
const POWER_DOMAIN_SUPPORT_PERF = UInt64(1) << 3
const POWER_DOMAIN_SUPPORT_INFO = UInt64(1) << 4

"""
Initialize energy measurements on specific CPU.
Returns the RAPL status, i.e. `false` (no RAPL) or `true` (RAPL working).
"""
function init_power(cpuid::Integer)
    power_initialized[] && return true
    hasRAPL = LibLikwid.power_init(cpuid)
    if Bool(hasRAPL)
        _powerinfo[] = unsafe_load(LibLikwid.get_powerInfo())
        _build_jl_power()
        power_initialized[] = true
        return true
    end
    return false
end

# "helper"
function init_power()
    power_initialized[] && return true
    init_topology()
    return init_power(0)
end

function finalize_power()
    LibLikwid.power_finalize()
    power_initialized[] = false
    _powerinfo[] = nothing
    return nothing
end

function _build_jl_power()
    pi = _powerinfo[]
    tb = TurboBoost(
        pi.turbo.numSteps, unsafe_wrap(Array, pi.turbo.steps, pi.turbo.numSteps)
    )
    pds = ntuple(
        i -> begin
            p = pi.domains[i]
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
    powerinfo[] = PowerInfo(
        pi.baseFrequency,
        pi.minFrequency,
        tb,
        pi.hasRAPL,
        pi.powerUnit,
        pi.timeUnit,
        pi.uncoreMinFreq,
        pi.uncoreMaxFreq,
        pi.perfBias,
        pds,
    )
    return nothing
end

function get_power_info()
    if !topo_initialized[]
        init_topology() || error("Couldn't init topology.")
    end
    if !power_initialized[]
        init_power(0) || error("Couldn't init power.")
    end
    return powerinfo[]
end

"""
Return the start value for a cpu (`cpuid`) for the domain with `domainid`.
"""
function start_power(cpuid::Integer, domainid::Integer)
    pt = LibLikwid.PowerType(domainid)
    pd = LibLikwid.PowerData(pt, 0, 0)
    pd_ref = Ref(pd)
    LibLikwid.power_start(pd_ref, cpuid, pt)
    return Int(pd_ref[].before)
end

"""
Return the stop value for a cpu (`cpuid`) for the domain with `domainid`.
"""
function stop_power(cpuid::Integer, domainid::Integer)
    pt = LibLikwid.PowerType(domainid)
    pd = LibLikwid.PowerData(pt, 0, 0)
    pd_ref = Ref(pd)
    LibLikwid.power_stop(pd_ref, cpuid, pt)
    return Int(pd_ref[].after)
end

"""
    get_power(p_start::Integer, p_stop::Integer, domainid::Integer)
Calculate the uJ from the values retrieved by `start_power()`
and `stop_power()`.
"""
function get_power(p_start::Integer, p_stop::Integer, domainid::Integer)
    pt = LibLikwid.PowerType(domainid)
    pd = LibLikwid.PowerData(pt, p_start, p_stop)
    energy = LibLikwid.power_printEnergy(Ref(pd))
    return energy
end
