function plot_initial_stops(bus_line_stops)
    # Gruppiere nach bus_line_id
    grouped_data = groupby(bus_line_stops, :bus_line_id)

    # Sammle alle Traces
    traces = PlotlyJS.AbstractTrace[]  # use correct type

    # Linien- und Beschriftungstraces erzeugen
    for grp in grouped_data
        sort!(grp, :stop_ids)

        # Linien-Trace mit Markern
        push!(traces, scatter(
            x = grp.stop_x,
            y = grp.stop_y,
            mode = "lines+markers+text",
            name = "Linie $(unique(grp.bus_line_id)[1])",
            marker = attr(size = 8),
            text = string.(grp.stop_ids),
            textposition = "top center",
            textfont = attr(color="black", size=10)
        ))

        # Distanzen zwischen benachbarten Haltestellen
        for i in 1:(nrow(grp) - 1)
            x1, y1 = grp.stop_x[i], grp.stop_y[i]
            x2, y2 = grp.stop_x[i+1], grp.stop_y[i+1]
            dist = round(sqrt((x2 - x1)^2 + (y2 - y1)^2), digits=2)
            mx, my = mean([x1, x2]), mean([y1, y2])

            # Distanztext hinzufügen
            push!(traces, scatter(
                x = [mx], y = [my],
                mode = "text",
                text = ["d = $dist"],
                textposition = "bottom center",
                textfont = attr(size = 9, color = "gray"),
                showlegend = false
            ))
        end
    end

    # Layout festlegen
    layout = Layout(
        title = "Buslinien und ihre Haltestellen",
        xaxis_title = "X-Koordinate",
        yaxis_title = "Y-Koordinate",
        legend = attr(x=1.02, y=1)
    )

    # Plot erstellen
    p = Plot(traces, layout)

    # In HTML-Datei speichern (im gleichen Ordner wie Code)
    return PlotlyJS.savefig(p, "/Users/alexanderklaus/Desktop/Masterthesis/Code/output/buslinien_test_function_plot.html")
end