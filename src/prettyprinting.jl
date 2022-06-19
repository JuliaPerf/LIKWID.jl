_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

"""
Print result tables etc. for the given group ids.
"""
function _print_perfmon_results(gid=PerfMon.get_id_of_active_group())
    PerfMon.isinitialized() || PerfMon.init()
    ## extract event and metric results
    nevents = PerfMon.get_number_of_events(gid)
    nmetrics = PerfMon.get_number_of_metrics(gid)
    ngrpthreads = PerfMon.get_number_of_threads()
    events = Matrix(undef, nevents, ngrpthreads + 1)
    metrics = Matrix(undef, nmetrics, ngrpthreads + 1)

    for tid in 1:ngrpthreads
        for eid in 1:nevents
            events[eid, 1] = PerfMon.get_name_of_event(gid, eid)
            events[eid, tid+1] = _zeroifnothing(PerfMon.get_result(gid, eid, tid))
        end
        for mid in 1:nmetrics
            metrics[mid, 1] = PerfMon.get_name_of_metric(gid, mid)
            metrics[mid, tid+1] = _zeroifnothing(PerfMon.get_metric(gid, mid, tid))
        end
    end

    ## printing
    theader = ["Thread $(i)" for i in 1:ngrpthreads]
    grpname = PerfMon.get_name_of_group(gid)
    print("\nGroup: ")
    printstyled("$grpname\n"; bold=true)
    pretty_table(events; header=vcat(["Event"], theader))
    pretty_table(metrics; header=vcat(["Metric"], theader))
    return nothing
end

"""
Requires previous `Marker.init_dynamic(group)` and `PerfMon.init()`!!!
"""
function _print_markerfile(markerfile::AbstractString)
    ret = MarkerFile.read(markerfile)
    ret || throw(ErrorException("Couldn't process markerfile."))
    for rid in 1:MarkerFile.numregions()
        rname = MarkerFile.regiontag(rid)
        rgid = MarkerFile.regiongroup(rid)
        rnthreads = MarkerFile.regionthreads(rid)
        rnevents = MarkerFile.regionevents(rid)
        rnmetrics = MarkerFile.regionmetrics(rid) # segfault?
        # rnmetrics = PerfMon.get_number_of_metrics(rgid)
        events = Matrix(undef, rnevents, rnthreads + 1)
        metrics = Matrix(undef, rnmetrics, rnthreads + 1)
        for tid in 1:rnthreads
            # events
            for eid in 1:rnevents
                events[eid, 1] = PerfMon.get_name_of_event(rgid, eid)
                events[eid, tid+1] = _zeroifnothing(MarkerFile.regionresult(rid, eid, tid))
            end
            # metrics
            for mid in 1:rnmetrics
                metrics[mid, 1] = PerfMon.get_name_of_metric(rgid, mid)
                metrics[mid, tid+1] = _zeroifnothing(MarkerFile.regionmetric(rid, mid, tid))
            end
        end
        ## printing
        theader = ["Thread $(i)" for i in 1:rnthreads]
        grpname = PerfMon.get_name_of_group(rgid)
        print("\nRegion: ")
        printstyled("$rname, "; bold=true)
        print("Group: ")
        printstyled("$grpname\n"; bold=true)
        pretty_table(events; header=vcat(["Event"], theader))
        pretty_table(metrics; header=vcat(["Metric"], theader))
    end
    return nothing
end
