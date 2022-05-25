# push!(LOAD_PATH,"../src/")
using Documenter
using CUDA
using LIKWID
using Literate
using DocThemePC2

const src = "https://github.com/JuliaPerf/LIKWID.jl"
const ci = get(ENV, "CI", "") == "true"

@info "Building Literate.jl documentation"
cd(@__DIR__) do
    Literate.markdown("src/tutorials/first.jl", "src/tutorials/";
        repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
    Literate.markdown("src/examples/dynamic_pinning.jl", "src/examples/";
        repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
    Literate.markdown("src/examples/perfmon.jl", "src/examples/";
        repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
end

@info "Installing DocThemePC2"
DocThemePC2.install(@__DIR__)

@info "Generating Documenter.jl site"
DocMeta.setdocmeta!(LIKWID, :DocTestSetup, :(using LIKWID, CUDA); recursive = true)
makedocs(
    sitename="LIKWID.jl",
    authors="Carsten Bauer",
    modules=[LIKWID],
    doctest=ci,
    pages=[
        "LIKWID" => "index.md",
        "Tutorials" => [
            "The very first time" => "tutorials/first.md",
        ],
        "Examples" => [
            "Using the Marker API" => "examples/saxpy.md",
            "Monitoring performance" => "examples/perfmon.md",
            "Thread Pinning" => "examples/dynamic_pinning.md",
        ],
        "Library" => [
            "Marker API (CPU)" => "marker.md",
            "Marker API (GPU)" => "marker_gpu.md",
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
    ],
    # assets = ["assets/custom.css", "assets/custom.js"]
    repo="https://github.com/JuliaPerf/LIKWID.jl/blob/{commit}{path}#{line}",
    format=Documenter.HTML(; collapselevel=1),#, assets = ["assets/favicon.ico"])
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