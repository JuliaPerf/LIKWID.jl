# perfmon.jl
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

metrics, results = @perfmon "FLOPS_DP" begin
    for _ in 1:100
        mul!(C, A, B)
    end
end

println("Metrics:")
display(metrics)
println()
println("Events:")
display(results)