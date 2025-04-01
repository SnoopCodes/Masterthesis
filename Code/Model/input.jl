lines=[] #definition fo line name (wenn ic die linien mit den stops bekomme, muss ich die Parameter evtl.  anders definieren)
line_stops=Dict{lines,}#stops here
time_of_stop=Dict{line_stops[], time}
stop_tuples = [(i, j) for i in keys(line_stops) for j in keys(line_stops)]
travel_times=Dict{stop_tuples,Float64}
fix_bus_capacity=y
buses_count=length(lines)
different_bus_capacities = Dict(i => 0 for i in 1:buses_count)
customer_demand=dict{lines[i],z}(for i in lines)
shift_starts=dict{}
break_starts=dict{}
break_length=xx
shift_ends=dict{}

