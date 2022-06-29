```@setup likwid
using LIKWID
```

# Power / Energy

## Example

General power information:
```
julia> power = LIKWID.Power.get_power_info()
LIKWID.PowerInfo
├ baseFrequency: 3300.0 MHz
├ minFrequency: 1200.0 MHz
├ turbo: TurboBoost()
├ hasRAPL: true
├ powerUnit: 125000.0
├ timeUnit: 976.0
├ uncoreMinFreq: 1200.0 MHz
├ uncoreMaxFreq: 2400.0 MHz
├ perfBias: 6
└ domains: ... (5 elements)

julia> power.domains
(PowerDomain(PKG, ...), PowerDomain(PP0, ...), PowerDomain(PP1, ...), PowerDomain(DRAM, ...), PowerDomain(PLATFORM, ...))

julia> first(power.domains)
LIKWID.PowerDomain
├ id: 0
├ type: PKG
├ supportFlags: 27
├ energyUnit: 6.103515625e-5
├ tdp: 1.65e8
├ minPower: 6.8e7
├ maxPower: 1.65e8
├ maxTimeWindow: 31232.0
├ supportInfo: true
├ supportStatus: true
├ supportPerf: true
├ supportPolicy: false
└ supportLimit: true
```

Energy measurement:
```
julia> LIKWID.Power.measure(; cpuid=0, domainid=0) do
        sleep(1)
       end
29.9920654296875 μJ

julia> LIKWID.Power.measure(; cpuid=0, domainid=0) do
        sum(sin(rand()) for _ in 1:1_000_000)
       end
0.5574951171875 μJ
```

(Note that the example requires that the first (perhaps only) Julia thread is pinned to the CPU thread with id `0`.)

## Index

```@index
Pages   = ["power.md"]
Order   = [:function, :type]
```

### Functions

```@docs
LIKWID.Power.init
LIKWID.Power.finalize
LIKWID.Power.get_power_info
LIKWID.Power.start_power
LIKWID.Power.stop_power
LIKWID.Power.get_power
LIKWID.Power.measure
```

### Types

```@docs
LIKWID.PowerInfo
LIKWID.PowerDomain
LIKWID.LibLikwid.PowerType
LIKWID.TurboBoost
```
