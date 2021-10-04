using LIKWID
using Test

@test typeof(LIKWID.get_processor_id()) == Int
@test typeof(LIKWID.pinprocess(0)) == Bool
@test typeof(LIKWID.pinthread(0)) == Bool