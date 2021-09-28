```@setup likwid
using LIKWID
```

# Affinity

## Example

Query affinity domain information:
```@repl likwid
aff = LIKWID.get_affinity()
aff.domains
```

## Functions

```@docs
LIKWID.init_affinity
LIKWID.finalize_affinity
LIKWID.get_affinity
LIKWID.cpustr_to_cpulist
```

## Types

```@docs
LIKWID.AffinityDomains
LIKWID.AffinityDomain
```