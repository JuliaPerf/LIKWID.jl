# likwid-pin related code

"""
    pin_mask(N::Integer) -> mask
Generates a `mask` that can be supplied to `likwid pin -s <mask>` to pin `N` Julia threads.

Taken from https://discourse.julialang.org/t/thread-affinitization-pinning-julia-threads-to-cores/58069/8.
"""
function pin_mask(N::Integer)
    mask = UInt(0)
    for i in 1:N
        mask |= 1<<i
    end
    return ~mask # Invert the mask to only pin Julia threads
end