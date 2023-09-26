# push!(LOAD_PATH,"../src/")
using Documenter
using CUDA
using LIKWID
using Literate

const src = "https://github.com/JuliaPerf/LIKWID.jl"
const ci = get(ENV, "CI", "") == "true"
const deploy = get(ENV, "DEPLOYDOCS", "") == "true"

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

@info "Generating Documenter.jl site"
#DocMeta.setdocmeta!(LIKWID, :DocTestSetup, :(using LIKWID, CUDA); recursive = true)
makedocs(sitename = "LIKWID.jl",
         authors = "Carsten Bauer",
         modules = [LIKWID],
         doctest = false, #ci
         warnonly = true,
         pages = [
             "LIKWID" => "index.md",
             "Tutorials" => [
                 "Counting FLOPs" => "tutorials/counting_flops.md",
             ],
             "How-To Guides" => [
                 "Performance Monitoring" => "howtos/howto_perfmon.md",
                 "Pinning Julia Threads" => "howtos/howto_pinning.md",
                 "Marker API" => "howtos/howto_marker.md",
                 "Marker API: Dynamic Usage" => "howtos/howto_marker_dynamic.md",
                 "System Topology" => "howtos/howto_topology.md",
             ],
             # "Examples" => [
             #     "Using the Marker API" => "examples/saxpy.md",
             #     "Monitoring performance" => "examples/perfmon.md",
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
         ],
         # assets = ["assets/custom.css", "assets/custom.js"]
         repo = "https://github.com/JuliaPerf/LIKWID.jl/blob/{commit}{path}#{line}",
         format = Documenter.HTML(repolink="https://github.com/JuliaPerf/LIKWID.jl"; collapselevel = 1))

if ci || deploy
    @info "Deploying documentation to GitHub"
    deploydocs(repo = "github.com/JuliaPerf/LIKWID.jl.git",
               devbranch = "main",
               push_preview = true
               # target = "site",
               )
end
