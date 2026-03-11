include(joinpath(@__DIR__, "..", "src", "DQPTPlots.jl"))

using .DQPTPlots

function main(args)
    cfg = parse_plot_cli(args)
    repo_root = normpath(joinpath(@__DIR__, ".."))

    root = isabspath(cfg.root) ? cfg.root : joinpath(repo_root, cfg.root)
    ising_path = joinpath(repo_root, "outputs", "refine_ising.tsv")
    xxz_path = joinpath(repo_root, "outputs", "medium_xxz.tsv")

    paths = render_figures(; style = cfg.style, root = root, ising_path = ising_path, xxz_path = xxz_path)

    for key in sort(collect(keys(paths)); by = string)
        println(string(key) * ": " * paths[key])
    end
end

main(ARGS)
