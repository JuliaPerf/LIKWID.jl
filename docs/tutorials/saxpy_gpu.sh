julia --project=../.. -t1 -E 'push!(LOAD_PATH, "../../.."); using Literate; Literate.markdown("saxpy_gpu.jl", "."; execute=true)'