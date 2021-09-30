# push!(LOAD_PATH,"../src/")
using Documenter
using CUDA
using LIKWID

const ci = get(ENV, "CI", "") == "true"

DocMeta.setdocmeta!(LIKWID, :DocTestSetup, :(using LIKWID, CUDA); recursive=true)
makedocs(
    sitename = "LIKWID.jl",
    authors = "Carsten Bauer",
    modules = [LIKWID],
    doctest = ci,
    pages = [
        "LIKWID" => "index.md",
        "Marker API" => [
            "CPU" => "marker.md",
            "GPU" => "marker_gpu.md",
        ],
        "Library" => [
            "CPU / NUMA Topology" => "topo.md",
            "Performance monitoring" => "perfmon.md",
            "GPU Topology" => "topo_gpu.md",
            "NVIDIA monitoring" => "nvmon.md",
            "CPU clock timer" => "timer.md",
            "CPU temperature" => "temperature.md",
            "Power / Energy" => "power.md",
            "Affinity" => "affinity.md",
            "HPM / Access" => "access.md",
            "Misc" => "misc.md",
        ],
        "CLI Tools" => [
            "likwid-pin" => "likwid-pin.md",
        ],
        "Examples" => [
            "SAXPY CPU+GPU" => "examples/saxpy.md",
        ],
    ],
    # assets = ["assets/custom.css", "assets/custom.js"]
)

if ci
    deploydocs(
        repo = "github.com/JuliaPerf/LIKWID.jl.git",
        devbranch = "main",
        push_preview = false,
        # target = "site",
    )
end