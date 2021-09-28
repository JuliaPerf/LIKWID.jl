```@setup likwid
using LIKWID
```

# Timer

## Example

Timing based on CPU clock:
```@repl likwid
LIKWID.Timer.@timeit sleep(1)
```

Essentially, this is equivalent to the following manual sequence.
```@repl likwid
LIKWID.Timer.init()
t_start = LIKWID.Timer.start_clock()
sleep(1)
t_stop = LIKWID.Timer.stop_clock(t_start)
LIKWID.Timer.get_clock(t_stop)
LIKWID.Timer.get_clock_cycles(t_stop)
LIKWID.Timer.finalize()
```

## Functions

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