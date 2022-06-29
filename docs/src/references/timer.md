```@setup likwid
using LIKWID
```

# CPU Clock Timer

## Example

Timing is as simple as
```
julia> LIKWID.Timer.@timeit sleep(1)
(clock = 1.0021697811990014, cycles = 3307182468)
```
Apart from the time it took to execute `sleep(1)` (`clock`) one also gets the number of
CPU clock cycles corresponding to the time interval (`cycles`).

Note that the macro usage above is essentially equivalent to the following manual sequence
```
julia> LIKWID.Timer.init()
true

julia> t_start = LIKWID.Timer.start_clock()
TimerData(cycles start: 60459589412988386, cycles stop: 0)

julia> sleep(1)

julia> t_stop = LIKWID.Timer.stop_clock(t_start)
TimerData(cycles start: 60459589412988386, cycles stop: 60459592861915014)

julia> LIKWID.Timer.get_clock(t_stop)
1.045121729122075

julia> LIKWID.Timer.get_clock_cycles(t_stop)
3448926580

julia> LIKWID.Timer.finalize()
```

## Index

```@index
Pages   = ["timer.md"]
Order   = [:function, :type]
```

### Functions

```@docs
LIKWID.Timer.init
LIKWID.Timer.finalize
LIKWID.Timer.get_cpu_clock
LIKWID.Timer.get_cpu_clock_current
LIKWID.Timer.start_clock
LIKWID.Timer.stop_clock
LIKWID.Timer.get_clock
LIKWID.Timer.get_clock_cycles
LIKWID.Timer.timeit
LIKWID.Timer.@timeit
```
