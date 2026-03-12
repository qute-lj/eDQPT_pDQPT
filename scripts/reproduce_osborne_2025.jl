include(joinpath(@__DIR__, "..", "src", "DQPTOsborne2025.jl"))

using .DQPTOsborne2025

function summarize(result, path)
    peak_index = argmax(result.rate)
    classification = classify_dqpt_event(result.mz, peak_index)
    println("osborne2025: " * path)
    println("  backend      = " * string(result.parameters.backend))
    println("  peak time    = " * string(result.times[peak_index]))
    println("  peak rate    = " * string(result.rate[peak_index]))
    println("  classification = " * string(classification))
    println("  max entropy  = " * string(maximum(result.entropy)))
    println("  energy drift = " * string(result.energy_drift))
    println("  max bond     = " * string(maximum(result.max_bond)))
    println("  final mz     = " * string(last(result.mz)))
end

function main(args)
    cfg = parse_osborne_cli(args)
    outdir = ensure_dir(joinpath(@__DIR__, "..", "outputs"))

    if cfg.mode == :compare
        low_hz, high_hz = DQPTOsborne2025._ordered_hz_pair(cfg.hz, cfg.compare_hz)

        low_result = run_osborne_quench(;
            backend = cfg.backend,
            length = cfg.length,
            steps = cfg.steps,
            dt = cfg.dt,
            J = cfg.J,
            g = cfg.g,
            alpha = cfg.alpha,
            hz = low_hz,
            bond_dim = cfg.bond_dim,
        )
        high_result = run_osborne_quench(;
            backend = cfg.backend,
            length = cfg.length,
            steps = cfg.steps,
            dt = cfg.dt,
            J = cfg.J,
            g = cfg.g,
            alpha = cfg.alpha,
            hz = high_hz,
            bond_dim = cfg.bond_dim,
        )

        low_path = joinpath(outdir, cfg.output_prefix * "_low_" * String(cfg.backend) * ".tsv")
        high_path = joinpath(outdir, cfg.output_prefix * "_high_" * String(cfg.backend) * ".tsv")
        summary_path = joinpath(outdir, cfg.output_prefix * "_" * String(cfg.backend) * "_summary.md")

        save_osborne_result(low_result, low_path)
        save_osborne_result(high_result, high_path)
        summarize_osborne_regimes(
            [low_result, high_result],
            ["lower confinement (hz=$(low_hz))", "higher confinement (hz=$(high_hz))"],
            summary_path,
        )

        summarize(low_result, low_path)
        summarize(high_result, high_path)
        println("osborne2025 summary: " * summary_path)
        return
    end

    result = run_osborne_quench(;
        backend = cfg.backend,
        length = cfg.length,
        steps = cfg.steps,
        dt = cfg.dt,
        J = cfg.J,
        g = cfg.g,
        alpha = cfg.alpha,
        hz = cfg.hz,
        bond_dim = cfg.bond_dim,
    )
    path = joinpath(outdir, cfg.output_prefix * "_" * String(cfg.backend) * ".tsv")
    save_osborne_result(result, path)
    summarize(result, path)
end

main(ARGS)
