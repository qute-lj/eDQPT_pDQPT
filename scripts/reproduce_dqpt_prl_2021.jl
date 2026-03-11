include(joinpath(@__DIR__, "..", "src", "DQPTPRL2021.jl"))

using .DQPTPRL2021

function summarize(name, result, path)
    println(name * ": " * path)
    println("  max rate     = " * string(maximum(result.rate)))
    println("  max entropy  = " * string(maximum(result.entropies)))
end

function main(args)
    cfg = parse_cli(args)
    outdir = ensure_dir(joinpath(@__DIR__, "..", "outputs"))

    if cfg.mode in (:ising, :all)
        ising = run_ising_baseline(;
            dt = cfg.dt,
            steps = cfg.steps,
            g0 = cfg.g0,
            g1 = cfg.g1,
            bond_dim = cfg.bond_dim,
            grow_steps = cfg.grow_steps,
            grow_by = cfg.grow_by,
            vumps_maxiter = cfg.vumps_maxiter,
            vumps_tol = cfg.vumps_tol,
        )
        ising_path = joinpath(outdir, cfg.output_prefix * "_ising.tsv")
        save_ising_result(ising, ising_path)
        summarize("ising", ising, ising_path)
    end

    if cfg.mode in (:xxz, :all)
        xxz = run_xxz_neel_protocol(;
            dt = cfg.dt,
            steps = cfg.steps,
            delta = cfg.delta,
            grow_steps = cfg.grow_steps,
            grow_by = cfg.grow_by,
        )
        xxz_path = joinpath(outdir, cfg.output_prefix * "_xxz.tsv")
        save_xxz_result(xxz, xxz_path)
        summarize("xxz", xxz, xxz_path)
    end
end

main(ARGS)
