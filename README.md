LIKWID.jl
=========
*Like I Knew What I am Doing*

LIKWID.jl is a Julia wrapper for [LIKWID](https://github.com/RRZE-HPC/likwid).

Installation
------------

First install `likwid` following https://github.com/RRZE-HPC/likwid#download-build-and-install,
and then use the Julia package manger to install `]add https://github.com/JuliaPerf/LIKWID.jl`.

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

License
-------

LIKWID.jl is licensed under the [MIT license](LICENSE).