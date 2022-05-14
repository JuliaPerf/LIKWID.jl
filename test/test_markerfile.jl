using Test
using LIKWID

const MARKERFILE = joinpath(@__DIR__, "markerfile.txt")

Marker.init()
@test LIKWID.MarkerFile.read(MARKERFILE)
@test LIKWID.MarkerFile.numregions() == 2
@test LIKWID.MarkerFile.regiontag(0) == "matmul"
@test LIKWID.MarkerFile.regiontag(1) == "eigen"
@test LIKWID.MarkerFile.regiongroup(0) == 0
@test LIKWID.MarkerFile.regionevents(0) == 7
@test LIKWID.MarkerFile.regionmetrics(0) == 10
@test LIKWID.MarkerFile.regionthreads(0) == 1
@test LIKWID.MarkerFile.regiontime(0,0) ≈ 14.57989
@test LIKWID.MarkerFile.regiontime(1,0) ≈ 10.75343
@test LIKWID.MarkerFile.regioncount(0,0) == 1
@test LIKWID.MarkerFile.regionresult(0,0,0) ≈ 3.341458e9
@test LIKWID.MarkerFile.regionmetric(0,0,0) ≈ 14.57989
Marker.close()