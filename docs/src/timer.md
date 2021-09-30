```@setup likwid
using LIKWID
```

# CPU Clock Timer

## Example

Timing is as simple as
```@repl likwid
LIKWID.Timer.@timeit sleep(1)
```
Apart from the time it took to execute `sleep(1)` (`clock`) one also gets the number of
CPU clock cycles corresponding to the time interval (`cycles`).

Note that the macro usage above is essentially equivalent to the following manual sequence
```@repl likwid
LIKWID.Timer.init()
t_start = LIKWID.Timer.start_clock()
sleep(1)
t_stop = LIKWID.Timer.stop_clock(t_start)
LIKWID.Timer.get_clock(t_stop)
LIKWID.Timer.get_clock_cycles(t_stop)
LIKWID.Timer.finalize()
```

## API

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