julia --project=../.. -E 'push!(LOAD_PATH, "../../.."); using Literate; Literate.markdown("howto_topology.jl", "."; execute=true, repo_root_url="https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/howtos")'
