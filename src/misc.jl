"""
    pinmask(N::Integer) -> mask
Generates a `mask` that can be supplied to `likwid pin -s <mask>` to pin `N` Julia threads.

Taken from https://discourse.julialang.org/t/thread-affinitization-pinning-julia-threads-to-cores/58069/8.
"""
function pinmask(N::Integer)
    mask = UInt(0)
    for i in 1:N
        mask |= 1<<i
    end
    return _uint_to_hexmask(~mask) # Invert the mask to only pin Julia threads
end

_uint_to_hexmask(mask::UInt) = "0x" * string(mask, pad = sizeof(mask)<<1, base = 16)

"""
Set the verbosity level of the LIKWID library. Returns `true` on success.

Options are:
  * `LIKWID.LibLikwid.DEBUGLEV_ONLY_ERROR` or `0`

  * `LIKWID.LibLikwid.DEBUGLEV_INFO` or `1`

  * `LIKWID.LibLikwid.DEBUGLEV_DETAIL` or `2`

  * `LIKWID.LibLikwid.DEBUGLEV_DEVELOP` or `3`
"""
function setverbosity(verbosity::Integer)
    if verbosity ≥ LibLikwid.DEBUGLEV_ONLY_ERROR && verbosity ≤ LibLikwid.DEBUGLEV_DEVELOP
        LibLikwid.perfmon_setVerbosity(verbosity)
        return true
    end
    return false
end

"""
Returns whether LIKWID has been compiled with GPU support
(i.e. has been compiled with `NVIDIA_INTERFACE=true`).
"""
function gpusupport()
    # Note: Should be replaced by a less "hacky" implementation when
    # https://github.com/RRZE-HPC/likwid/issues/430 has been addressed.
    if isnothing(likwid_gpusupport[])
        likwid_gpusupport[] = _check_likwid_gpusupport()
    end
    return likwid_gpusupport[]
end

function _check_likwid_gpusupport()
    dlopen(liblikwid) do handle
        return !isnothing(dlsym(handle, :likwid_gpuMarkerInit; throw_error=false))
    end
end

function _check_likwid_gpusupport_alternative()
    x = _execute(`likwid-topology`)
    # if there is a gpu section in the output, return true
    contains(lowercase(x[1]), "gpu") && return true
    # if there is a cuda related error, return true
    contains(lowercase(x[2]), "cuda") && return true
    # else
    return false
end

"Run a Cmd object, returning the stdout & stderr contents plus the exit code"
function _execute(cmd::Cmd)
    out = Pipe()
    err = Pipe()

    process = run(pipeline(ignorestatus(cmd); stdout=out, stderr=err))
    close(out.in)
    close(err.in)

    out = (stdout=String(read(out)), stderr=String(read(err)), exitcode=process.exitcode)
    return out
end

function _execute_test(cmd::Cmd; print_only_on_fail=true)
    out = _execute(cmd)
    hasfailed = !iszero(out[:exitcode]) || (out[:stderr] != "")
    if !print_only_on_fail || hasfailed
        @info("Command: $cmd")
        @info("stdout:\n" * out[:stdout])
        @warn("stderr:\n" * out[:stderr])
    end
    return out[:exitcode] == 0
end

# working around https://github.com/JuliaLang/julia/issues/12711
function capture_stderr!(f::Function, io::IO)
    old_stderr = stderr
    rd, = redirect_stderr()
    task = @async write(io, rd)
    try
        ret = f()
        Libc.flush_cstdio()
        flush(stderr)
        return ret
    finally
        Base.close(rd)
        redirect_stderr(old_stderr)
        wait(task)
    end
end

function capture_stdout!(f::Function, io::IO)
    old_stdout = stdout
    rd, = redirect_stdout()
    task = @async write(io, rd)
    try
        ret = f()
        Libc.flush_cstdio()
        flush(stdout)
        return ret
    finally
        Base.close(rd)
        redirect_stdout(old_stdout)
        wait(task)
    end
end

function capture_stderr(f::Function)
    mktemp() do path, io
        redirect_stderr(io) do
            f()
        end
        flush(io)
        s = read(path, String)
    end
end

"""
List the values of `LIKWID_*` environment variables.
"""
function env()
    d = Dict{String, String}()
    d["LIKWID_FORCE"] = ""
    d["LIKWID_NO_ACCESS"] = ""
    d["LIKWID_PIN"] = ""
    d["LIKWID_SILENT"] = ""
    d["LIKWID_SKIP"] = ""
    d["LIKWID_DEBUG"] = ""
    d["LIKWID_FORCE_SETUP"] = ""
    d["LIKWID_IGNORE_CPUSET"] = ""
    d["LIKWID_FILEPATH"] = ""
    d["LIKWID_MODE"] = ""
    d["LIKWID_EVENTS"] = ""
    d["LIKWID_THREADS"] = ""
    d["LIKWID_MPI_CONNECT"] = ""
    for (k, v) in ENV
        startswith(k, "LIKWID") || continue
        d[k] = v
    end
    return d
end

