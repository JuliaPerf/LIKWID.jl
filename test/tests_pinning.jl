using LIKWID
using Test
using Random

const N = Threads.nthreads()

if N == 1
    @warn("Running pinning_test.jl with only a single thread!")
end

@testset "Pinning" begin
    println("Before: ", LIKWID.get_processor_ids())
    @test typeof(LIKWID.get_processor_id()) == Int
    @test typeof(LIKWID.pinprocess(0)) == Bool
    @test typeof(LIKWID.pinthread(0)) == Bool

    topo = LIKWID.get_cpu_topology()
    ncores = topo.numSockets * topo.numCoresPerSocket
    cpus_firstN = 0:(N - 1)
    cpus_firstN_shuffeled = shuffle(cpus_firstN)
    cpus_rand = shuffle(0:(ncores - 1))[1:N]

    LIKWID.pinthreads(cpus_firstN)
    println("First N: ", LIKWID.get_processor_ids())
    @test LIKWID.get_processor_ids() == cpus_firstN

    LIKWID.pinthreads(cpus_firstN_shuffeled)
    println("First N (shuffled): ", LIKWID.get_processor_ids())
    @test LIKWID.get_processor_ids() == cpus_firstN_shuffeled

    LIKWID.pinthreads(cpus_rand)
    println("Rand: ", LIKWID.get_processor_ids())
    @test LIKWID.get_processor_ids() == cpus_rand
end
