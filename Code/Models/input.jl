using CSV
using DataFrames
# CSV-Dateien einlesen
lines = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/lines.csv", DataFrame)
demand = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/demand.csv", DataFrame)
busses = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/busses.csv", DataFrame)
bus_line_stops = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/bus_lines.csv", DataFrame)

# Dictionary mit Tuple (bus_line_id, line_id) => start_time erstellen
for row in eachrow(lines)
    key = (row.bus_line_id, row.line_id)
    start_times[key] = row.start_time
end

#create dict with every bus-line ID as key and list of stops in a row as value
line_stops=Dict{lines,}
time_of_stop=Dict{line_stops[], time}
#create tuples of all different stops on a line to create a dict with the traveltimes between the stops of the tuple
stop_tuples = [(i, j) for i in keys(line_stops) for j in keys(line_stops)]
travel_times=Dict{stop_tuples,Float64}
#=
fix_bus_capacity=y
buses_count=length(lines)
different_bus_capacities = Dict(i => 0 for i in 1:buses_count)
customer_demand=dict{lines[i],z}(for i in lines)
shift_starts=dict{}
break_starts=dict{}
break_length=xx
shift_ends=dict{}
=#
depot=(bus_line_id=0,stop_ids=0,stop_x=30,stop_y=30)
insert!(bus_line_stops,1,depot)
line_stops_dict = Dict{Int, Vector{Int}}()

for row in eachrow(bus_line_stops)
    l = row.bus_line_id
    stop = row.stop_ids
    # Depot-Zeile überspringen
    if l == 0 && stop == 0
        continue
    end
    if haskey(line_stops_dict, l)
        push!(line_stops_dict[l], stop)
    else
        line_stops_dict[l] = [stop]
    end
end
println("Dictionary of lines with their respective stop-sequences:")
sort(line_stops_dict)
distances_stops_dict_2 = Dict{Tuple{Tuple{Int, Int}, Tuple{Int, Int}}, Float64}()

for i in 1:length(bus_line_stops.stop_x)
    for j in i:length(bus_line_stops.stop_x)
        a = (bus_line_stops.bus_line_id[i], bus_line_stops.stop_ids[i])
        b = (bus_line_stops.bus_line_id[j], bus_line_stops.stop_ids[j])
        c = b[1]  # Linien-ID

        # Bedingung: erste zur letzten Haltestelle derselben Linie
        if a[2] == 1 && a[1] == b[1] && b[2] == last(line_stops_dict[c])
            # hole alle Stopps dieser Linie und sortiere sie nach Reihenfolge
            stops = sort(filter(row -> row.bus_line_id == c, eachrow(bus_line_stops)),by = r -> r.stop_ids)

            # summme der Teilstrecken
            total_length = 0.0
            for k in 1:(length(stops)-1)
                x1, y1 = stops[k].stop_x, stops[k].stop_y
                x2, y2 = stops[k+1].stop_x, stops[k+1].stop_y
                total_length += sqrt((x2 - x1)^2 + (y2 - y1)^2)
            end
            key = (a, b)
            distances_stops_dict_2[key] = total_length
        else 
            distance_temp = sqrt((bus_line_stops.stop_x[j]-bus_line_stops.stop_x[i])^2+(bus_line_stops.stop_y[j]-bus_line_stops.stop_y[i])^2)
            key = (a, b)
            distances_stops_dict_2[key]=distance_temp
        end
    end
end
sort(collect(distances_stops_dict_2))
# Dictionary zur Speicherung der Linienlängen
line_lengths_dict = Dict{Int, Float64}()

# Alle eindeutigen Linien ermitteln
unique_lines = unique(bus_line_stops.bus_line_id)

for line in unique_lines
    if line == 0
        continue
    end

    # Filtere Stopps dieser Linie und sortiere nach stop_ids
    stops = sort(filter(row -> row.bus_line_id == line, eachrow(bus_line_stops)), by = r -> r.stop_ids)
    line_length = 0.0
    for i in 1:(length(stops)-1)
        x1, y1 = stops[i].stop_x, stops[i].stop_y
        x2, y2 = stops[i+1].stop_x, stops[i+1].stop_y
        line_length += sqrt((x2 - x1)^2 + (y2 - y1)^2) # in Kilometern
    end

    line_lengths_dict[line] = line_length
