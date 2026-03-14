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

@testset "ESQPT spectral helper tests" begin
    H = build_dense_ising_hamiltonian(3; J = 1.0, hx = 0.2, hz = 0.1, boundary = :open)
    @test size(H) == (8, 8)
    @test H ≈ H'

    scan = run_ising_esqpt_scan(; length = 4, J = 1.0, hx = 0.1, hz = 0.15, boundary = :open)
    @test issorted(scan.energies)
    @test length(scan.energies) == 16
    @test length(scan.density_proxy) == length(scan.energies)
    @test length(scan.observable) == length(scan.energies)
    @test length(scan.ipr) == length(scan.energies)
    @test all(isfinite, scan.density_proxy)
    @test all(isfinite, scan.observable)
    @test all(isfinite, scan.ipr)
end

@testset "ESQPT parser and summary tests" begin
    parsed = parse_esqpt_cli(["ising", "--length", "6", "--output-prefix", "demo"])
    @test parsed.model == :ising
    @test parsed.length == 6
    @test parsed.output_prefix == "demo"

    tmpdir = mktempdir()
    summary_path = joinpath(tmpdir, "summary.md")
    spectrum_path = joinpath(tmpdir, "spectrum.tsv")
    scan = (
        model = :ising,
        observable_name = "mx",
        energies = [-1.0, 0.0, 1.0],
        density_proxy = [1.0, 3.0, 1.0],
        observable = [0.6, 0.1, -0.4],
        ipr = [0.8, 0.4, 0.8],
        parameters = (length = 3, boundary = :open, J = 1.0, hx = 0.1, hz = 0.15),
    )

    save_esqpt_spectrum(scan, spectrum_path)
    write_esqpt_summary(scan, summary_path)

    summary_text = read(summary_path, String)
    @test isfile(spectrum_path)
    @test occursin("finite-size spectral ESQPT diagnostics", summary_text)
    @test occursin("does not identify eDQPT as ESQPT", summary_text)
    @test occursin("candidate_density_energy", summary_text)
end

@testset "ESQPT dispatcher tests" begin
    ising_scan = run_esqpt_scan(parse_esqpt_cli(["ising", "--length", "4"]))
    @test ising_scan.model == :ising
    @test length(ising_scan.energies) == 16

    xxz_scan = run_esqpt_scan(parse_esqpt_cli(["xxz", "--length", "4"]))
    @test xxz_scan.model == :xxz
    @test length(xxz_scan.energies) == 16
end

@testset "PRL 2021 quench projection tests" begin
    projection = run_prl2021_esqpt_projection(:ising_p; length = 4, boundary = :open)
    @test projection.protocol == :ising_p
    @test isapprox(sum(projection.weights), 1.0; atol = 1e-10)
    @test isfinite(projection.mean_energy)
    @test isfinite(projection.energy_std)
    @test 0.0 <= projection.candidates.density.nearest3_weight <= 1.0
    @test 0.0 <= projection.candidates.observable.nearest3_weight <= 1.0
    @test 0.0 <= projection.candidates.ipr.nearest3_weight <= 1.0

    tmpdir = mktempdir()
    projection_tsv = joinpath(tmpdir, "projection.tsv")
    projection_md = joinpath(tmpdir, "projection.md")
    save_prl2021_esqpt_projection(projection, projection_tsv)
    write_prl2021_esqpt_projection_summary(projection, projection_md)
    projection_text = read(projection_md, String)
    @test isfile(projection_tsv)
    @test occursin("quench-energy distribution", projection_text)
    @test occursin("density_nearest3_weight", projection_text)
end

@testset "PRL 2021 stability scan tests" begin
    stability = run_prl2021_esqpt_stability_scan(
        :xxz_e;
        lengths = [4, 6],
        boundaries = [:open, :periodic],
    )
    @test stability.protocol == :xxz_e
    @test length(stability.rows) == 4
    @test all(row -> row.length in (4, 6), stability.rows)
    @test all(row -> row.boundary in (:open, :periodic), stability.rows)

    tmpdir = mktempdir()
    stability_tsv = joinpath(tmpdir, "stability.tsv")
    stability_md = joinpath(tmpdir, "stability.md")
    save_prl2021_esqpt_stability_scan(stability, stability_tsv)
    write_prl2021_esqpt_stability_summary(stability, stability_md)
    stability_text = read(stability_md, String)
    @test isfile(stability_tsv)
    @test occursin("energy_per_site_span", stability_text)
    @test occursin("boundary = open", stability_text)
end

@testset "PRL 2021 finite DQPT comparison tests" begin
    dqpt = run_prl2021_finite_dqpt(:ising_e; length = 4, dt = 0.1, steps = 6, boundary = :open)
    @test dqpt.protocol == :ising_e
    @test length(dqpt.times) == 7
    @test length(dqpt.rate) == 7
    @test isapprox(dqpt.rate[1], 0.0; atol = 1e-10)
    @test all(isfinite, dqpt.rate)
    @test dqpt.peak_index >= 2

    comparison = run_prl2021_dqpt_esqpt_comparison(
        :xxz_p;
        length = 4,
        dt = 0.1,
        steps = 6,
        boundary = :open,
    )
    @test comparison.protocol == :xxz_p
    @test isfinite(comparison.dqpt.peak_time)
    @test comparison.esqpt_best_label in ("density", "observable", "ipr")
    @test 0.0 <= comparison.esqpt_best_weight <= 1.0

    tmpdir = mktempdir()
    dqpt_path = joinpath(tmpdir, "dqpt.tsv")
    comparison_path = joinpath(tmpdir, "comparison.md")
    save_prl2021_finite_dqpt(dqpt, dqpt_path)
    write_prl2021_dqpt_esqpt_comparison_summary(comparison, comparison_path)
    comparison_text = read(comparison_path, String)
    @test isfile(dqpt_path)
    @test occursin("best_esqpt_overlap", comparison_text)
    @test occursin("dqpt_peak_time", comparison_text)
end
