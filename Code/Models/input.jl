function load_data()
    lines = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/lines.csv", DataFrame)
    demand = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/demand.csv", DataFrame)
    busses = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/busses.csv", DataFrame)
    bus_line_stops = CSV.read("/Users/alexanderklaus/Desktop/Masterthesis/Code/data/bus-lines.csv", DataFrame)
    return lines, demand, busses, bus_line_stops
end

#bus_velocity
bus_velocity = 100 #in km/h

#break_time
break_time= "break1" #oder "break2"

