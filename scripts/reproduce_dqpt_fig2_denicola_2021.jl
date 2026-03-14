include("../src/DQPTFig2DeNicola2021.jl")

using .DQPTFig2DeNicola2021

cli = parse_fig2_cli(ARGS)
paths = planned_fig2_output_paths()

function _run_and_save(preset::Symbol, path::AbstractString, cli)
    cfg = paper_fig2_preset(preset)
    steps = isnothing(cli.steps) ? round(Int, cfg.tmax / cli.dt) : cli.steps
    result = run_fig2_xxz_quench(;
        preset = preset,
        dt = cli.dt,
        steps = steps,
        max_bond = cli.max_bond,
        cutoff = cli.cutoff,
    )
    save_fig2_result(result, path)
    println("saved ", preset, " dataset -> ", path)
end

if cli.mode in (:pdqpt, :all)
    _run_and_save(:pdqpt, paths[:pdqpt_tsv], cli)
end

if cli.mode in (:edqpt, :all)
    _run_and_save(:edqpt, paths[:edqpt_tsv], cli)
end
