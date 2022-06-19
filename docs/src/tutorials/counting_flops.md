```@meta
EditURL = "https://github.com/JuliaPerf/LIKWID.jl/blob/main/docs/src/tutorials/counting_flops.jl"
```

# Counting FLOPs

Have you ever wondered how many floating point operations (FLOPs) a certain block of code,
e.g. a Julia function, has *actually* triggered in a CPU core? With LIKWID.jl you can readily
answer this question!

Let's consider a simple example: [SAXPY](https://www.netlib.org/lapack/explore-html/df/d28/group__single__blas__level1_gad2a52de0e32a6fc111931ece9b39726c.html).
The abbreviation SAXPY stands for single-precision (`Float32`) `a` times `x` plus `y`, i.e. the computation

```math
z = a \cdot x + y
```

Of course, we can readily write this as a Julia function.

````julia
saxpy!(z, a, x, y) = z .= a .* x .+ y
````

````
saxpy! (generic function with 1 method)
````

Preparing some random input we can perform the `saxpy!` operation as per usual (we're suppressing the unimportant output below).

````julia
const N = 10_000
const a = 3.141
const x = rand(Float32, N)
const y = rand(Float32, N)
const z = zeros(Float32, N)

saxpy!(z, a, x, y);
````

Let's now use LIKWID to count the **actually** performed FLOPs for this computation!
Concretely, we measure the FLOPS_SP performance group, in which "SP" stands for "single precision".

````julia
using LIKWID
metrics, events = @perfmon "FLOPS_SP" saxpy!(z, a, x, y);
````

````

Group: FLOPS_SP
┌───────────────────────────┬──────────┐
│                     Event │ Thread 1 │
├───────────────────────────┼──────────┤
│          ACTUAL_CPU_CLOCK │  75640.0 │
│             MAX_CPU_CLOCK │  55762.0 │
│      RETIRED_INSTRUCTIONS │  20140.0 │
│       CPU_CLOCKS_UNHALTED │  27097.0 │
│ RETIRED_SSE_AVX_FLOPS_ALL │  20000.0 │
│                     MERGE │      0.0 │
└───────────────────────────┴──────────┘
┌──────────────────────┬────────────┐
│               Metric │   Thread 1 │
├──────────────────────┼────────────┤
│  Runtime (RDTSC) [s] │ 7.46982e-6 │
│ Runtime unhalted [s] │ 3.08736e-5 │
│          Clock [MHz] │    3323.36 │
│                  CPI │    1.34543 │
│         SP [MFLOP/s] │    2677.44 │
└──────────────────────┴────────────┘

````

That was easy. Let's see what we got.
Among all those results, the event "RETIRED\_SSE\_AVX\_FLOPS\_ALL" is the one that we care
about since it indicates the number of performed FLOPs.

````julia
NFLOPs_actual = first(events["FLOPS_SP"])["RETIRED_SSE_AVX_FLOPS_ALL"]
````

````
20000.0
````

!!! note
    Unfortunately, as CPUs can be very different the relevant event might have a different name
    on your system. Look out for something with "FLOPS" in `events`.

Let's check whether this number makes sense. Our vectors are of length `N` and for each element
we perform two FLOPs in the SAXPY operation: one multiplication and one addition. Hence,
our expectation is

````julia
NFLOPs_expected(N) = 2 * N
NFLOPs_expected(N)
````

````
20000
````

Note that this perfectly matches our measurement result above!

````julia
NFLOPs_actual == NFLOPs_expected(N)
````

````
true
````

To rule out that this is just a big coincidence, let's try to modify `N` and check again.
For convenience, let's wrap the above procedure into a function.

````julia
function count_FLOPs(N)
    a = 3.141
    x = rand(Float32, N)
    y = rand(Float32, N)
    z = zeros(Float32, N)
    _, events = @perfmon "FLOPS_SP" saxpy!(z, a, x, y)
    return first(events["FLOPS_SP"])["RETIRED_SSE_AVX_FLOPS_ALL"]
end
````

````
count_FLOPs (generic function with 1 method)
````

See how it still matches our expectation when varying the input!

````julia
count_FLOPs(2 * N) == NFLOPs_expected(2 * N)
````

````
true
````

Feel free to play around further and apply this knowledge to other operations!
As an inspiration: How many FLOPs does an `exp.(x)` or `sin.(x)` trigger?
Does the answer depend on the length of `x`?

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

