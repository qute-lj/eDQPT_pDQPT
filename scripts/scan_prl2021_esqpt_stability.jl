include(joinpath(@__DIR__, "..", "src", "DQPTPRL2021.jl"))

using .DQPTPRL2021

function _parse_csv_ints(value::AbstractString)
    return parse.(Int, split(value, ','))
end

function _parse_csv_symbols(value::AbstractString)
    return Symbol.(split(value, ','))
end

function parse_stability_cli(args::Vector{String})
    isempty(args) && throw(ArgumentError("expected protocol: ising_p | ising_e | xxz_p | xxz_e"))

    protocol = Symbol(args[1])
    lengths = [4, 6, 8]
    boundaries = [:open, :periodic]
    output_prefix = string(protocol) * "_stability"

    i = 2
    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--lengths"
            lengths = _parse_csv_ints(value)
        elseif key == "--boundaries"
            boundaries = _parse_csv_symbols(value)
        elseif key == "--output-prefix"
            output_prefix = value
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    return (
        protocol = protocol,
        lengths = lengths,
        boundaries = boundaries,
        output_prefix = output_prefix,
    )
end

function main(args)
    cfg = parse_stability_cli(args)
    outdir = ensure_dir(joinpath(@__DIR__, "..", "outputs"))
    result = run_prl2021_esqpt_stability_scan(
        cfg.protocol;
        lengths = cfg.lengths,
        boundaries = cfg.boundaries,
    )

    tsv_path = joinpath(outdir, cfg.output_prefix * "_stability.tsv")
    summary_path = joinpath(outdir, cfg.output_prefix * "_stability_summary.md")

    save_prl2021_esqpt_stability_scan(result, tsv_path)
    write_prl2021_esqpt_stability_summary(result, summary_path)

    println("stability tsv: " * tsv_path)
    println("stability summary: " * summary_path)
end

main(ARGS)
