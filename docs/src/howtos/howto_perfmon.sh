julia --project=../.. -t 10 -E 'push!(LOAD_PATH, "../../.."); using Literate; Literate.markdown("howto_perfmon.jl", "."; execute=true)'