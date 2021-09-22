# push!(LOAD_PATH,"../src/")
using Documenter, LIKWID

makedocs(
    modules = [LIKWID],
    doctest = false,
    sitename = "LIKWID.jl",
    pages = [
        "LIKWID" => "index.md",
        "Marker API" => "marker.md",
        "Library" => [
            "CPU / NUMA Topology" => "topo.md",
            "Performance monitoring" => "perfmon.md",
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