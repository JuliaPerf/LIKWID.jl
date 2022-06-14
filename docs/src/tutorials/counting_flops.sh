julia --project=../.. -t4 -E 'push!(LOAD_PATH, "../../.."); using Literate; Literate.markdown("counting_flops.jl", "."; execute=true, documenter=true)'
