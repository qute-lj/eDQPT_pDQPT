include(joinpath(@__DIR__, "..", "src", "DQPTPRL2021.jl"))

using .DQPTPRL2021

function parse_projection_cli(args::Vector{String})
    isempty(args) && throw(ArgumentError("expected protocol: ising_p | ising_e | xxz_p | xxz_e"))

    protocol = Symbol(args[1])
    nsites = 8
    boundary = :open
    output_prefix = string(protocol) * "_projection"

    i = 2
    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--length"
            nsites = parse(Int, value)
        elseif key == "--boundary"
            boundary = Symbol(value)
        elseif key == "--output-prefix"
            output_prefix = value
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    return (protocol = protocol, length = nsites, boundary = boundary, output_prefix = output_prefix)
end

function main(args)
    cfg = parse_projection_cli(args)
    outdir = ensure_dir(joinpath(@__DIR__, "..", "outputs"))
    result = run_prl2021_esqpt_projection(cfg.protocol; length = cfg.length, boundary = cfg.boundary)

    tsv_path = joinpath(outdir, cfg.output_prefix * "_projection.tsv")
    summary_path = joinpath(outdir, cfg.output_prefix * "_projection_summary.md")

    save_prl2021_esqpt_projection(result, tsv_path)
    write_prl2021_esqpt_projection_summary(result, summary_path)

    println("projection tsv: " * tsv_path)
    println("projection summary: " * summary_path)
end

main(ARGS)