end
println("Total line lengths:")
sort(collect(line_lengths_dict))
bus_velocity= 100 #in km/h
#############
#Berechnung der Dauer von jedem Knoten zu jedem anderen Knoten
#############
durations_each_connection_dict=Dict()
# Neues Dictionary für die Reisezeiten
for (key, dist) in distances_stops_dict_2
    # Fahrtzeit in Minuten berechnen
    time_min = (dist / bus_velocity * 60)
    durations_each_connection_dict[key] = time_min
end
println("\n\nDictionary of durations from every node to every node:")
sort(collect(durations_each_connection_dict))
#######
#Filtern der Dauer jeder Linie
#######
duration_line_dict = Dict(k => v for (k, v) in durations_each_connection_dict if k[1][1] == k[2][1] && k[1][2] == 1 && k[2][2]==last(line_stops_dict[k[1][1]]))
sort(collect(duration_line_dict))
########
#Filtern der Dauer von Depot zu jeder ersten Haltestelle
########
duration_depot_firststop_dict= Dict(k => v for (k, v) in durations_each_connection_dict if k[1] == (0,0) && k[2][2] ==1)
sort(collect(duration_depot_firststop_dict))
########
#Filtern der Dauer von jeder letzten Haltestelle zum Depot
########
duration_laststop_depot_dict=Dict(k => v for (k, v) in durations_each_connection_dict if k[2][1]!=0 && k[1]==(0,0) && k[2][2] == last(line_stops_dict[k[2][1]]))
sort(collect(duration_laststop_depot_dict))
########
#Filtern von der Dauern vom Ende einer Linie zum Beginn aller anderen Linien in der smmyterischen Matrix
dict_temp_1=Dict((from,to) => v for ((from,to), v) in durations_each_connection_dict if from[1]!=0 && from[1]!=to[1] && from[2] == last(line_stops_dict[from[1]]) && to[2] == first(line_stops_dict[to[1]]))

################
#dieser Part verwendet dieselbe Distanz zwischen zwei Knoten für beide Richtungen (Hinweg = Rückweg)
#################
dict_temp_2=Dict()
for i in keys(durations_each_connection_dict)
    to, from = i  #hiermit werden auch die Verbindungen berücksichtigt, die keinen eigenen tuple haben, deren Dauer aber trotzdem in der Matrix stehen
    if to[1] == 0
        continue
    end
    if from[1]!=to[1] && from[2] == last(line_stops_dict[from[1]]) && to[2] == first(line_stops_dict[to[1]])
        i_temp=(from, to)
        dict_temp_2[i_temp]=durations_each_connection_dict[(to,from)]        
    end
