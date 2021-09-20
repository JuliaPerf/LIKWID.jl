module Freq

using ..LIKWID: LibLikwid

init() = LibLikwid.freq_init()

finalize() = LibLikwid.freq_finalize()

get_cpu_clock_current(cpuid::Integer) = LibLikwid.freq_getCpuClockCurrent(cpuid)
get_cpu_clock_max(cpuid::Integer) = LibLikwid.freq_getCpuClockMax(cpuid)
get_cpu_clock_min(cpuid::Integer) = LibLikwid.freq_getCpuClockMin(cpuid)
get_conf_cpu_clock_max(cpuid::Integer) = LibLikwid.freq_getConfCpuClockMax(cpuid)
get_conf_cpu_clock_min(cpuid::Integer) = LibLikwid.freq_getConfCpuClockMin(cpuid)

function set_cpu_clock_max(cpuid::Integer, freq::Integer)
    return LibLikwid.freq_setCpuClockMax(cpuid, freq)
end
function set_cpu_clock_min(cpuid::Integer, freq::Integer)
    return LibLikwid.freq_setCpuClockMin(cpuid, freq)
end

get_governor(cpuid::Integer) = LibLikwid.freq_getGovernor(cpuid)
set_governor(cpuid::Integer, g::String) = LibLikwid.freq_setGovernor(cpuid, g)

get_avail_freq(cpuid::Integer) = LibLikwid.freq_getAvailFreq(cpuid)
get_avail_govs(cpuid::Integer) = LibLikwid.freq_getAvailGovs(cpuid)

get_uncore_clock_min(s::Integer) = LibLikwid.freq_getUncoreFreqMin(s) * 1000000
set_uncore_clock_min(s::Integer, f::Integer) = LibLikwid.freq_setUncoreFreqMin(s, f)
get_uncore_clock_max(s::Integer) = LibLikwid.freq_getUncoreFreqMax(s) * 1000000
set_uncore_clock_max(s::Integer, f::Integer) = LibLikwid.freq_setUncoreFreqMax(s, f)

end # module
