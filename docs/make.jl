# push!(LOAD_PATH,"../src/")
using Documenter, LIKWID

makedocs(
    modules = [LIKWID],
    doctest = false,
    sitename = "LIKWID.jl",
    pages = [
        "Introduction" => "index.md",
        "Marker API" => [
            "Introduction" => "marker.md",
        ],
    ],
    # assets = ["assets/custom.css", "assets/custom.js"]
)

deploydocs(
    repo = "github.com/JuliaPerf/LIKWID.jl.git",
    push_preview = true,
    # target = "site",
)