# # Counting FLOPs
#
# [TODO: Intro]
#
# ## Our computation
vecadd(a, b) = a .+ b
# Example: Perform `vecadd`
vecadd([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])

# ## How many FLOPs does the CPU core perfom?
# We expect the CPU to perform `N` additions, one for each element of the vectors.

# ## CPU, tell us how many FLOPs you've performed!
# Set the problem size and initialize the vectors
const N = 10_000
const a = rand(N)
const b = rand(N);
# We measure the FLOPS_DP performance group, in which "DP" stands for "double precision".
using LIKWID
metrics, events = @perfmon "FLOPS_DP" vecadd(a, b);

# Let's look at what we got
metrics
#
events

# In particular, the event "RETIRED\_SSE\_AVX\_FLOPS\_ALL" is the relevant one here and gives us the number of performed FLOPs. Note that it matches our expectation above
events["RETIRED_SSE_AVX_FLOPS_ALL"] == N

# Feel free to play around and try monitoring other performance groups. To see which ones are supported on your system you can use [`PerfMon.supported_groups()`](@ref)
PerfMon.supported_groups()