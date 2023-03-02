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
        @time @safetestset "Topology" begin include("topology_test.jl") end
        @time @safetestset "NUMA" begin include("numa_test.jl") end
        @time @safetestset "Affinity" begin include("affinity_test.jl") end
        @time @safetestset "Timer" begin include("timer_test.jl") end
        @time @safetestset "Configuration" begin include("configuration_test.jl") end
        @time @safetestset "Misc" begin include("misc_test.jl") end
    end

    if GROUP == "All" || GROUP == "CPU" || GROUP == "PerfMon"
        @time @safetestset "PerfMon" begin include("perfmon_test.jl") end
        @time @safetestset "PerfMon + Marker API CPU" begin include("perfmon_marker_test.jl") end
    end
    if GROUP == "All" || GROUP == "CPU" || GROUP == "Pinning"
        @time @safetestset "Pinning" begin include("pinning_test.jl") end
    end

    if GROUP == "All" || GROUP == "CPU" || GROUP == "Daemon"
        # requires LIKWID access daemon
        @time @safetestset "Thermal" begin include("thermal_test.jl") end
        @time @safetestset "Power" begin include("power_test.jl") end
        @time @safetestset "Access" begin include("access_test.jl") end
    end

    # CLI
    if GROUP == "All" || GROUP == "CPU" || GROUP == "CLI"
        @time @safetestset "Marker API CPU (CLI)" begin include("marker_cpu_cli/marker_cpu_cli_test.jl") end
        @time @safetestset "Marker File Reader (CLI)" begin include("markerfile/markerfile_cli_test.jl") end
        # @time @safetestset "likwid-pin (CLI)" begin
        #     include("likwid-pin/likwid-pin_test.jl")
        # end
    end

    if GROUP == "All" || GROUP == "GPU"
        @time @safetestset "Topology (GPU)" begin include("gpu/topology_gpu_test.jl") end
        @time @safetestset "NvMon (GPU)" begin include("gpu/nvmon_test.jl") end
        @time @safetestset "Marker API GPU (CLI)" begin include("gpu/marker_gpu_cli/marker_gpu_cli_test.jl") end
    end
end
