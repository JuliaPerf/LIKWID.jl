# LIKWID - Like I Knew What I'm Doing

[LIKWID.jl](https://github.com/JuliaPerf/LIKWID.jl) is a Julia wrapper for the 
performance monitoring and benchmarking suite [LIKWID](https://github.com/RRZE-HPC/likwid). It is an effort by the [Paderborn Center for Parallel Computing (PC²)](https://pc2.uni-paderborn.de) and, originally, the [MIT JuliaLab](https://julia.mit.edu/).

## Installation

Prerequisites:
* You must have `likwid` installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)).
* **You must be running Linux.** (LIKWID doesn't support macOS or Windows.)

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```

## LIKWID.jl vs LinuxPerf.jl

As per default (and recommendation) LIKWID(.jl) uses a custom [access daemon](https://github.com/RRZE-HPC/likwid/wiki/likwid-accessD) to monitor hardware performance counters. In contrast, [LinuxPerf.jl](https://github.com/JuliaPerf/LinuxPerf.jl) uses Linux's [`perf_events`](https://www.kernel.org/doc/html/latest/admin-guide/perf-security.html). However, it is possible to make LIKWID use `perf_events` as an alternative (inferior) backend. See [here](https://github.com/RRZE-HPC/likwid/wiki/TutorialLikwidPerf) for more information.

## Supported CPUs

```@setup likwid
using LIKWID
```

```@repl likwid
LIKWID.print_supported_cpus()
Libc.flush_cstdio() # hide
```
