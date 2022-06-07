# # Counting FLOPS: SAXPY
#
# [TODO: Intro]
#
# 
Threads.nthreads()
#
# ## Single-threaded
# ### Our computation
# Single-precision (i.e. `Float32`) `a` times `x` plus y (SAXPY):
# $$ z = a \cdot x + y $$
#
# Set the problem size and initialize the vectors
const N = 10_000
const a = 3.141
const x = rand(Float32, N)
const y = rand(Float32, N)
const z = zeros(Float32, N);

# #### How many FLOPS?
# The multiply and plus operations correspond to one FLOP each and we to `N` of those in total.
2 * N

# ### CPU, tell us how many FLOPS you've performed!
# We measure the FLOPS_SP performance group, in which "SP" stands for "single precision".
using LIKWID
metrics, events = @perfmon "FLOPS_SP" begin
    z .= a .* x .+ y
end;
# Note that while the computation itself is single-threaded `@perfmon` automatically monitors all Julia threads and the returned `metrics` and `events` are vectors.
metrics
#
events
# Extracting the results for the relevant event "RETIRED\_SSE\_AVX\_FLOPS\_ALL" for all threads gives us.
FLOPS_per_thread = getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL")
# This matches our expectation from above, i.e.
FLOPS_per_thread[1] == 2 * N

# [TODO: make info box] As an alternative to monitoring all Julia threads, we could have used the functional form `perfmon` to only consider the main thread.
LIKWID.pinthread(0)
metrics, events = perfmon("FLOPS_SP"; cpuids=[0], autopin=false) do
    z .= a .* x .+ y
end;

# ## Multi-threaded
#
using LIKWID
metrics, events = @perfmon "FLOPS_SP" begin
    Threads.@threads for i in eachindex(x, y, z)
        z[i] = a * x[i] + y[i]
    end
end;
#
FLOPS_per_thread = getindex.(events, "RETIRED_SSE_AVX_FLOPS_ALL")
# Note that `sum(FLOPS_per_thread) > N` since the multithreading itself has some overhead.

# ## GPU
# First, we need to make sure that CUDA(.jl) is functional
using CUDA
@assert CUDA.functional()
#
# Then, we can move our vector data to the GPU
const xgpu = CuArray(x)
const ygpu = CuArray(y)
const zgpu = CUDA.zeros(N);

# To run SAXPY on the GPU we can still use broadcasting but must prefix it with `CUDA.@sync` to ensure that the GPU has finished the computation before return.
saxpy_gpu!(z, a, x, y) = CUDA.@sync z .= a .* x .+ y

# ### GPU, tell us how many FLOPs you've performed!
using LIKWID
metrics, events = @nvmon "FLOPS_SP" saxpy_gpu!(zgpu, a, xgpu, ygpu);

# Let's look at what we got
metrics
#
events

# [TODO: Check which event actually gives the FLOPs]
# In particular, the event "SMSP\_SASS\_THREAD\_INST\_EXECUTED\_OP\_FFMA\_PRED\_ON\_SUM" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above
events["SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM"] == 2 * N