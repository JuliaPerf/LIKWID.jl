using LIKWID
using Base.Threads
using Test

if length(ARGS) < 1
    @info("test_pin.jl: No cpustr provided to `test_pin.jl`. Assuming first N cores.")
    cores = 0:nthreads()-1
else
    cpustr = ARGS[1]
    if contains(cpustr, "-")
        s = split(cpustr, "-")
        start = parse(Int, s[1])
        stop = parse(Int, s[2])
        cores = start:stop
    else
        # assume explicit list of cores, e.g. "0,4,2,3,12,1"
        cores = parse.(Int, split(cpustr, ","))
    end
end

threadids = zeros(Int, nthreads())
procids = zeros(Int, nthreads())
procids_glibc = zeros(Int, nthreads())
@threads for i in 1:nthreads()
    threadids[i] = threadid()
    procids[i] = LIKWID.get_processor_id()
    procids_glibc[i] = LIKWID.get_processor_id_glibc()
end

@test threadids == 1:nthreads()
@test procids == procids_glibc == cores