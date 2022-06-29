# Marker API (CPU)

## Example

(See [https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr](https://github.com/JuliaPerf/LIKWID.jl/tree/main/examples/perfctr).)

```julia
# perfctr.jl
using LIKWID
using LinearAlgebra

Marker.init()

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

@marker for _ in 1:100
    mul!(C, A, B)
end

Marker.close()
```

### Manual

```julia
# perfctr.jl
using LIKWID
using LinearAlgebra

Marker.init()

A = rand(128, 64)
B = rand(64, 128)
C = zeros(128, 128)

Marker.registerregion("matmul") # optional
Marker.startregion("matmul")
for _ in 1:100
    mul!(C, A, B)
end
Marker.stopregion("matmul")

Marker.close()
```

## Index

```@index
Pages   = ["marker.md"]
Order   = [:function, :macro, :type]
```

### API

```@autodocs
Modules = [Marker]
```
