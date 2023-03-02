println("--- :julia: Instantiating project")
using Pkg
Pkg.activate("..")
Pkg.instantiate()
Pkg.activate(".")
Pkg.instantiate()
push!(LOAD_PATH, joinpath(@__DIR__, ".."))
deleteat!(LOAD_PATH, 2)

println("+++ :julia: Building examples")
using LIKWID
using Literate
const src = "https://github.com/JuliaPerf/LIKWID.jl"
const execute = false
cd(@__DIR__) do
    # Literate.markdown("src/examples/dynamic_pinning.jl", "src/examples/";
    # repo_root_url = "$src/blob/main/docs", execute = execute) #, codefence = "```@repl 1" => "```")
    Literate.markdown("src/examples/perfmon.jl", "src/examples/";
                      repo_root_url = "$src/blob/main/docs", execute = execute) #, codefence = "```@repl 1" => "```")
end
