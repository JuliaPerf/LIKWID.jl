# CPU / NUMA Topology

The basis functionality of `likwid-topology`.

## Example

Query CPU topology information:
```@repl
using LIKWID
topo = LIKWID.get_cpu_topology()
topo.threadPool
topo.cacheLevels
```

Get detailed CPU information:
```@repl
using LIKWID
cpuinfo = LIKWID.get_cpu_info()
```

Query information about NUMA nodes:

```@repl
using LIKWID
numa = LIKWID.get_numa_topology()
numa.nodes
numa_node = first(numa.nodes)
```

## Graphical output
Currently, LIKWID.jl doesn't feature a native graphical visualization of the CPU topology. However, it provides a small "wrapper function" around `likwid-topology -g` which should give you an output like this:
```@repl
using LIKWID
LIKWID.print_cpu_topology()
```

## Functions

```@docs
LIKWID.init_topology()
LIKWID.finalize_topology()
LIKWID.get_cpu_topology()
LIKWID.get_cpu_info()
LIKWID.print_supported_cpus()
LIKWID.init_numa()
LIKWID.finalize_numa()
LIKWID.get_numa_topology()
```

## Types

```@docs
LIKWID.CpuTopology
LIKWID.CpuInfo
LIKWID.HWThread
LIKWID.CacheLevel
LIKWID.NumaTopology
LIKWID.NumaNode
```

## Supported CPUs

```@repl
using LIKWID; LIKWID.print_supported_cpus()
LIKWID.print_supported_cpus(; cprint=false) # hide
```