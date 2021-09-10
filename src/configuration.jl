function init_configuration()
    config_initialized[] && return true
    ret = LibLikwid.init_configuration()
    if ret == 0
        config_initialized[] = true
        _config[] = unsafe_load(LibLikwid.get_configuration())
        _build_jl_config()
        return true
    end
    return false
end

function destroy_configuration()
    config_initialized[] || return false
    ret = LibLikwid.destroy_configuration()
    if ret == 0
        config_initialized[] = false
        return true
    end
    return false
end

function _build_jl_config()
    c = _config[]

    config[] = Likwid_Configuration(
        c.configFileName == C_NULL ? "" : unsafe_string(c.configFileName),
        c.topologyCfgFileName == C_NULL ? "" : unsafe_string(c.topologyCfgFileName),
        c.daemonPath == C_NULL ? "" : unsafe_string(c.daemonPath),
        c.groupPath == C_NULL ? "" : unsafe_string(c.groupPath),
        c.daemonMode,
        c.maxNumThreads,
        c.maxNumNodes,
    )
    return nothing
end

function get_configuration()
    if !config_initialized[]
        init_configuration() || error("Couldn't init configuration.")
    end
    return config[]
end