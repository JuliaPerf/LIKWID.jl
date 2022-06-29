using LIKWID
using Test

const N = Threads.nthreads()

if N == 1
    @warn("Running perfmon_marker_test.jl with only a single thread!")
end

function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops
        c = a * b + c
    end
    return c
end

result = @perfmon_marker "FLOPS_DP" begin
    NUM_FLOPS = 100_000_000
    a = 1.8
    b = 3.2
    c = 1.0
    Threads.@threads :static for tid in 1:N
        @marker "calc_flops" c = do_flops(c, a, b, NUM_FLOPS)
        sin(b) # not monitored
        @marker "exponential" exp(a)
    end
end
@test isnothing(result)
# TODO: Better test.... Ideally we would test the printed output.

result2 = @perfmon_marker ["FLOPS_DP", "CPI"] begin
    @marker "exponential" exp(3.141)
end
@test isnothing(result2)
# TODO: Better test.... Ideally we would test the printed output.

# LIKWID.finalize()
