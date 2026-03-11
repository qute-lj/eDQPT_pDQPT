module DQPTPlots

using DelimitedFiles
ENV["GKSwstype"] = get(ENV, "GKSwstype", "100")
using Plots

export load_tsv_table
export parse_plot_cli
export planned_figure_paths
export build_figure_bundle
export render_figures

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

end
