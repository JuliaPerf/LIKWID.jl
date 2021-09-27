println("--- :julia: Instantiating project")
using Pkg
Pkg.instantiate()
Pkg.activate("docs")
Pkg.instantiate()
push!(LOAD_PATH, @__DIR__)
println("+++ :julia: Building documentation")
include("docs/make.jl")'