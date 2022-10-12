module Prefs

using Preferences

"Clear all LIKWID.jl related preferences"
function clear()
    @delete_preferences!("liblikwid")
    @info("Done. Please restart Julia. Package might automatically recompile afterwards.")
end

"Set the path of the LIKWID library (`liblikwid`)."
function set_liblikwid(liblikwid::AbstractString)
    @set_preferences!("liblikwid" => liblikwid)
    @info("Done. Please restart Julia. Package might automatically recompile afterwards.")
    return nothing
end

"Query the value of the `liblikwid` preference. Returns `nothing` if not set."
function get_liblikwid()
    @load_preference("liblikwid")
end

end
