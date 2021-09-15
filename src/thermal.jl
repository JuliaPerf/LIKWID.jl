"""
Initialize thermal measurements on specific CPU.
"""
function init_thermal(cpuid::Integer)
    LibLikwid.thermal_init(cpuid)
    return true
end

"""
Read the current thermal value of a specific CPU.
"""
function read_thermal(cpuid::Integer)
    init_thermal(cpuid)
    data = Ref(zero(UInt32))
    LibLikwid.thermal_read(cpuid, data)
    return Int(data[])
end