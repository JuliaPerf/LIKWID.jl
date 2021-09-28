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
            "NVIDIA monitoring" => "nvmon.md",
            "CPU clock timer" => "timer.md",
            "Affinity" => "affinity.md",
        ],
        "CLI Tools" => [
            "likwid-pin" => "likwid-pin.md",
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