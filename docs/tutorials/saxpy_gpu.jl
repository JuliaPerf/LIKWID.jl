# # Monitoring SAXPY on CPU and GPU
#
# [TODO: Intro]
#
# ## Our computation
# Single-precision (i.e. `Float32`) `a` times `x` plus y (SAXPY):
# $$ z = a \cdot x + y $$
#
# First, we need to make sure that CUDA(.jl) is functional
using CUDA
@assert CUDA.functional()
#
# Set the problem size and initialize the vectors
const N = 10_000
const a = 3.141
const xgpu = CuArray(x)
const ygpu = CuArray(y)
const zgpu = CUDA.zeros(N);

# Our saxpy operation can now be readily run on the GPU via
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