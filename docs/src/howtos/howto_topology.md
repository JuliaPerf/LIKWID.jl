```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/howtos/howto_topology.jl"
```

# How  CPU / NUMA Topology

The basis functionality of `likwid-topology`.

## CPU

Query CPU topology information:

````julia
using LIKWID # hide
topo = LIKWID.get_cpu_topology()
topo.threadPool
topo.cacheLevels
````

````
3-element Vector{LIKWID.CacheLevel}:
 LIKWID.CacheLevel(1, :data, 8, 64, 64, 32768, 1, 0)
 LIKWID.CacheLevel(2, :unified, 16, 1024, 64, 1048576, 1, 0)
 LIKWID.CacheLevel(3, :unified, 11, 40960, 64, 28835840, 20, 0)
````

Get detailed CPU information:

````julia
cpuinfo = LIKWID.get_cpu_info()
````

````
LIKWID.CpuInfo
├ family: 6
├ model: 85
├ stepping: 4
├ vendor: 0
├ part: 0
├ clock: 0
├ turbo: true
├ osname: Intel(R) Xeon(R) Gold 6148F CPU @ 2.40GHz
├ name: Intel Skylake SP processor
├ short_name: skylakeX
├ features: FP ACPI MMX SSE SSE2 HTT TM RDTSCP MONITOR VMX EIST TM2 SSSE FMA SSE4.1 SSE4.2 AES AVX RDRAND HLE AVX2 RTM AVX512 RDSEED SSE3 
├ isIntel: true
├ architecture: x86_64
├ supportUncore: true
├ supportClientmem: false
├ featureFlags: 4328456191
├ perf_version: 4
├ perf_num_ctr: 8
├ perf_width_ctr: 48
└ perf_num_fixed_ctr: 3
````

Query information about NUMA nodes:

````julia
numa = LIKWID.get_numa_topology()
````

````
LIKWID.NumaTopology
├ numberOfNodes: 2
└ nodes: ... (2 elements)
````

````julia
numa_node = first(numa.nodes)
````

````
LIKWID.NumaNode
├ id: 0
├ totalMemory: 89.48 GB
├ freeMemory: 83.5 GB
├ numberOfProcessors: 20
├ processors: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
├ numberOfDistances: 2
└ distances: [10, 21]
````

## Graphical output
Currently, LIKWID.jl doesn't feature a native graphical visualization of the CPU topology. However, it provides a small "wrapper function" around `likwid-topology -g` which should give you an output like this:

````julia
LIKWID.print_cpu_topology()
````

````
Graphical Topology
********************************************************************************
Socket 0:
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| |   0   | |   1   | |   2   | |   3   | |   4   | |   5   | |   6   | |   7   | |   8   | |   9   | |   10  | |   11  | |   12  | |   13  | |   14  | |   15  | |   16  | |   17  | |   18  | |   19  | |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ |
| |                                                                                                28 MB                                                                                                | |
| +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
Socket 1:
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| |   20  | |   21  | |   22  | |   23  | |   24  | |   25  | |   26  | |   27  | |   28  | |   29  | |   30  | |   31  | |   32  | |   33  | |   34  | |   35  | |   36  | |   37  | |   38  | |   39  | |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | | 32 kB | |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |  1 MB | |
| +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ +-------+ |
| +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ |
| |                                                                                                28 MB                                                                                                | |
| +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+ |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

````

## GPU
Query GPU topology information:

````julia
topo = LIKWID.get_gpu_topology()
````

````
LIKWID.GpuTopology
├ numDevices: 1
└ devices: ... (1 elements)
````

````julia
gpu = first(topo.devices)
````

````
LIKWID.GpuDevice
├ devid: 0
├ numaNode: 1
├ name: NVIDIA GeForce RTX 2080 Ti
├ short_name: nvidia_gpu_cc_ge_7
├ mem: 10.76 GB
├ compute_capability_major: 7
├ compute_capability_minor: 5
├ maxThreadsPerBlock: 1024
├ maxThreadsDim: (1024, 1024, 64)
├ maxGridSize: (2147483647, 65535, 65535)
├ sharedMemPerBlock: 49152
├ totalConstantMemory: 65536
├ simdWidth: 32
├ memPitch: 2147483647
├ regsPerBlock: 0
├ clockRatekHz: 1545000
├ textureAlign: 512
├ surfaceAlign: 512
├ l2Size: 5767168
├ memClockRatekHz: 7000000
├ pciBus: 175
├ pciDev: 0
├ pciDom: 0
├ maxBlockRegs: 65536
├ numMultiProcs: 68
├ maxThreadPerMultiProc: 1024
├ memBusWidth: 352
├ unifiedAddrSpace: true
├ ecc: false
├ asyncEngines: 3
├ mapHostMem: true
└ integrated: false
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
