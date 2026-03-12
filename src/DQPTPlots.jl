module DQPTPlots

using DelimitedFiles
ENV["GKSwstype"] = get(ENV, "GKSwstype", "100")
using Plots

export load_tsv_table
export load_osborne_summary
export parse_plot_cli
export planned_figure_paths
export build_figure_bundle
export build_osborne_longrange_window_figure
export render_figures
export render_osborne_longrange_window_figure

function load_tsv_table(path::AbstractString)
    lines = readlines(path)
    isempty(lines) && throw(ArgumentError("empty TSV file: $path"))

    header = split(first(lines), '\t')
    table = Dict(name => Float64[] for name in header)

    for line in Iterators.drop(lines, 1)
        isempty(line) && continue
        values = split(line, '\t')
        length(values) == length(header) || throw(ArgumentError("row/header mismatch in $path"))
        for (name, value) in zip(header, values)
            push!(table[name], parse(Float64, value))
        end
    end

    return table
end

function load_osborne_summary(path::AbstractString)
    lines = readlines(path)
    isempty(lines) && throw(ArgumentError("empty summary file: $path"))

    entries = NamedTuple[]
    current = nothing

    for line in lines
        startswith(line, "## ") || startswith(line, "- ") || continue

        if startswith(line, "## ")
            isnothing(current) || push!(entries, current)
            label = strip(line[4:end])
            m = match(r"^(.*)\(hz=([^\)]+)\)$", label)
            m === nothing && throw(ArgumentError("invalid Osborne heading in $path: $line"))
            current = (
                label = strip(m.captures[1]),
                hz = parse(Float64, m.captures[2]),
                metrics = Dict{Symbol, Any}(),
            )
            continue
        end

        isnothing(current) && throw(ArgumentError("metric before heading in $path"))
        metric_line = strip(line[3:end])
        parts = split(metric_line, " = "; limit = 2)
        length(parts) == 2 || throw(ArgumentError("invalid Osborne metric line in $path: $line"))
        key = Symbol(parts[1])
        raw = parts[2]

        value =
            if key == :classification
                Symbol(raw)
            elseif key == :max_allocated_bond
                parse(Int, raw)
            else
                parse(Float64, raw)
            end

        current.metrics[key] = value
    end

    isnothing(current) || push!(entries, current)

    return map(entries) do entry
        return (
            label = entry.label,
            hz = entry.hz,
            classification = entry.metrics[:classification],
            metrics = entry.metrics,
        )
    end
end

function parse_plot_cli(args::Vector{String})
    style = :all
    root = "figures"

    i = 1
    while i <= length(args)
        key = args[i]
        key in ("--style", "--root") || throw(ArgumentError("unknown argument: $key"))
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--style"
            style = Symbol(value)
            style in (:analysis, :report, :all) || throw(ArgumentError("invalid style: $value"))
        elseif key == "--root"
            root = value
        end
        i += 2
    end

    return (style = style, root = root)
end

function planned_figure_paths(style::Symbol; root::AbstractString = "figures")
    paths = Dict{Symbol, String}()

    if style in (:analysis, :all)
        paths[:ising_diagnostics] = joinpath(root, "analysis", "ising_diagnostics.png")
        paths[:xxz_diagnostics] = joinpath(root, "analysis", "xxz_diagnostics.png")
        paths[:comparison_overview] = joinpath(root, "analysis", "comparison_overview.png")
    end

    if style in (:report, :all)
        paths[:dqpt_qualitative_comparison] = joinpath(
            root,
            "report",
            "dqpt_qualitative_comparison.png",
        )
    end

    return paths
end

function _series(table, name::AbstractString)
    haskey(table, name) || throw(ArgumentError("missing column: $name"))
    return table[name]
end

function _style_defaults!(style::Symbol)
    gr()
    if style == :analysis
        default(
            fontfamily = "sans-serif",
            lw = 2,
            legend = :topright,
            grid = true,
            framestyle = :box,
            size = (1200, 900),
        )
    else
        default(
            fontfamily = "sans-serif",
            lw = 2.5,
            legend = :topright,
            grid = false,
            framestyle = :box,
            foreground_color_legend = nothing,
            background_color = :white,
            size = (1280, 900),
        )
    end
end

function _ising_diagnostics_plot(table)
    t = _series(table, "time")
    rate = _series(table, "rate")
    entropy = _series(table, "entropy")
    mx = _series(table, "mx")
    mz = _series(table, "mz")
    cusp_t = t[argmax(rate)]

    p1 = plot(t, rate; color = :firebrick, xlabel = "t", ylabel = "rate", title = "Ising rate")
    vline!(p1, [cusp_t]; color = :gray40, ls = :dash, label = "peak")

    p2 = plot(
        t,
        entropy;
        color = :teal,
        xlabel = "t",
        ylabel = "entropy",
        title = "Ising entanglement",
        label = "entropy",
    )
    vline!(p2, [cusp_t]; color = :gray40, ls = :dash, label = "peak")

    p3 = plot(t, mx; color = :navy, xlabel = "t", ylabel = "magnetization", title = "Ising order", label = "mx")
    plot!(p3, t, mz; color = :darkorange, label = "mz")
    vline!(p3, [cusp_t]; color = :gray40, ls = :dash, label = "peak")

    return plot(p1, p2, p3; layout = (3, 1), size = (1100, 1200))
