likwid-perfctr -c 0-2 -g FLOPS_DP -m julia --project=. -t3 threads.jl > threads.out 2>&1
# Of one wants to do the pinning with likwid-pin:
# likwid-perfctr -c 0-2 -g FLOPS_DP -m likwid-pin -s 0xfffffffffffffff1 -c 0-2 julia --project=. -t3 threads.jl > threads.out 2>&1
