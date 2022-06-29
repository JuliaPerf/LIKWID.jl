```@setup likwid
using LIKWID
```

# Affinity

## Example

Query affinity domain information:
```
julia> aff = LIKWID.get_affinity()
LIKWID.AffinityDomains
├ numberOfSocketDomains: 2
├ numberOfNumaDomains: 2
├ numberOfProcessorsPerSocket: 24
├ numberOfCacheDomains: 2
├ numberOfCoresPerCache: 12
├ numberOfProcessorsPerCache: 24
├ numberOfAffinityDomains: 9
└ domains: ... (9 elements)

julia> aff.domains
9-element Vector{LIKWID.AffinityDomain}:
 LIKWID.AffinityDomain("N", 48, 24, [0, 24, 1, 25, 2, 26, 3, 27, 4, 28  …  19, 43, 20, 44, 21, 45, 22, 46, 23, 47])
 LIKWID.AffinityDomain("S0", 24, 12, [0, 24, 1, 25, 2, 26, 3, 27, 4, 28  …  7, 31, 8, 32, 9, 33, 10, 34, 11, 35])
 LIKWID.AffinityDomain("S1", 24, 12, [12, 36, 13, 37, 14, 38, 15, 39, 16, 40  …  19, 43, 20, 44, 21, 45, 22, 46, 23, 47])
 LIKWID.AffinityDomain("D0", 24, 12, [0, 24, 1, 25, 2, 26, 3, 27, 4, 28  …  7, 31, 8, 32, 9, 33, 10, 34, 11, 35])
 LIKWID.AffinityDomain("D1", 24, 12, [12, 36, 13, 37, 14, 38, 15, 39, 16, 40  …  19, 43, 20, 44, 21, 45, 22, 46, 23, 47])
 LIKWID.AffinityDomain("C0", 24, 12, [0, 24, 1, 25, 2, 26, 3, 27, 4, 28  …  7, 31, 8, 32, 9, 33, 10, 34, 11, 35])
 LIKWID.AffinityDomain("C1", 24, 12, [12, 36, 13, 37, 14, 38, 15, 39, 16, 40  …  19, 43, 20, 44, 21, 45, 22, 46, 23, 47])
 LIKWID.AffinityDomain("M0", 24, 12, [0, 24, 1, 25, 2, 26, 3, 27, 4, 28  …  7, 31, 8, 32, 9, 33, 10, 34, 11, 35])
 LIKWID.AffinityDomain("M1", 24, 12, [12, 36, 13, 37, 14, 38, 15, 39, 16, 40  …  19, 43, 20, 44, 21, 45, 22, 46, 23, 47])
```

## Index

```@index
Pages   = ["affinity.md"]
Order   = [:function, :type]
```

### Functions

```@docs
LIKWID.init_affinity
LIKWID.finalize_affinity
LIKWID.get_affinity
LIKWID.cpustr_to_cpulist
LIKWID.get_processor_id
LIKWID.get_processor_ids
LIKWID.get_processor_id_glibc
LIKWID.pinprocess
LIKWID.pinthread
LIKWID.pinthreads
```

### Types

```@docs
LIKWID.AffinityDomains
LIKWID.AffinityDomain
```
