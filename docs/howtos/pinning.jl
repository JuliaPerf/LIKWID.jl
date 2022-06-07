# # How to pin Julia threads

# Below, we demonstrate how to use LIKWID.jl to pin
# Julia threads to specific cores. However, before we do that, let us note two things.

# !!! note
#     Instead of LIKWID's pinning features, we generally strongly recommend
#     to use [ThreadPinning.jl](https://github.com/carstenbauer.eu/ThreadPinning.jl)
#     to pin Julia threads to cores, as it provides many more options and visualizations!

# !!! note
#     Note that Julia implements task-based multithreading where `N`
#     tasks get mapped onto `M` OS threads (M:N hybrid threading).
#     We will pin the Julia (p)threads and not the tasks.
#     Depending on how the latter are started/configured, tasks may
#     migrate between Julia threads!

# First, make sure to start Julia in multithreaded mode, i.e. `julia -t N`
# where `N` is the desired number of Julia threads (below I'll use `N=10`).
N = Threads.nthreads()

# Let's find out on which cores the Julia threads are currently running (before we've pinned them).
# We will use [`LIKWID.get_processor_id`](@ref) in combination with
# `Threads.@threads :static for`, which guarantees that the *tasks* associated with different instances of the loop body
# get executed on different Julia threads (ThreadPinning.jl provides `@tspawnat` as a nice(r) alternative).
using LIKWID
coreids = zeros(Int, N)
Threads.@threads :static for i in 1:N
    coreids[i] = LIKWID.get_processor_id()
end
println("Cores: ", coreids)

# Since querying all core ids is a common operation, we provide [`LIKWID.get_processor_ids`](@ref) which returns all core ids right away.
println("Cores: ", LIKWID.get_processor_ids())

# To pin a thread to a specific core, there is [`LIKWID.pinthread`](@ref).
# Using `Threads.@threads :static for` like above, we can, for example, pin the `N` Julia threads to the first `N` cores.
cores_firstN = 0:N-1
Threads.@threads :static for i in 1:N
    LIKWID.pinthread(cores_firstN[i])
end
println("Cores: ", LIKWID.get_processor_ids())

# To avoid the explicit for-loop, we can directly use [`LIKWID.pinthreads`](@ref) to pin all Julia threads.
# Let's realize a less trivial shuffled mapping.
using Random
cores_firstN_shuffeled = shuffle(cores_firstN)
LIKWID.pinthreads(cores_firstN_shuffeled)
println("Cores: ", LIKWID.get_processor_ids())
LIKWID.get_processor_ids() == cores_firstN_shuffeled
