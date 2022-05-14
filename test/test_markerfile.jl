using Test
using LIKWID

const MARKERFILE = joinpath(@__DIR__, "markerfile.txt")

Marker.init()
@test LIKWID.MarkerFile.read(MARKERFILE)
@test LIKWID.MarkerFile.numregions() == 2
@test LIKWID.MarkerFile.regiontag(1) == "matmul"
@test LIKWID.MarkerFile.regiontag(2) == "eigen"
@test LIKWID.MarkerFile.regiongroup(1) == 1
@test LIKWID.MarkerFile.regionevents(1) == 7
@test LIKWID.MarkerFile.regionmetrics(1) == 10
@test LIKWID.MarkerFile.regionthreads(1) == 1
@test LIKWID.MarkerFile.regiontime(1, 1) ≈ 14.57989
@test LIKWID.MarkerFile.regiontime(2, 1) ≈ 10.75343
@test LIKWID.MarkerFile.regioncount(1, 1) == 1
@test LIKWID.MarkerFile.regionresult(1, 1, 1) ≈ 3.341458e9
@test LIKWID.MarkerFile.regionmetric(1, 1, 1) ≈ 14.57989
Marker.close()