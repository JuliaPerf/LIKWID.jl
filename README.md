LIKWID.jl
=========

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-blue.svg)
[![Build Status](https://github.com/JuliaPerf/LIKWID.jl/workflows/CI/badge.svg)](https://github.com/JuliaPerf/LIKWID.jl/actions)
[![Build Status](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/badges/main/pipeline.svg?key_text=CI+at+NHR@FAU&key_width=130)](https://gitlab.rrze.fau.de/ub55yzis/LIKWID.jl/-/pipelines)
[![codecov](https://codecov.io/gh/JuliaPerf/LIKWID.jl/branch/main/graph/badge.svg?token=Ze61CbGoO5)](https://codecov.io/gh/JuliaPerf/LIKWID.jl)

*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for [LIKWID](https://github.com/RRZE-HPC/likwid).

Installation
------------

First install `likwid` following https://github.com/RRZE-HPC/likwid#download-build-and-install,
and then use the Julia package manger to install `]add LIKWID`.

Example
-------

```julia
using LIKWID
using LinearAlgebra

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

LIKWID.Marker.startregion("matmul")
mul!(C, A, B)
LIKWID.Marker.stopregion("matmul")
```

Then run `likwid-perfctr` with `--marker` like: `likwid-perfctr ... --marker julia ...`.

License
-------

LIKWID.jl is licensed under the [MIT license](LICENSE).
