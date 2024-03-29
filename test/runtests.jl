using SafeTestsets
using LIKWID
using CUDA
using Libdl

const GROUP = get(ENV, "GROUP", "All") # All, GPU, CPU
@info("GROUP=$GROUP")

if GROUP == "All" || GROUP == "CPU"
    if Threads.nthreads() == 1
        error("LIKWID test suite must be run in multithreaded mode, i.e. `julia -t N`.")
    end
end

if GROUP == "All" || GROUP == "GPU"
    # Can GPU tests be run?
    # check if CUDA is available and functional
    hascuda = CUDA.functional()
    if !hascuda
        @warn("CUDA isn't functional!")
        if false # only turn on for debugging
            # debug information
            @show Libdl.find_library("libcuda")
            @show filter(contains("cuda"), lowercase.(Libdl.dllist()))
            try
                @info("CUDA.versioninfo():")
                CUDA.versioninfo()
                @info("Successful!")
            catch ex
                @warn("Unsuccessful!")
                println(ex)
                println()
            end
        end
    end
    # check if LIKWID has been compiled with NVIDIA GPU support
    const haslikwidgpu = LIKWID.gpusupport()
    if !haslikwidgpu
        @warn("LIKWID doesn't seem to have been compiled with GPU support!")
    end
    if haslikwidgpu && hascuda
        @info("GPU setup seems to look good.")
    else
        error("Cant test GROUP $GROUP because GPU support isn't setup properly. Either fix it or choose GROUP=CPU to only run CPU tests.")
    end
end

@time begin
    if GROUP == "All" || GROUP == "CPU"
        @time @safetestset "Topology" begin include("tests_topology.jl") end
        @time @safetestset "NUMA" begin include("tests_numa.jl") end
        @time @safetestset "Affinity" begin include("tests_affinity.jl") end
        @time @safetestset "Timer" begin include("tests_timer.jl") end
        @time @safetestset "Configuration" begin include("tests_configuration.jl") end
        @time @safetestset "Misc" begin include("tests_misc.jl") end
    end

    if GROUP == "All" || GROUP == "CPU" || GROUP == "PerfMon"
        @time @safetestset "PerfMon" begin include("tests_perfmon.jl") end
        @time @safetestset "PerfMon + Marker API CPU" begin include("tests_perfmon_marker.jl") end
    end
    if GROUP == "All" || GROUP == "CPU" || GROUP == "Pinning"
        @time @safetestset "Pinning" begin include("tests_pinning.jl") end
    end

    if GROUP == "All" || GROUP == "CPU" || GROUP == "Daemon"
        # requires LIKWID access daemon
        @time @safetestset "Thermal" begin include("tests_thermal.jl") end
        @time @safetestset "Power" begin include("tests_power.jl") end
        @time @safetestset "Access" begin include("tests_access.jl") end
    end

    # CLI
    if GROUP == "All" || GROUP == "CPU" || GROUP == "CLI"
        @time @safetestset "Marker API CPU (CLI)" begin include("marker_cpu_cli/tests_marker_cpu_cli.jl") end
        @time @safetestset "Marker File Reader (CLI)" begin include("markerfile/tests_markerfile_cli.jl") end
        # @time @safetestset "likwid-pin (CLI)" begin
        #     include("likwid-pin/likwid-pin.jl")
        # end
    end

    if GROUP == "All" || GROUP == "GPU"
        @time @safetestset "Topology (GPU)" begin include("gpu/tests_topology_gpu.jl") end
        @time @safetestset "NvMon (GPU)" begin include("gpu/tests_nvmon.jl") end
        @time @safetestset "Marker API GPU (CLI)" begin include("gpu/marker_gpu_cli/tests_marker_gpu_cli.jl") end
    end
end
