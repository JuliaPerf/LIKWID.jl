# push!(LOAD_PATH,"../src/")
using Documenter
using CUDA
using LIKWID
using Literate
using DocThemePC2

const src = "https://github.com/JuliaPerf/LIKWID.jl"
const ci = get(ENV, "CI", "") == "true"

# @info "Building Literate.jl documentation"
# cd(@__DIR__) do
#     # Literate.markdown("src/tutorials/first.jl", "src/tutorials/";
#     #     repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
#     # Literate.markdown("src/tutorials/saxpy.jl", "src/tutorials/";
#     #     repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
#     Literate.markdown("src/examples/dynamic_pinning.jl", "src/examples/";
#         repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
#     Literate.markdown("src/examples/perfmon.jl", "src/examples/";
#         repo_root_url = "$src/blob/main/docs") #, codefence = "```@repl 1" => "```")
# end

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
        # "Tutorials" => [
        #     "The Very First Time" => "tutorials/first.md",
        #     "Counting FLOPS: SAXPY" => "tutorials/saxpy_cpu.md",
        #     # "Counting GPU FLOPS: SAXPY" => "tutorials/saxpy_gpu.md",
        # ],
        # "Examples" => [
        #     "Using the Marker API" => "examples/saxpy.md",
        #     "Monitoring performance" => "examples/perfmon.md",
        # ],
        # "How-To Guides" => [
        #     "Pinning Threads" => "howtos/pinning.md",
        # ],
        "References" => [
            "Marker API (CPU)" => "references/marker.md",
            "Marker API (GPU)" => "references/marker_gpu.md",
            "CPU topology" => "references/topo.md",
            "Performance monitoring" => "references/perfmon.md",
            "GPU topology" => "references/topo_gpu.md",
            "NVIDIA monitoring" => "references/nvmon.md",
            "CPU clock timer" => "references/timer.md",
            "CPU temperature" => "references/temperature.md",
            "Power / Energy" => "references/power.md",
            "Affinity" => "references/affinity.md",
            "HPM / Access" => "references/access.md",
            "Miscellaneous" => "references/misc.md",
        ],
        # "CLI Tools" => [
        #     "likwid-pin" => "likwid-pin.md",
        # ],
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