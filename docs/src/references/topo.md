# CPU / NUMA Topology

## Index

```@index
Pages   = ["topo.md"]
Order   = [:function, :type]
```

### Functions


```@docs
LIKWID.init_topology
LIKWID.finalize_topology
LIKWID.get_cpu_topology
LIKWID.get_cpu_info
LIKWID.print_supported_cpus
LIKWID.init_numa
LIKWID.finalize_numa
LIKWID.get_numa_topology
```

### Types

```@docs
LIKWID.CpuTopology
LIKWID.CpuInfo
LIKWID.HWThread
LIKWID.CacheLevel
LIKWID.NumaTopology
LIKWID.NumaNode
```