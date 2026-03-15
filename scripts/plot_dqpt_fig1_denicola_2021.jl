include("../src/DQPTFig1DeNicola2021.jl")

using .DQPTFig1DeNicola2021
using Plots

paths = planned_fig1_output_paths()

pdqpt_table = load_fig1_table(paths[:pdqpt_tsv])
edqpt_table = load_fig1_table(paths[:edqpt_tsv])

pdqpt_plot = build_fig1_plot(pdqpt_table; preset = :pdqpt)
edqpt_plot = build_fig1_plot(edqpt_table; preset = :edqpt)

mkpath(dirname(paths[:pdqpt_figure]))
savefig(pdqpt_plot, paths[:pdqpt_figure])
savefig(edqpt_plot, paths[:edqpt_figure])

println("saved pdqpt figure -> ", paths[:pdqpt_figure])
println("saved edqpt figure -> ", paths[:edqpt_figure])
