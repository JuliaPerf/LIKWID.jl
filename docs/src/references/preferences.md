# Preferences

By default, LIKWID.jl will assume that LIKWID is available as `liblikwid` on the system (i.e. present in `LD_LOAD_PATH`). You can overwrite this default and (permanently) specify the path to `liblikwid` as a [Julia preference](https://github.com/JuliaPackaging/Preferences.jl) by using the tools below (`LIKWID.Prefs.set_likwid` in particular).

## Index

```@index
Pages   = ["preferences.md"]
Order   = [:function, :type]
```

### Functions

```@autodocs
Modules = [LIKWID.Prefs]
```