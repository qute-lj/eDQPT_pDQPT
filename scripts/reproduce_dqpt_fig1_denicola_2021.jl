include("../src/DQPTFig1DeNicola2021.jl")

using .DQPTFig1DeNicola2021

function result_path(mode::Symbol, output_prefix::AbstractString)
    if output_prefix == "dqpt_fig1_denicola_2021"
        paths = planned_fig1_output_paths()
        return mode == :pdqpt ? paths[:pdqpt_tsv] : paths[:edqpt_tsv]
    end
    return joinpath("outputs", "$(output_prefix)_$(mode).tsv")
end

cfg = parse_fig1_cli(ARGS)

for mode in (:pdqpt, :edqpt)
    cfg.mode in (mode, :all) || continue
    result = run_fig1_ising_quench(; preset = mode, dt = cfg.dt, steps = cfg.steps)
    path = result_path(mode, cfg.output_prefix)
    save_fig1_result(result, path)
    println("saved ", mode, " -> ", path)
end
