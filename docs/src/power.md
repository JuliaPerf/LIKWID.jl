```@setup likwid
using LIKWID
```

# Power / Energy

## Example

General power information:
```@repl likwid
power = LIKWID.Power.get_power_info()
power.domains
first(power.domains)
```

Energy measurement:
```@repl likwid
LIKWID.Power.measure(; cpuid=0, domainid=0) do
    sleep(1)
end
LIKWID.Power.measure(; cpuid=0, domainid=0) do
    sum(sin(rand()) for _ in 1:1_000_000)
end
```


## Functions

```@docs
LIKWID.Power.init
LIKWID.Power.finalize
LIKWID.Power.get_power_info
LIKWID.Power.start_power
LIKWID.Power.stop_power
LIKWID.Power.get_power
LIKWID.Power.measure
```