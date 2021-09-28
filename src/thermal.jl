"""
Initialize thermal measurements on the given CPU.
"""
function init_thermal(cpuid::Integer)
    LibLikwid.thermal_init(cpuid)
    return true
end

"""
Read the current temperature of the given CPU in degrees Celsius.
"""
function get_temperature(cpuid::Integer)
    init_thermal(cpuid)
    data = Ref(zero(UInt32))
    LibLikwid.thermal_read(cpuid, data)
    return Int(data[]) * u"°C"
end