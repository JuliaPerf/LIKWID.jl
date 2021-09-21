# CPU Topology

The basis functionality of `likwid-topology`.

## Example

```@repl
using LIKWID
topo = LIKWID.get_cpu_topology()
topo.cacheLevels
```