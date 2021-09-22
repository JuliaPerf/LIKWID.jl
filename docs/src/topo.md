# CPU Topology

The basis functionality of `likwid-topology`.

## Example

```@repl
using LIKWID
topo = LIKWID.get_cpu_topology()
topo.cacheLevels
```

## Graphical output
Currently, LIKWID.jl doesn't feature a native graphical visualization of the CPU topology. However, it provides a small "wrapper function" around `likwid-topology -g` which should give you an output like this:
```
LIKWID.print_cpu_topology()
```

## All Functions

```@autodocs
Modules = [LIKWID]
Pages   = ["topology.jl"]
```