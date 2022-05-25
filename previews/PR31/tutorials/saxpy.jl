# # Monitoring SAXPY on CPU and GPU
#
# [TODO: Intro]
#
# ## Our computation
# Single-precision (i.e. `Float32`) `a` times `x` plus y (SAXPY):
# $$ z = a * x + y $$
#
# Set the problem size and initialize the vectors
const N = 10_000
const a = 3.141
const x = rand(Float32, N)
const y = rand(Float32, N)
const z = zeros(Float32, N);

# ## CPU
# ### How many FLOPs?
# The multiply and plus operations correspond to one FLOP each and we to `N` of those in total.
2 * N

# ### CPU, tell us how many FLOPs you've performed!
# We measure the FLOPS_SP performance group, in which "SP" stands for "single precision".
using LIKWID
metrics, events = @perfmon "FLOPS_SP" z .= a .* x .+ y;

# Let's look at what we got
metrics
#
events

# In particular, the event "RETIRED_SSE_AVX_FLOPS_ALL" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above
events["RETIRED_SSE_AVX_FLOPS_ALL"] == 2 * N

# ## GPU
# First, we need to make sure that CUDA(.jl) is functional
using CUDA
@assert CUDA.functional()

# If that's the case, we can move our data vectors to the GPU
const xgpu = CuArray(x)
const ygpu = CuArray(y)
const zgpu = CUDA.zeros(N);

# Our saxpy operation can now be readily run on the GPU via
saxpy_gpu!(z, a, x, y) = CUDA.@sync z .= a .* x .+ y

# ### GPU, tell us how many FLOPs you've performed!
using LIKWID
metrics, events = @nvmon "FLOPS_SP" saxpy_gpu!(zgpu, a, xgpu, ygpu)

# Let's look at what we got
metrics
#
events

# [TODO: Check which event actually gives the FLOPs]
# In particular, the event "SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above
# events["SMSP_SASS_THREAD_INST_EXECUTED_OP_FFMA_PRED_ON_SUM"] == 2 * N