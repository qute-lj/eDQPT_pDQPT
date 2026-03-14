include("../src/DQPTFig2DeNicola2021.jl")

using .DQPTFig2DeNicola2021
using Plots

paths = planned_fig2_output_paths()

pdqpt_table = load_fig2_table(paths[:pdqpt_tsv])
edqpt_table = load_fig2_table(paths[:edqpt_tsv])

main_fig = build_fig2_plot(pdqpt_table, edqpt_table)
audit_fig = build_fig2_audit_plot(pdqpt_table, edqpt_table)

mkpath(dirname(paths[:figure]))
savefig(main_fig, paths[:figure])
savefig(audit_fig, paths[:audit_figure])

println("saved fig2 figure -> ", paths[:figure])
println("saved fig2 audit figure -> ", paths[:audit_figure])
