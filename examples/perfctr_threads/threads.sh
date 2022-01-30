# likwid-perfctr -c 0-2 -g FLOPS_SP -m julia --project=. -t3 threads.jl > threads.out
likwid-perfctr -c 0-2 -g FLOPS_SP -m likwid-pin -s 0xfffffffffffffff1 -c 0-2 julia --project=. -t3 threads.jl > threads.out
