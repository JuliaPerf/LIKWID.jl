# push!(LOAD_PATH,"../src/")
using Documenter, LIKWID

makedocs(
    modules = [LIKWID],
    doctest = false,
    sitename = "LIKWID.jl",
    pages = [
        "Like I Knew What I am Doing" => "index.md",
        "Marker API" => "marker.md",
        "Sections" => [
            "CPU Topology" => "topo.md",
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