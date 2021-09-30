# LIKWID - Like I Knew What I'm Doing

LIKWID.jl is a Julia wrapper for the performance monitoring and benchmarking suite [LIKWID](https://github.com/RRZE-HPC/likwid).

## Installation

Prerequisites:
* You must have `likwid` installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)).
* **You must be running Linux.** (LIKWID doesn't support macOS or Windows.)

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```

## Supported CPUs

```@setup likwid
using LIKWID
```

```@repl likwid
LIKWID.print_supported_cpus()
LIKWID.print_supported_cpus(; cprint=false) # hide
```