<div align="center">
  <img width="390px" src="https://raw.githubusercontent.com/JuliaPerf/LIKWID.jl/main/docs/src/assets/logo_with_txt_white_border.png">
</div>

<br>

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://juliaperf.github.io/LIKWID.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliaperf.github.io/LIKWID.jl/stable

[ci-img]: https://git.uni-paderborn.de/pc2-ci/julia/LIKWID-jl/badges/main/pipeline.svg?key_text=CI@PC2
[ci-url]: https://git.uni-paderborn.de/pc2-ci/julia/LIKWID-jl/-/pipelines

[ci-fau-img]: https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/badges/main/pipeline.svg?key_text=NHR@FAU&key_width=70
[ci-fau-url]: https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/-/pipelines

[cov-img]: https://codecov.io/gh/JuliaPerf/LIKWID.jl/branch/main/graph/badge.svg?token=Ze61CbGoO5
[cov-url]: https://codecov.io/gh/JuliaPerf/LIKWID.jl

[lifecycle-img]: https://img.shields.io/badge/lifecycle-maturing-blue.svg

[code-style-img]: https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826
[code-style-url]: https://github.com/SciML/SciMLStyle

[formatcheck-img]: https://github.com/JuliaPerf/LIKWID.jl/actions/workflows/FormatCheck.yml/badge.svg
[formatcheck-url]: https://github.com/JuliaPerf/LIKWID.jl/actions/workflows/FormatCheck.yml

<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
-->

| **Documentation**                                                               | **Build Status**                                                                                |  **Quality**                                                                                |
|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
| [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | [![][ci-img]][ci-url] [![][ci-fau-img]][ci-fau-url] [![][cov-img]][cov-url] | ![][lifecycle-img] |

*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for the performance monitoring and benchmarking suite [LIKWID](https://github.com/RRZE-HPC/likwid).

## Video

Talk (25 min) given at [JuliaCon 2022](https://juliacon.org/2022/).

[![](https://img.youtube.com/vi/l2fTNfEDPC0/0.jpg)](https://youtu.be/l2fTNfEDPC0)

## Installation

Prerequisites:
* You must have `likwid` installed (see the [build & install instructions](https://github.com/RRZE-HPC/likwid#download-build-and-install)).
* **You must be running Linux.** (LIKWID doesn't support macOS or Windows.)

LIKWID.jl is a registered Julia package. Hence, you can simply add it to your Julia environment with the command
```julia
] add LIKWID
```
Make sure that `LD_LIBRARY_PATH` includes the directory that contains the `liblikwid` library (`/usr/local/lib` by default). You can check via 
```bash
echo $LD_LIBRARY_PATH
```
If it doesn't, put the following into your `~/.bashrc`:
```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```
Note that if you are using VSCode a restart might be required to see the changes.

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

function daxpy!(z, a, x, y)
    z .= a .* x .+ y
end
daxpy!(z, a, x, y); # warmup

metrics, events = @perfmon "FLOPS_DP" daxpy!(z, a, x, y); # double-precision floating point ops.
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
