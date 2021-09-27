# push!(LOAD_PATH,"../src/")
using Documenter, LIKWID

DocMeta.setdocmeta!(LIKWID, :DocTestSetup, :(using LIKWID); recursive=true)
makedocs(
    sitename = "LIKWID.jl",
    authors = "Carsten Bauer",
    modules = [LIKWID],
    doctest = false,
    pages = [
        "LIKWID" => "index.md",
        "Marker API" => [
            "CPU" => "marker.md",
            "GPU" => "marker_gpu.md",
        ],
        "Library" => [
            "CPU / NUMA Topology" => "topo.md",
            "Performance monitoring" => "perfmon.md",
        ],
        "CLI Tools" => [
            "likwid-pin" => "likwid-pin.md",
        ],
    ],
    # assets = ["assets/custom.css", "assets/custom.js"]
)

deploydocs(
    repo = "github.com/JuliaPerf/LIKWID.jl.git",
    devbranch = "main",
    push_preview = false,
    # target = "site",
)