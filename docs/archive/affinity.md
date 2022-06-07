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

## API

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