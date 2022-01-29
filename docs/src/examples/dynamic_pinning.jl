# # Pinning Julia Threads
# 
# In the following, we demonstrate how to use LIKWID.jl to pin
# Julia threads to specific cores.

#md # !!! note
#md #     Instead of LIKWID's pinning features, we strongly recommend
#md #     to use [ThreadPinning.jl](https://github.com/carstenbauer.eu/ThreadPinning.jl)
#md #     to pin Julia threads to cores!

#md # !!! note
#md #     Note that Julia implements task-based multithreading where `N`
#md #     tasks get mapped onto `M` OS threads (M:N hybrid threading).
#md #     We will pin the Julia (p)threads and not the tasks.
#md #     Depending on how the latter are started/configured, tasks may
#md #     migrate between Julia threads!

# First, we load the packages and standard libraries that we'll use.
using LIKWID
using Base.Threads: nthreads, @threads
using Test, Random

# Note that I have started julia with multiple threads (`julia -t N`), concretely
NT = nthreads()

# Let's find out on which cores are running our Julia threads.
# We will use [`LIKWID.get_processor_id`](@ref) in combination with
# `@threads :static for`, which guarantees that the associated tasks
# are themselves pinned to Julia threads.
coreids = zeros(Int, NT)
@threads :static for i in 1:NT
    coreids[i] = LIKWID.get_processor_id()
end
println("Cores: ", coreids)

# Since querying all core ids is a common operation, we provide [`LIKWID.get_processor_ids`](@ref) which returns all core ids right away.

# To pin a thread to a specific core, there is [`LIKWID.pinthread`](@ref). Using `@threads :static for` like above, we can, for example, pin the `NT` Julia threads to the first `NT` cores:
## core numbering starts with zero
cores_firstNT = 0:NT-1
@threads :static for i in 1:NT
    LIKWID.pinthread(cores_firstNT[i])
end
@test LIKWID.get_processor_ids() == cores_firstNT

# To avoid the explicit for-loop, we can directly use [`LIKWID.pinthreads`](@ref) to pin all Julia threads.

# Let's try a less trivial shuffled mapping
cores_firstNT_shuffeled = shuffle(cores_firstNT)
LIKWID.pinthreads(cores_firstNT_shuffeled)
@test LIKWID.get_processor_ids() == cores_firstNT_shuffeled