using LIKWID
using Test
using Random

if Threads.nthreads() == 1
    @warn("Running likwid-pin_test.jl with only a single thread!")
end

const likwidpin = `likwid-pin`
const julia = Base.julia_cmd()
const testdir = @__DIR__
const pkgdir = joinpath(@__DIR__, "../..")
exec(cmd::Cmd) = LIKWID._execute_test(cmd)

topo = LIKWID.get_cpu_topology()
ncores = topo.numCoresPerSocket * topo.numSockets
N = Threads.nthreads()

maskstr = LIKWID.pinmask(N)
cores_firstN = string("0-", N - 1)
cores_firstN_shuffled = join(shuffle(0:(N - 1)), ",")
cores_rand = join(shuffle(0:(ncores - 1))[1:N], ",")

# LIKWID.finalize()
# LIKWID.init()

@testset "likwid-pin (CLI)" begin
    @testset "$f" for f in ["test_pin.jl"]
        withenv("OPENBLAS_NUM_THREADS" => 1) do
            # NOTE: Only broken when run via `] test`.
            #       They pass if you only run this file.
            @test_broken exec(`$likwidpin -s $(maskstr) -C $(cores_firstN) -m $julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, f)) $(cores_firstN)`)
            @test_broken exec(`$likwidpin -s $(maskstr) -C $(cores_firstN_shuffled) -m $julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, f)) $(cores_firstN_shuffled)`)
            @test_broken exec(`$likwidpin -s $(maskstr) -C $(cores_rand) -m $julia --project=$(pkgdir) -t$(N) $(joinpath(testdir, f)) $(cores_rand)`)
        end
    end
end
