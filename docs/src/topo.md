# CPU Topology

The basis functionality of `likwid-topology`.

## Example

```@repl
using LIKWID
topo = LIKWID.get_cpu_topology()
topo.cacheLevels
cpuinfo = LIKWID.get_cpu_info()
```

## Graphical output
Currently, LIKWID.jl doesn't feature a native graphical visualization of the CPU topology. However, it provides a small "wrapper function" around `likwid-topology -g` which should give you an output like this:
```@repl
using LIKWID
LIKWID.print_cpu_topology()
```

## Functions

```@autodocs
Modules = [LIKWID]
Pages   = ["topology.jl"]
```

## Types

```@docs
LIKWID.CpuTopology
LIKWID.CpuInfo
LIKWID.HWThread
LIKWID.CacheLevel
```