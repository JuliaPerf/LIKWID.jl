# # How  CPU / NUMA Topology
#
# The basis functionality of `likwid-topology`.
#
# ## CPU
#
# Query CPU topology information:
using LIKWID # hide
topo = LIKWID.get_cpu_topology()
topo.threadPool
topo.cacheLevels

# Get detailed CPU information:
cpuinfo = LIKWID.get_cpu_info()

# Query information about NUMA nodes:
numa = LIKWID.get_numa_topology()
numa.nodes
numa_node = first(numa.nodes)

# ## Graphical output
# Currently, LIKWID.jl doesn't feature a native graphical visualization of the CPU topology. However, it provides a small "wrapper function" around `likwid-topology -g` which should give you an output like this:
LIKWID.print_cpu_topology()

#src ## GPU
#src 
#src Query GPU topology information:
#src topo = LIKWID.get_gpu_topology()
#src topo.devices
#src gpu = first(topo.devices)