end
durations_each_end_to_start_dict = merge(dict_temp_1, dict_temp_2)
sort(collect(durations_each_end_to_start_dict))
function get_connections_which_fulfill_time_constraint(lines, line_stops_dict, durations_each_end_to_start_dict, duration_depot_firststop_dict, duration_line_dict,A_Set)
    for i in sort(collect(keys(durations_each_end_to_start_dict)))
        from, to = i
        a, b = from
        c, d = to
        # Depot-Zeile überspringen
        if from[2]==0
            continue
        end
        #check only for the connections between the lines
        if from[2] == last(line_stops_dict[from[1]]) && to[2] == 1 && from[1]!=to[1]#if connection ist zwischen ende von Linie a und anfang von Linie b
            #display("Calculating for connection $i:")
            possible_origin_lines = filter(row -> row.bus_line_id == from[1], eachrow(lines))
            possible_goal_lines = filter(row -> row.bus_line_id == to[1], eachrow(lines))
            for row_i in possible_origin_lines
                if i in A_Set
                    #display("Skipped, connection $i already in A_temp.")
                    break
                else
                    bl1_temp=row_i.bus_line_id
                    l1_id_temp=row_i.line_id
                    t_start_first_line=row_i.start_time
                    #display("Checking for tour $bl1_temp-$l1_id_temp with start time $t_start_first_line")
                    t_depot_firststop = duration_depot_firststop_dict[((0,0),(from[1],1))] 

                    #check only for tours which can actually be started
                    if t_depot_firststop < t_start_first_line
                        #display("Tour $bl1_temp-$l1_id_temp can be started!")
                        for row_j in possible_goal_lines
                            bl2_temp=row_j.bus_line_id
                            l2_id_temp=row_j.line_id
                            t_end_first_line = t_start_first_line + duration_line_dict[((from[1],first(line_stops_dict[from[1]])),((from[1],last(line_stops_dict[from[1]]))))]
                            t_between_lines= durations_each_end_to_start_dict[i]
                            t_start_second_line=row_j.start_time
                            #add only those connections bewteen lines if the time-constraint holds for at least on connections of tours
                            #display("Checking if connection from tour $bl1_temp-$l1_id_temp to tour $bl2_temp-$l2_id_temp can be upheld")
                            if t_end_first_line + t_between_lines <= t_start_second_line
                                if !(i in A_Set)
                                    push!(A_Set, i)
                                    #display("Added connection $i, because end of tour $bl1_temp-$l1_id_temp is $t_end_first_line and start of tour $bl2_temp-$l2_id_temp is $t_start_second_line.")
                                else
                                    #display("Skipped, connection already in A_temp.")
                                end
                            else
                                #display("Time-constraint not fulfilled, skipping...")
                            end
                        end
                    else
                        #display("Tour $bl1_temp-$l1_id_temp cannot be started in time, skipping...")
                        continue
                    end 
                end
                if i in A_Set
                    break
                end
            end
        end
    end
end
A_set = []
for i in keys(distances_stops_dict_2)
    from, to = i
    # Depot-Zeile überspringen
    if to[2]==0
        continue
    end
    #Connection Depot <-> erste Haltestelle wird mit aufgenommen
    if from == (0, 0) && to[2] == 1
        push!(A_set, i)
    #=elseif b== (0, 0) && a[2] == 1            für den Fall einer unsymmetrischen Matrix
        push!(A_set, i)
    =#
    #Connection Depot <-> letzte Haltestelle wird mit aufgenommen
    elseif from == (0, 0) && to[2]==last(line_stops_dict[to[1]])
        i_temp=(to,from)
        push!(A_set, i_temp)
    #=elseif to == (0, 0) && from[2] == last(line_stops_dict[c])     für den Fall einer unsymmetrischen Matrix
        push!(A_set, i)
    =#
    #Connection erste Haltestelle <-> letzte Haltestelle derselben Linie wird mit aufgenommen
    elseif from[2] == 1 && from[1] == to[1] && to[2] == last(line_stops_dict[to[1]])
        push!(A_set, i)
    end
end

#Connection zwischen den Linien unter der Bedingung "t_end_of_first_line + t_between_lines <= t_start_time_second_line"
get_connections_which_fulfill_time_constraint(lines, line_stops_dict, durations_each_end_to_start_dict, duration_depot_firststop_dict, duration_line_dict,A_set)
sort(A_set)
V_Set=[]
count=0
for i in sort(collect(keys(distances_stops_dict_2)))
    if count==21
        break
    else
        push!(V_Set,i[2])
        count+=1
    end
end
sort(V_Set)
model= Model(HiGHS.Optimizer)
@variable(model, x[(i,j) in A_set], Bin)
@objective(model, Min, sum(x[(i,j)] for (i,j) in A_set if i == (0,0)))
@constraint(model, flow_conservation[node in V_Set],sum(x[(i,j)] for (i,j) in A_set if j == node) - sum(x[(i,j)] for (i,j) in A_set if i == node)==0)
@constraint(model,[l in keys(line_stops_dict)],x[((l, first(line_stops_dict[l])),(l, last(line_stops_dict[l])))] == 1)
optimize!(model)