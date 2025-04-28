using Plots

# 1) Knoten ⇒ (x,y)-Koordinaten mappen
node_coords = Dict{Tuple{Int,Int}, Tuple{Float64,Float64}}()
for row in eachrow(bus_line_stops)
    node = (row.bus_line_id, row.stop_ids)
    node_coords[node] = (row.stop_x, row.stop_y)
end
# Depot-Koordinate hinzufügen
node_coords[(0,0)] = (30, 30)

# 2) Aktivierte Kanten
edges = [(u,v) for (u,v) in A_set if value(x[(u,v)]) > 1e-6]

# 3) Basisscatter der Knoten zeichnen
xs = [coord[1] for coord in values(node_coords)]
ys = [coord[2] for coord in values(node_coords)]
scatter(xs, ys;
    marker=:circle, ms=6,
    xlabel="X", ylabel="Y",
    title="Reihenfolge der Touren",
    legend=false)

# 4) Punkte beschriften
for (node, (xpt,ypt)) in node_coords
    annotate!(xpt, ypt, text(string(node), 8, :black, :center))
end

# 5) Tour-Kanten mit Pfeilen drüberplotten
for (u,v) in edges
    x1,y1 = node_coords[u]
    x2,y2 = node_coords[v]
    plot!([x1, x2], [y1, y2];
        arrow = :arrow,
        lw = 2,
        label = "")
end

display(current())
