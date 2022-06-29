# Julia "translation" of https://github.com/RRZE-HPC/likwid/blob/master/examples/C-internalMarkerAPI.c
using LIKWID
using LIKWID: PerfMon, MarkerFile
using Base.Threads: nthreads, @threads
using Printf

const NUM_FLOPS = 100_000_000
const NUM_COPIES = 100_000
const NUM_THREADS = 3
const MAX_NUM_EVENTS = 20
const ARRAY_SIZE = 2048

@assert nthreads() == NUM_THREADS

_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

"Simple function designed to perform memory operations"
function do_copy(arr, copy_arr, num_copies)
    for _ in 1:num_copies
        for i in eachindex(arr)
            copy_arr[i] = arr[i]
        end
    end
    return nothing
end

"Simple function designed to do floating point computations"
function do_flops(a, b, c, num_flops)
    for _ in 1:num_flops # @simd
        c = a * b + c
        # c = muladd(a, b, c)
    end
    return c
end

# "Optimized function designed to do floating point computations"
# function do_flops(a, b, c, num_flops)
#     @simd for _ in 1:num_flops
#         c = muladd(a, b, c)
#     end
#     return c
# end

function main()

    # ====== Begin setting environment variables ======
    # The envrionment variables used to configure are typically set
    # at runtime with a command like:
    #
    # LIKWID_EVENTS="L2|L3" LIKWID_THREADS="0,2,3" LIKWID_FILEPATH="/tmp/likwid_marker.out" LIKWID_ACCESSMODE="1" LIKWID_FORCE="1" julia -t3 Julia-internalMarkerAPI.jl
    #
    # They are set here to ensure completeness of this example.

    # shouldn't be run under likwid-perfctr
    if haskey(ENV, "LIKWID_PIN")
        error(
            "It appears you are running this example with " *
            "likwid-perfctr. This example is intended to be run alone. " *
            "Results will be incorrect or missing.",
        )
        exit()
    end

    # The first envrionment variable is "LIKWID_EVENTS", which indicates the
    # groups to be measured. In this case, the first 3 are group names
    # specified in `/<LIKWID_PREFIX>/share/likwid/perfgroups/<ARCHITECTURE>/`
    # (default prefix is `/usr/local`). The final group is a custom group
    # specified with EVENT_NAME:COUNTER_NAME
    #
    # Be aware that the groups chosen below are defined for most but not all
    # architectures supported by likwid. For a more compatible set of groups,
    # see the commented group set. The second, more compatible set will work
    # for all architectures supported by likwid except nvidiagpus and Xeon Phi
    # (KNC).
    LIKWID.LIKWID_EVENTS("FLOPS_DP|L2|INSTR_RETIRED_ANY:FIXC0")
    # LIKWID.LIKWID_EVENTS("BRANCH|INSTR_RETIRED_ANY:FIXC0")

    # LIKWID_THREADS must be set to the list of hardware threads that we will use
    # for the Marker API
    LIKWID.LIKWID_THREADS("0,2,3")

    # the location the marker file will be stored
    LIKWID.LIKWID_FILEPATH(joinpath(@__DIR__, "likwid_marker.out"))

    # 1 is the code for access daemon
    LIKWID.LIKWID_MODE(1)

    # If the NMI watchdog is enabled or the application does not call
    # perfmon_finalize(), e.g. because of some error, LIKWID will fail with
    # a message "Counter in use". By settings LIKWID_FORCE you can overwrite
    # the registers.
    LIKWID.LIKWID_FORCE(true)

    # If the user desires more information about what's going on under the
    # hood, set this to get debug information. Values from 0-3 are valid, with
    # 0 being the default (none) and each level from 1-3 being an increased
    # level of verbosity
    LIKWID.LIKWID_DEBUG(0)
    # LIKWID.LIKWID_DEBUG(3)

    # ====== End setting environment variables ======

    # Calls perfmon_init() and perfmon_addEventSet. Uses environment variables
    # set above to configure likwid.
    # Note: LIKWID_MARKER_THREADINIT was required with past versions of likwid but
    # now is now commonly not needed.
    # It is only required if the pinning library fails and there is a risk of
    # threads getting migrated. I am currently unaware of any runtime system
    # that doesn't work. 
    Marker.init_nothreads()
    PerfMon.init()

    # Virtual threads must be pinned to a physical thread. This is
    # demonstrated below. Alternatively, threads may be pinned on julia startup
    # using likwid-pin or similar.
    cpus = [0, 2, 3]
    @threads :static for threadid in 1:NUM_THREADS
        LIKWID.pinthread(cpus[threadid])

        # Registering regions is optional but strongly recommended, as it reduces
        # overhead of LIKWID_MARKER_START and prevents wrong counts in short
        # regions.
        #
        # There must be a barrier between registering a region and starting that
        # region. Typically these are done in separate parallel blocks, relying on
        # the implicit barrier at the end of the parallel block. Usually there is
        # a parallel block for initialization and a parallel block for execution.
        Marker.registerregion("Total")
        Marker.registerregion("calc_flops")

        # To demonstrate that registering regions is optional, we do not register
        # the "copy" region
        # 
        # Marker.registerregion("copy")
    end

    # variables needed for flops/copy computations
    a = 1.8
    b = 3.2
    c = 1.0
    arr = zeros(ARRAY_SIZE)
    copy_arr = zeros(ARRAY_SIZE)

    # First, we will demonstrate measuring a single region, getting results
    # with `Marker.getregion`, and resetting the region so that these results
    # do not affect later measurements
    @threads :static for threadid in 1:NUM_THREADS
        # This region will measure flop-heavy computation. Notice that only the
        # first group specified, FLOPS_DP, will be measured. Measuring multiple
        # groups is demonstrated in the next example block.
        Marker.startregion("calc_flops")
        a = do_flops(c, a, b, NUM_FLOPS)
        Marker.stopregion("calc_flops")

        nevents, events, time, count = Marker.getregion("calc_flops")

        # group ID will let us get group and event names
        gid = PerfMon.get_id_of_active_group()

        # get group name
        group_name = PerfMon.get_name_of_group(gid)

        # print basic info
        @printf(
            "calc_flops thread %d finished measuring group %s.\nGot %d events, runtime %f s, and call count %d\n",
            threadid,
            group_name,
            nevents,
            time,
            count
        )

        # only allow one thread to print to prevent repeated output.
        if threadid == 1
            # uncomment the for loop if you'd like to inspect all threads.
            tid = 1
            for tid in 1:NUM_THREADS
                println("detailed event results:")
                for eid in 1:nevents
                    # get event name
                    event_name = PerfMon.get_name_of_event(gid, eid)
                    # print results
                    @printf(
                        "%40s: %30f\n",
                        event_name,
                        _zeroifnothing(PerfMon.get_result(gid, eid, tid))
                    )
                end
            end
            println()
        end

        # Regions may be reset during execution. This should be called on every
        # thread that should be reset. Since we have already inspected results of
        # the calc_flops region, we will reset it here:
        Marker.resetregion("calc_flops")
    end

    # Next, we'll demonstrate nested regions and measuring multiple groups
    # using `Marker.nextgroup`. We will not inspect them with
    # `Marker.getregion`, but will instead use the marker file to inspect
    # regions after this parallel block is finished.

    # The code that is to be measured will be run multiple times to measure
    # each group specified above. Using `PerfMon.get_number_of_groups` to get the
    # number of iterations makes it easy to run the computations once for each
    # group.
    for i in 1:PerfMon.get_number_of_groups()
        @threads :static for threadid in 1:NUM_THREADS
            # Starting and stopping regions should be done in a parallel block. If
            # regions are started/stopped in a serial region, only the master
            # thread will be measured.
            Marker.startregion("Total")
            Marker.startregion("calc_flops")
            c = do_flops(a, b, c, NUM_FLOPS)
            Marker.stopregion("calc_flops")

            Marker.startregion("copy")
            do_copy(arr, copy_arr, NUM_COPIES)
            Marker.stopregion("copy")
            Marker.stopregion("Total")
        end

        # The barrier after stopping all regions but before switching groups
        # is absolutely required: without it, some threads may
        # not have stopped the "copy" and "Total" regions before switching
        # groups, which causes erroneous results

        # `Marker.nextgroup` should only be run by a single thread and all
        # threads have stopped regions before switching groups.
        # 
        # Regions must be switched outside of all regions (e.g. after
        # `Marker.stopregion` is called for each region)
        Marker.nextgroup()
    end
    println()

    # Stops performance monitoring and writes to the file specified in the
    # LIKWID_FILEPATH environment variable. We will read this using likwid to
    # view results. 
    #
    Marker.close()

    # Read file output by likwid so that we can process results
    MarkerFile.read(ENV["LIKWID_FILEPATH"])

    # Get information like region name, number of events, and number of
    # metrics. Notice that number of regions printed here is actually
    # (num_region#num_groups), because perfmon considers a region to be the
    # region/group combo. In other words, each time a region is measured with
    # a different group or event set, perfmon considers it a new region.
    #
    # Therefore, if we have two regions and 3 groups measured for each,
    # `MarkerFile.numregions()` will return 6.
    #
    nregions = MarkerFile.numregions()
    println("Marker API measured ", nregions, " regions")
    for rid in 1:nregions
        gid = MarkerFile.regiongroup(rid)
        @printf(
            "Region %s with %d events and %d metrics\n",
            MarkerFile.regiontag(rid),
            MarkerFile.regionevents(rid),
            MarkerFile.regionmetrics(rid)
        )
    end
    println()

    # Print per-thread results.
    println("detailed results follow. Notice that the region \"calc_flops\"")
    println("will not appear, as it was reset after each time it was measured.")
    println()

    @printf(
        "%6s : %15s : %10s : %6s : %40s : %30s \n",
        "thread",
        "region",
        "group",
        "type",
        "result name",
        "result value"
    )

    # Uncomment the for loop if you'd like to inspect all threads
    tid = 1
    for tid in 1:NUM_THREADS
        for rid in 1:nregions
            # Returns the user-supplied region name
            region_name = MarkerFile.regiontag(rid)

            # gid is the group ID independent of region, where as i is the ID
            # of the region/group combo
            gid = MarkerFile.regiongroup(rid)
            # Get the name of the group measured, like "FLOPS_DP" or "L2"
            group_name = PerfMon.get_name_of_group(gid)

            # Get info for each event
            for eid in 1:PerfMon.get_number_of_events(gid)
                # Get the event name, like "INSTR_RETIRED_ANY"
                event_name = PerfMon.get_name_of_event(gid, eid)
                # Get the associated value
                event_value = MarkerFile.regionresult(rid, eid, tid)

                @printf(
                    "%6d : %15s : %10s : %6s : %40s : %30f \n",
                    tid,
                    region_name,
                    group_name,
                    "event",
                    event_name,
                    event_value
                )
            end

            # Get info for each metric
            for mid in 1:PerfMon.get_number_of_metrics(gid)
                # Get the metric name, like "L2 bandwidth [MBytes/s]"
                metric_name = PerfMon.get_name_of_metric(gid, mid)
                # Get the associated value
                metric_value = MarkerFile.regionmetric(rid, mid, tid)

                @printf(
                    "%6d : %15s : %10s : %6s : %40s : %30f \n",
                    tid,
                    region_name,
                    group_name,
                    "metric",
                    metric_name,
                    metric_value
                )
            end
        end
    end

    return nothing
end

main()