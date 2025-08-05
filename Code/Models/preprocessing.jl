function adding_depot(bus_line_stops, lines)
    depot=(bus_line_id=0,stop_ids=0,stop_x=30,stop_y=30)
    insert!(bus_line_stops,1,depot)
    depot=(line_id=0,bus_line_id=0, start_time=0)
    insert!(lines,1,depot)
end

function get_customer_trips(demand)
    customer_trips = [((r.bus_line_id, r.line_id, r.origin_stop_id), (r.bus_line_id, r.line_id, r.destination_stop_id)) for r in eachrow(demand)]
    return customer_trips
end

function create_all_nodes(line, bus_line_stops)
    nodes = []
    for r in eachrow(lines)
        for row in eachrow(bus_line_stops)
            if r.bus_line_id == row.bus_line_id
                start_time_temp=0.0
                if row.stop_ids == 1
                    start_time_temp = r.start_time
                else
                    # alle Stopps dieser Linie sortieren
                    stops = sort(filter(r2 -> r2.bus_line_id == row.bus_line_id, eachrow(bus_line_stops)), by = r2 -> r2.stop_ids)
                    
                    # Travel time vom ersten Knoten bis aktuellen Knoten:
                    total_distance = 0.0
                    for k in 1:(row.stop_ids - 1)
                        x1, y1 = stops[k].stop_x, stops[k].stop_y
                        x2, y2 = stops[k+1].stop_x, stops[k+1].stop_y
                        total_distance += sqrt((x2 - x1)^2 + (y2 - y1)^2)
                    end
                    travel_time = (total_distance / bus_velocity) * 60  # Minuten

                    # Startzeit = Startzeit erster Knoten + Travel Time
                    start_time_temp = r.start_time + travel_time
                end
                push!(nodes, (
                    bus_line_id = row.bus_line_id,
                    line_id     = r.line_id,
                    stop_id     = row.stop_ids,
                    coord_x     = row.stop_x,
                    coord_y     = row.stop_y,
                    start_time  = start_time_temp
                ))
                    
            end
        end
    end
    return nodes
end

function create_all_connections(nodes)
    connections_dict = Dict()

    for node1 in nodes
        for node2 in nodes
            if node1 != node2
                #skip if the nodes are the same
                origin_node = (node1.bus_line_id, node1.line_id, node1.stop_id)
                goal_node = (node2.bus_line_id, node2.line_id, node2.stop_id)
                if node1.bus_line_id == node2.bus_line_id
                    if node1.line_id == node2.line_id
                        if node1.stop_id == node2.stop_id
                            # Nodes are the same
                            break
                        else
                            # Nodes are on the same tour
                            stops = sort(filter(n -> n.bus_line_id == node1.bus_line_id && n.line_id==node1.line_id, nodes), by = n -> n.stop_id)
                            start_index = findfirst(n -> n.stop_id == node1.stop_id, stops)
                            end_index = findfirst(n -> n.stop_id == node2.stop_id, stops)            
                            if start_index < end_index
                                #if origin node comes before goal node
                                total_distance = 0.0
                                for i in start_index:(end_index - 1)
                                    x1, y1 = stops[i].coord_x, stops[i].coord_y
                                    x2, y2 = stops[i + 1].coord_x, stops[i + 1].coord_y
                                    total_distance += eucleadian_distance(x1, y1, x2, y2)
                                end
                                distance= total_distance
                                travel_time = (distance / bus_velocity) * 60 #travel_time in minutes
                                end_time = node1.start_time + travel_time
                                connections_dict[(origin_node, goal_node)] = Connection(distance, travel_time, end_time)
                            elseif start_index > end_index
                                #=
                                total_distance = 0.0
                                for i in start_index:(end_index - 1)
                                    x1, y1 = stops[i].coord_x, stops[i].coord_y
                                    x2, y2 = stops[i + 1].coord_x, stops[i + 1].coord_y
                                    total_distance += eucleadian_distance(x1, y1, x2, y2)
                                end
                                distance= total_distance
                                =#
                                distance=eucleadian_distance(node1.coord_x, node1.coord_y, node2.coord_x, node2.coord_y)
                                travel_time = (distance / bus_velocity) * 60 #travel_time in minutes
                                end_time = node1.start_time + travel_time
                                connections_dict[(origin_node, goal_node)] = Connection(distance, travel_time, end_time)
                            end
                        end
                    else
                        #nodes are on the same bus line but not the same tour
                        distance = eucleadian_distance(node1.coord_x, node1.coord_y, node2.coord_x, node2.coord_y)
                        travel_time = (distance / bus_velocity) * 60 #travel_time in minutes
                        end_time = node1.start_time + travel_time
                        connections_dict[(origin_node, goal_node)] = Connection(distance, travel_time, end_time)
                    end
                else
                    # Nodes are on different bus lines
                    distance = eucleadian_distance(node1.coord_x, node1.coord_y, node2.coord_x, node2.coord_y)
                    travel_time = (distance / bus_velocity) * 60 #travel_time in minutes
                    end_time = node1.start_time + travel_time
                    connections_dict[(origin_node, goal_node)] = Connection(distance, travel_time, end_time)
                end
            end
        end
    end
    return connections_dict
end

function create_dict_of_lines_and_stops(bus_line_stops)
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
    return line_stops_dict
end