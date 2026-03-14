include(joinpath(@__DIR__, "..", "src", "DQPTPRL2021.jl"))

using .DQPTPRL2021

function parse_comparison_cli(args::Vector{String})
    isempty(args) && throw(ArgumentError("expected protocol: ising_p | ising_e | xxz_p | xxz_e"))

    protocol = Symbol(args[1])
    nsites = 8
    dt = 0.05
    steps = 80
    boundary = :open
    output_prefix = string(protocol) * "_comparison"

    i = 2
    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--length"
            nsites = parse(Int, value)
        elseif key == "--dt"
            dt = parse(Float64, value)
        elseif key == "--steps"
            steps = parse(Int, value)
        elseif key == "--boundary"
            boundary = Symbol(value)
        elseif key == "--output-prefix"
            output_prefix = value
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    return (
        protocol = protocol,
        length = nsites,
        dt = dt,
        steps = steps,
        boundary = boundary,
        output_prefix = output_prefix,
    )
end

function main(args)
    cfg = parse_comparison_cli(args)
    outdir = ensure_dir(joinpath(@__DIR__, "..", "outputs"))

    dqpt = run_prl2021_finite_dqpt(
        cfg.protocol;
        length = cfg.length,
        dt = cfg.dt,
        steps = cfg.steps,
        boundary = cfg.boundary,
    )
    comparison = run_prl2021_dqpt_esqpt_comparison(
        cfg.protocol;
        length = cfg.length,
        dt = cfg.dt,
        steps = cfg.steps,
        boundary = cfg.boundary,
    )

    dqpt_path = joinpath(outdir, cfg.output_prefix * "_dqpt.tsv")
    summary_path = joinpath(outdir, cfg.output_prefix * "_comparison_summary.md")

    save_prl2021_finite_dqpt(dqpt, dqpt_path)
    write_prl2021_dqpt_esqpt_comparison_summary(comparison, summary_path)

    println("dqpt tsv: " * dqpt_path)
    println("comparison summary: " * summary_path)
end

main(ARGS)
