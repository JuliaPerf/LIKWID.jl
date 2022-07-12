<div align="center">
  <img width="390px" src="https://raw.githubusercontent.com/JuliaPerf/LIKWID.jl/main/docs/src/assets/logo_with_txt_white_border.png">
</div>

<br>

[ci-img]: https://git.uni-paderborn.de/pc2-ci/julia/LIKWID-jl/badges/main/pipeline.svg?key_text=CI@PC2
[ci-url]: https://git.uni-paderborn.de/pc2-ci/julia/LIKWID-jl/-/pipelines

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaperf.github.io/LIKWID.jl/dev/)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaperf.github.io/LIKWID.jl/stable/)
[![][ci-img]][ci-url]
[![Build Status](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/badges/main/pipeline.svg?key_text=NHR@FAU&key_width=70)](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/-/pipelines)
[![codecov](https://codecov.io/gh/JuliaPerf/LIKWID.jl/branch/main/graph/badge.svg?token=Ze61CbGoO5)](https://codecov.io/gh/JuliaPerf/LIKWID.jl)
![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)

*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for the performance monitoring and benchmarking suite [LIKWID](https://github.com/RRZE-HPC/likwid).

## Installation

Prerequisites:
* You must have `likwid` installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)).
* **You must be running Linux.** (LIKWID doesn't support macOS or Windows.)

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```

## Documentation

Please check out [the documentation](https://juliaperf.github.io/LIKWID.jl/dev/) to learn how to use LIKWID.jl.

## Example: Performance Monitoring

```julia
using LIKWID

N = 10_000
a = 3.141
x = rand(N)
y = rand(N)
z = zeros(N)

function saxpy!(z, a, x, y)
    z .= a .* x .+ y
end
saxpy!(z, a, x, y); # warmup

metrics, events = @perfmon "FLOPS_DP" saxpy!(z, a, x, y); # double-precision floating point ops.
```

Output:
```
Group: FLOPS_DP
┌───────────────────────────┬──────────┐
│                     Event │ Thread 1 │
├───────────────────────────┼──────────┤
│          ACTUAL_CPU_CLOCK │  73956.0 │
│             MAX_CPU_CLOCK │  51548.0 │
│      RETIRED_INSTRUCTIONS │  10357.0 │
│       CPU_CLOCKS_UNHALTED │  23174.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │  20000.0 │
│                     MERGE │      0.0 │
└───────────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 7.68048e-6 │
│ Runtime unhalted [s] │  3.0188e-5 │
│          Clock [MHz] │     3514.8 │
│                  CPI │    2.23752 │
│         DP [MFLOP/s] │     2604.0 │
└──────────────────────┴────────────┘
```

## Resources

* [LIKWID](https://github.com/RRZE-HPC/likwid) / [LIKWID Performance Tools](https://hpc.fau.de/research/tools/likwid/)
* Most C-bindings have been autogenerated using [Clang.jl](https://github.com/JuliaInterop/Clang.jl)
* [pylikwid](https://github.com/RRZE-HPC/pylikwid): Python wrappers of LIKWID
* Logo by @davibarreira
* The [Erlangen National High Performance Computing Center (NHR@FAU)](https://hpc.fau.de/) supports the project with [CI infrastructure](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/-/pipelines)

## Creators

LIKWID.jl is an effort by the [Paderborn Center for Parallel Computing (PC²)](https://pc2.uni-paderborn.de) and, originally, the [MIT JuliaLab](https://julia.mit.edu/).
