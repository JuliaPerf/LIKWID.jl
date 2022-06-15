julia --project=../.. -t 3 -E 'push!(LOAD_PATH, "../../.."); using Literate; Literate.markdown("howto_marker_cpu_dynamic.jl", "."; execute=true)'
