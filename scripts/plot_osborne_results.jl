include(joinpath(@__DIR__, "..", "src", "DQPTPlots.jl"))

using .DQPTPlots

function main(args)
    root = "figures"

    i = 1
    while i <= length(args)
        key = args[i]
        key == "--root" || throw(ArgumentError("unknown argument: $key"))
        i == length(args) && throw(ArgumentError("missing value for $key"))
        root = args[i + 1]
        i += 2
    end

    repo_root = normpath(joinpath(@__DIR__, ".."))
    fig_root = isabspath(root) ? root : joinpath(repo_root, root)
    path = render_osborne_longrange_window_figure(;
        root = fig_root,
        specs = [
            (
                length = 6,
                path = joinpath(
                    repo_root,
                    "outputs",
                    "osborne_longrange_candidate_longrange_summary.md",
                ),
            ),
            (
                length = 8,
                path = joinpath(
                    repo_root,
                    "outputs",
                    "osborne_longrange_L8_candidate_longrange_summary.md",
                ),
            ),
            (
                length = 10,
                path = joinpath(
                    repo_root,
                    "outputs",
                    "osborne_longrange_L10_candidate_longrange_summary.md",
                ),
            ),
            (
                length = 12,
                path = joinpath(
                    repo_root,
                    "outputs",
                    "osborne_longrange_L12_refine_right_bd16_longrange_summary.md",
                ),
            ),
        ],
    )

    println("osborne_longrange_window: " * path)
end

main(ARGS)
