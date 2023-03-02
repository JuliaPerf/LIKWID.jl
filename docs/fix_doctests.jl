println("--- :julia: Instantiating project")
using Pkg
Pkg.activate("..")
Pkg.instantiate()
Pkg.activate(".")
Pkg.instantiate()
push!(LOAD_PATH, joinpath(@__DIR__, ".."))
println("+++ :julia: Fixing Doctests")
using Documenter
using LIKWID
DocMeta.setdocmeta!(LIKWID, :DocTestSetup, :(using LIKWID); recursive = true)
doctest(LIKWID, fix = true)
