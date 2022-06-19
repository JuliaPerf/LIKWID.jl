_zeroifnothing(x::Nothing) = 0.0
_zeroifnothing(x) = x

"""
Print result tables etc. for the given group ids.
"""
function print_results(gid=PerfMon.get_id_of_active_group())
    PerfMon.isinitialized() || PerfMon.init()
    ## extract event and metric results
    nevents = PerfMon.get_number_of_events(gid)
    nmetrics = PerfMon.get_number_of_metrics(gid)
    events = Matrix(undef, nevents, Threads.nthreads() + 1)
    metrics = Matrix(undef, nmetrics, Threads.nthreads() + 1)

    for tid in 1:Threads.nthreads()
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
    theader = ["Thread $(i)" for i in 1:Threads.nthreads()]
    grpname = PerfMon.get_name_of_group(gid)
    print("\nGroup: ")
    printstyled("$grpname\n"; bold=true)
    pretty_table(events; header=vcat(["Event"], theader))
    pretty_table(metrics; header=vcat(["Metric"], theader))
    return nothing
end