end

function _xxz_diagnostics_plot(table)
    t = _series(table, "time")
    rate = _series(table, "rate")
    entropy = _series(table, "entropy")
    mz1 = _series(table, "mz1")
    mz2 = _series(table, "mz2")
    staggered = _series(table, "staggered_mz")
    peak_t = t[argmax(rate)]

    p1 = plot(t, rate; color = :purple4, xlabel = "t", ylabel = "rate", title = "XXZ rate", label = "rate")
    vline!(p1, [peak_t]; color = :gray40, ls = :dash, label = "peak")

    p2 = plot(
        t,
        entropy;
        color = :forestgreen,
        xlabel = "t",
        ylabel = "entropy",
        title = "XXZ entanglement",
        label = "entropy",
    )
    vline!(p2, [peak_t]; color = :gray40, ls = :dash, label = "peak")

    p3 = plot(t, mz1; color = :royalblue4, xlabel = "t", ylabel = "magnetization", title = "XXZ order", label = "mz1")
    plot!(p3, t, mz2; color = :indianred3, label = "mz2")
    plot!(p3, t, staggered; color = :black, ls = :dash, label = "staggered")
    vline!(p3, [peak_t]; color = :gray40, ls = :dot, label = "peak")

    return plot(p1, p2, p3; layout = (3, 1), size = (1100, 1200))
end

function _comparison_overview_plot(ising_table, xxz_table)
    p1 = plot(
        _series(ising_table, "time"),
        _series(ising_table, "rate");
        color = :firebrick,
        xlabel = "t",
        ylabel = "rate",
        title = "Rate comparison",
        label = "Ising",
    )
    plot!(p1, _series(xxz_table, "time"), _series(xxz_table, "rate"); color = :purple4, label = "XXZ")

    p2 = plot(
        _series(ising_table, "time"),
        _series(ising_table, "entropy");
        color = :teal,
        xlabel = "t",
        ylabel = "entropy",
        title = "Entanglement comparison",
        label = "Ising",
    )
    plot!(p2, _series(xxz_table, "time"), _series(xxz_table, "entropy"); color = :forestgreen, label = "XXZ")

    return plot(p1, p2; layout = (2, 1), size = (1100, 850))
end

function _report_plot(ising_table, xxz_table)
    ising_t = _series(ising_table, "time")
    xxz_t = _series(xxz_table, "time")
    ising_peak = ising_t[argmax(_series(ising_table, "rate"))]
    xxz_peak = xxz_t[argmax(_series(xxz_table, "rate"))]

    p1 = plot(
        ising_t,
        _series(ising_table, "rate");
        color = :firebrick,
        xlabel = "t",
        ylabel = "rate",
        title = "Ising",
        label = "rate",
    )
    vline!(p1, [ising_peak]; color = :gray45, ls = :dash, label = nothing)

    p2 = plot(
        ising_t,
        _series(ising_table, "entropy");
        color = :teal,
        xlabel = "t",
        ylabel = "entropy / order",
        title = "Ising diagnostics",
        label = "entropy",
    )
    plot!(p2, ising_t, _series(ising_table, "mz"); color = :darkorange, label = "mz")
    vline!(p2, [ising_peak]; color = :gray45, ls = :dash, label = nothing)

    p3 = plot(
        xxz_t,
        _series(xxz_table, "rate");
        color = :purple4,
        xlabel = "t",
        ylabel = "rate",
        title = "XXZ Neel",
        label = "rate",
    )
    vline!(p3, [xxz_peak]; color = :gray45, ls = :dash, label = nothing)

    p4 = plot(
        xxz_t,
        _series(xxz_table, "entropy");
        color = :forestgreen,
        xlabel = "t",
        ylabel = "entropy / order",
        title = "XXZ diagnostics",
        label = "entropy",
    )
    plot!(p4, xxz_t, _series(xxz_table, "staggered_mz"); color = :black, ls = :dash, label = "staggered")
    vline!(p4, [xxz_peak]; color = :gray45, ls = :dash, label = nothing)

    return plot(p1, p2, p3, p4; layout = (2, 2), size = (1300, 900))
end

function build_figure_bundle(ising_table, xxz_table; style::Symbol = :all)
    figures = Dict{Symbol, Any}()

    if style in (:analysis, :all)
        _style_defaults!(:analysis)
        figures[:ising_diagnostics] = _ising_diagnostics_plot(ising_table)
        figures[:xxz_diagnostics] = _xxz_diagnostics_plot(xxz_table)
        figures[:comparison_overview] = _comparison_overview_plot(ising_table, xxz_table)
    end

    if style in (:report, :all)
        _style_defaults!(:report)
        figures[:dqpt_qualitative_comparison] = _report_plot(ising_table, xxz_table)
    end

    return figures
