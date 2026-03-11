using Test
using TensorKit
using Plots

include("../src/DQPTPRL2021.jl")
using .DQPTPRL2021
include("../src/DQPTPlots.jl")
using .DQPTPlots

@testset "Helper smoke tests" begin
    @test isapprox(loschmidt_rate_infinite(1.0 + 0.0im), 0.0; atol = 1e-12)

    tmpdir = joinpath(@__DIR__, "tmp-output")
    ensure_dir(tmpdir)
    @test isdir(tmpdir)

    psi = build_two_site_product_state([1.0 + 0im, 0.0 + 0im], [0.0 + 0im, 1.0 + 0im])
    @test length(psi) == 2
end

@testset "CLI parsing" begin
    parsed = parse_cli(["ising", "--steps", "5", "--dt", "0.2", "--output-prefix", "demo"])
    @test parsed.mode == :ising
    @test parsed.steps == 5
    @test parsed.dt == 0.2
    @test parsed.output_prefix == "demo"

    defaults = parse_cli(String[])
    @test defaults.mode == :all
    @test defaults.output_prefix == "dqpt_prl_2021"
end

@testset "Plot helper parsing" begin
    ising_data = load_tsv_table(joinpath(@__DIR__, "..", "outputs", "refine_ising.tsv"))
    @test haskey(ising_data, "time")
    @test haskey(ising_data, "rate")
    @test length(ising_data["time"]) > 10

    analysis_paths = planned_figure_paths(:analysis; root = joinpath(@__DIR__, "..", "figures"))
    @test haskey(analysis_paths, :ising_diagnostics)
    @test haskey(analysis_paths, :xxz_diagnostics)
    @test haskey(analysis_paths, :comparison_overview)
    @test !haskey(analysis_paths, :dqpt_qualitative_comparison)

    all_paths = planned_figure_paths(:all; root = joinpath(@__DIR__, "..", "figures"))
    @test haskey(all_paths, :dqpt_qualitative_comparison)
    @test occursin("figures/report/dqpt_qualitative_comparison.png", all_paths[:dqpt_qualitative_comparison])
end

@testset "Plot output planning" begin
    paths = planned_figure_paths(:all; root = joinpath(@__DIR__, "..", "figures"))
    @test occursin("figures/analysis/ising_diagnostics.png", paths[:ising_diagnostics])
    @test occursin("figures/analysis/xxz_diagnostics.png", paths[:xxz_diagnostics])
    @test occursin("figures/analysis/comparison_overview.png", paths[:comparison_overview])
    @test occursin("figures/report/dqpt_qualitative_comparison.png", paths[:dqpt_qualitative_comparison])
end

@testset "Plot bundle build" begin
    ising_data = load_tsv_table(joinpath(@__DIR__, "..", "outputs", "refine_ising.tsv"))
    xxz_data = load_tsv_table(joinpath(@__DIR__, "..", "outputs", "medium_xxz.tsv"))
    figures = build_figure_bundle(ising_data, xxz_data; style = :all)
    @test figures[:ising_diagnostics] isa Plots.Plot
    @test figures[:xxz_diagnostics] isa Plots.Plot
    @test figures[:comparison_overview] isa Plots.Plot
    @test figures[:dqpt_qualitative_comparison] isa Plots.Plot
end

@testset "Ising baseline smoke test" begin
    result = run_ising_baseline(;
        dt = 0.1,
        steps = 2,
        bond_dim = 8,
        grow_steps = 1,
        grow_by = 1,
        vumps_maxiter = 20,
        vumps_tol = 1e-6,
    )
    @test length(result.times) == 3
    @test length(result.rate) == 3
    @test isapprox(result.rate[1], 0.0; atol = 1e-9)
    @test any(x -> abs(x) > 1e-8, result.rate[2:end])
end

@testset "XXZ Neel smoke test" begin
    result = run_xxz_neel_protocol(; dt = 0.1, steps = 1, delta = 1.2, grow_steps = 1, grow_by = 1)
    @test length(result.times) == 2
    @test length(result.entropies) == 2
    @test all(isfinite, result.rate)
    @test all(isfinite, result.entropies)
    @test length(result.state_unit_cell) == 2
end
