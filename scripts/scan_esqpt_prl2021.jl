include(joinpath(@__DIR__, "..", "src", "DQPTPRL2021.jl"))

using .DQPTPRL2021

function main(args)
    cfg = parse_esqpt_cli(args)
    outdir = ensure_dir(joinpath(@__DIR__, "..", "outputs"))
    scan = run_esqpt_scan(cfg)

    spectrum_path = joinpath(outdir, cfg.output_prefix * "_esqpt_spectrum.tsv")
    summary_path = joinpath(outdir, cfg.output_prefix * "_esqpt_summary.md")

    save_esqpt_spectrum(scan, spectrum_path)
    write_esqpt_summary(scan, summary_path)

    println("esqpt spectrum: " * spectrum_path)
    println("esqpt summary: " * summary_path)
end

main(ARGS)