end

function _osborne_window_rows(specs)
    rows = NamedTuple[]
    for spec in sort(collect(specs); by = x -> x.length)
        for entry in load_osborne_summary(spec.path)
            push!(
                rows,
                (
                    length = spec.length,
                    hz = entry.hz,
                    classification = entry.classification,
                    peak_time = entry.metrics[:peak_time],
                    peak_rate = entry.metrics[:peak_rate],
                    peak_mz = entry.metrics[:peak_mz],
                    max_entropy = entry.metrics[:max_entropy],
                    energy_drift = entry.metrics[:energy_drift],
                    max_allocated_bond = entry.metrics[:max_allocated_bond],
                ),
            )
        end
    end
    return rows
end

function _classified_rows(rows, classification::Symbol)
    return sort(filter(row -> row.classification == classification, rows); by = x -> x.length)
end

function build_osborne_longrange_window_figure(specs)
    rows = _osborne_window_rows(specs)
    manifold = _classified_rows(rows, :manifold)
    branch = _classified_rows(rows, :branch)

    _style_defaults!(:report)

    p1 = plot(
        [row.length for row in manifold],
        [row.hz for row in manifold];
        color = :teal,
        marker = :circle,
        ms = 7,
        xlabel = "chain length L",
        ylabel = "candidate hz",
        title = "Long-range confinement window",
        label = "manifold",
    )
    plot!(
        p1,
        [row.length for row in branch],
        [row.hz for row in branch];
        color = :firebrick,
        marker = :diamond,
        ms = 7,
        label = "branch",
    )

    p2 = plot(
        [row.length for row in manifold],
        [row.peak_mz for row in manifold];
        color = :teal,
        marker = :circle,
        ms = 7,
        xlabel = "chain length L",
        ylabel = "peak mz",
        title = "Order parameter at dominant peak",
        label = "manifold",
    )
    plot!(
        p2,
        [row.length for row in branch],
        [row.peak_mz for row in branch];
        color = :firebrick,
        marker = :diamond,
        ms = 7,
        label = "branch",
    )
    hline!(p2, [0.0]; color = :gray45, ls = :dash, label = nothing)

    p3 = plot(
        [row.length for row in manifold],
        [row.peak_rate for row in manifold];
        color = :teal,
        marker = :circle,
        ms = 7,
        xlabel = "chain length L",
        ylabel = "peak rate",
        title = "Dominant DQPT peak",
        label = "manifold",
    )
    plot!(
        p3,
        [row.length for row in branch],
        [row.peak_rate for row in branch];
        color = :firebrick,
        marker = :diamond,
        ms = 7,
        label = "branch",
    )

    p4 = plot(
        [row.length for row in manifold],
        [row.max_entropy for row in manifold];
        color = :teal,
        marker = :circle,
        ms = 7,
        xlabel = "chain length L",
        ylabel = "max entropy",
        title = "Entanglement scale",
        label = "manifold",
    )
    plot!(
        p4,
        [row.length for row in branch],
        [row.max_entropy for row in branch];
        color = :firebrick,
        marker = :diamond,
        ms = 7,
        label = "branch",
    )

    return plot(p1, p2, p3, p4; layout = (2, 2), size = (1280, 900))
end

function render_figures(;
    style::Symbol = :all,
    root::AbstractString = "figures",
    ising_path::AbstractString = joinpath("outputs", "refine_ising.tsv"),
    xxz_path::AbstractString = joinpath("outputs", "medium_xxz.tsv"),
)
    ising_table = load_tsv_table(ising_path)
    xxz_table = load_tsv_table(xxz_path)
    figures = build_figure_bundle(ising_table, xxz_table; style = style)
    paths = planned_figure_paths(style; root = root)

    for (key, fig) in figures
        path = paths[key]
        mkpath(dirname(path))
        savefig(fig, path)
    end

    return paths
end

function render_osborne_longrange_window_figure(;
    root::AbstractString = "figures",
    specs = [
        (length = 6, path = joinpath("outputs", "osborne_longrange_candidate_longrange_summary.md")),
        (length = 8, path = joinpath("outputs", "osborne_longrange_L8_candidate_longrange_summary.md")),
        (length = 10, path = joinpath("outputs", "osborne_longrange_L10_candidate_longrange_summary.md")),
        (length = 12, path = joinpath("outputs", "osborne_longrange_L12_candidate_longrange_summary.md")),
    ],
)
    fig = build_osborne_longrange_window_figure(specs)
    path = joinpath(root, "report", "osborne_longrange_window.png")
    mkpath(dirname(path))
    savefig(fig, path)
    return path
end

end