"""
Unset all `LIKWID_*` environment variables (for the current session).
"""
function clearenv()
    for (k, v) in ENV
        startswith(k, "LIKWID") || continue
        ENV[k] = ""
    end
    return nothing
end

"""
Enables the overwriting of counters that are detected to be in-use.
The environment variable is similar to the `-f`/`--force` command line switch for `likwid-perfctr`.
"""
function LIKWID_FORCE end

"""
The execution does not require the access layer (access to hardware counters).
For example, this variable is set by `likwid-topology` or `likwid-pin`.
"""
function LIKWID_NO_ACCESS end

"""
The comma-separated list contains the CPUs the application threads should be pinned to.
Careful, the first CPU in the cpuset must be the last entry because the application is pinned to this CPU per default.
"""
function LIKWID_PIN end

"""
Disable stdout output caused by the library and the scripts.
Some scripts provide the `-q`/`--quiet` command line switch which provides the same functionality.
"""
function LIKWID_SILENT end

"""
Variable content must be a hexmask.
This hexmask describes which threads should be skipped while pinning.
This function is required to avoid pinning the shepherd threads used by some OpenMP and MPI implementations.
The version 4.3.1 introduced an automatic detection of the shepherd threads.
In most cases the detection works, but if not, the hexmask overwrites the automatic detection.
"""
function LIKWID_SKIP end

"""
Verbosity settings for the LIKWID library.
"""
function LIKWID_DEBUG end

"""
Always setup all counters in `setupCounters(...)` and don't respect the previous configuration.
Without this environment variable set, LIKWID writes the configuration to the register only if
the configuration has changed (compared to the last `setupCounters(...)` call)
"""
function LIKWID_FORCE_SETUP end

"""
LIKWID respects the CPUset of the calling process.
If you want to measure/run outside of this CPUset, use this environment variable.
It will not ignore the CPUset but create a new CPUset internally which contains `sysconf(_SC_NPROCESSORS_CONF)` hardware threads.
"""
function LIKWID_IGNORE_CPUSET end

"""
Filepath for the result file of the MarkerAPI.
"""
function LIKWID_FILEPATH end

"""
Access mode for MarkerAPI. `1` is the code for the access daemon.
"""
function LIKWID_MODE end

"""
Event string or performance group name.
Multiple event strings or performance group names can be separated by `|`.
"""
function LIKWID_EVENTS end

"""
The CPUs LIKWID is configured to run on (comma-separated list).
"""
function LIKWID_THREADS end

"""
Connection method for Intel MPI. Default is `ssh`, see option `-r` of `mpdboot` or similar.
"""
function LIKWID_MPI_CONNECT end

LIKWID_FORCE() = get(ENV, "LIKWID_FORCE", "")
LIKWID_NO_ACCESS() = get(ENV, "LIKWID_NO_ACCESS", "")
LIKWID_PIN() = get(ENV, "LIKWID_PIN", "")
LIKWID_SILENT() = get(ENV, "LIKWID_SILENT", "")
LIKWID_SKIP() = get(ENV, "LIKWID_SKIP", "")
LIKWID_DEBUG() = get(ENV, "LIKWID_DEBUG", "")
LIKWID_IGNORE_CPUSET() = get(ENV, "LIKWID_IGNORE_CPUSET", "")
LIKWID_FILEPATH() = get(ENV, "LIKWID_FILEPATH", "")
LIKWID_MODE() = get(ENV, "LIKWID_MODE", "")
LIKWID_EVENTS() = get(ENV, "LIKWID_EVENTS", "")
LIKWID_THREADS() = get(ENV, "LIKWID_THREADS", "")
LIKWID_MPI_CONNECT() = get(ENV, "LIKWID_MPI_CONNECT", "")

LIKWID_FORCE(v::Bool) = ENV["LIKWID_FORCE"] = Int(v);
LIKWID_NO_ACCESS(v::Bool) = ENV["LIKWID_NO_ACCESS"] = Int(v);
LIKWID_PIN(cpustr::AbstractString) = ENV["LIKWID_PIN"] = cpustr;
LIKWID_SILENT(v::Bool) = ENV["LIKWID_SILENT"] = Int(v);
LIKWID_SKIP(hexmask::AbstractString) = ENV["LIKWID_SKIP"] = hexmask;
LIKWID_DEBUG(v::Int) = ENV["LIKWID_DEBUG"] = v;
LIKWID_IGNORE_CPUSET(v::Bool) = ENV["LIKWID_IGNORE_CPUSET"] = Int(v);
LIKWID_FILEPATH(path::AbstractString) = ENV["LIKWID_FILEPATH"] = path;
LIKWID_MODE(mode) = ENV["LIKWID_MODE"] = mode;
LIKWID_EVENTS(eventstr::AbstractString) = ENV["LIKWID_EVENTS"] = eventstr;
LIKWID_THREADS(cpustr::AbstractString) = ENV["LIKWID_THREADS"] = cpustr;
LIKWID_MPI_CONNECT(x::AbstractString) = ENV["LIKWID_MPI_CONNECT"] = x;