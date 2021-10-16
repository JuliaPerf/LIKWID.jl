# push!(LOAD_PATH,"../src/")
using Documenter
using CUDA
using LIKWID
using Literate

const src = "https://github.com/JuliaPerf/LIKWID.jl"
const ci = get(ENV, "CI", "") == "true"

@info "Building Literate.jl documentation"
cd(@__DIR__) do
    Literate.markdown("src/examples/dynamic_pinning.jl", "src/examples/";
                        repo_root_url="$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
    Literate.markdown("src/examples/perfmon.jl", "src/examples/";
                        repo_root_url="$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
end

@info "Generating Documenter.jl site"
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
            "CPU topology" => "topo.md",
            "Performance monitoring" => "perfmon.md",
            "GPU topology" => "topo_gpu.md",
            "NVIDIA monitoring" => "nvmon.md",
            "CPU clock timer" => "timer.md",
            "CPU temperature" => "temperature.md",
            "Power / Energy" => "power.md",
            "Affinity" => "affinity.md",
            "HPM / Access" => "access.md",
            "Miscellaneous" => "misc.md",
        ],
        "CLI Tools" => [
            "likwid-pin" => "likwid-pin.md",
        ],
        "Examples" => [
            "SAXPY CPU+GPU" => "examples/saxpy.md",
            "Pinning Julia threads" => "examples/dynamic_pinning.md",
            "Monitoring performance" => "examples/perfmon.md",
        ],
    ],
    # assets = ["assets/custom.css", "assets/custom.js"]
)

if ci
    @info "Deploying documentation to GitHub"
    deploydocs(
        repo = "github.com/JuliaPerf/LIKWID.jl.git",
        devbranch = "main",
        push_preview = true,
        # target = "site",
    )
end