using Test
using LinearAlgebra
using Plots
using TensorKit

include("../src/DQPTFig1DeNicola2021.jl")
using .DQPTFig1DeNicola2021

@testset "Fig1 paper presets" begin
    pdqpt = paper_fig1_preset(:pdqpt)
    @test pdqpt.label == :pdqpt
    @test pdqpt.initial_state == :down
    @test isapprox(pdqpt.J, 0.1; atol = 1e-12)
    @test isapprox(pdqpt.hx, 1.0; atol = 1e-12)
    @test isapprox(pdqpt.hz, 0.15; atol = 1e-12)

    edqpt = paper_fig1_preset(:edqpt)
    @test edqpt.label == :edqpt
    @test edqpt.initial_state == :right
    @test isapprox(edqpt.J, 1.0; atol = 1e-12)
    @test isapprox(edqpt.hx, 0.1; atol = 1e-12)
    @test isapprox(edqpt.hz, 0.15; atol = 1e-12)
end

@testset "Fig1 local state builders" begin
    down = build_local_spinor(:down)
    @test length(down) == 2
    @test isapprox(norm(down), 1.0; atol = 1e-12)
    @test down == ComplexF64[0.0, 1.0]

    right = build_local_spinor(:right)
    @test length(right) == 2
    @test isapprox(norm(right), 1.0; atol = 1e-12)
    @test isapprox(abs2(right[1]), 0.5; atol = 1e-12)
    @test isapprox(abs2(right[2]), 0.5; atol = 1e-12)

    psi = build_single_site_product_state(right)
    @test length(psi) == 1
end

@testset "Fig1 CLI parsing" begin
    parsed = parse_fig1_cli([
        "pdqpt",
        "--steps",
        "5",
        "--dt",
        "0.02",
        "--output-prefix",
        "demo",
    ])
    @test parsed.mode == :pdqpt
    @test parsed.steps == 5
    @test parsed.dt == 0.02
    @test parsed.output_prefix == "demo"

    defaults = parse_fig1_cli(String[])
    @test defaults.mode == :all
    @test defaults.output_prefix == "dqpt_fig1_denicola_2021"
end

@testset "Fig1 fidelity-transfer diagnostics" begin
    schmidt = DiagonalTensorMap(ComplexF64[0.9, 0.3], ℂ^2)
    gamma = zeros(ComplexF64, 2, 2, 2)
    gamma[1, :, 1] .= ComplexF64[1.0, 0.0]
    gamma[1, :, 2] .= ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    gamma[2, :, 1] .= ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    gamma[2, :, 2] .= ComplexF64[0.0, 1.0]

    al_data = similar(gamma)
    for i in axes(gamma, 1), sigma in axes(gamma, 2), j in axes(gamma, 3)
        al_data[i, sigma, j] = schmidt[i, i] * gamma[i, sigma, j]
    end
    al = TensorMap(al_data, ℂ^2 ⊗ ℂ^2 ← ℂ^2)

    recovered = canonical_gamma_from_left(al, schmidt; count = 2)
    @test recovered ≈ gamma

    singular_values = leading_singular_values(schmidt; count = 2)
    @test singular_values ≈ [0.9, 0.3]

    entanglement_weights = leading_entanglement_spectrum(schmidt; count = 2)
    @test entanglement_weights ≈ [0.81, 0.09]

    overlaps = overlap_matrix(recovered, ComplexF64[1.0, 0.0]; count = 2)
    expected_overlaps = ComplexF64[
        1.0 inv(sqrt(2));
        inv(sqrt(2)) 0.0;
    ]
    @test overlaps ≈ expected_overlaps

    transfer = fidelity_transfer_matrix(singular_values, overlaps)
    expected_transfer = Diagonal(ComplexF64[0.9, 0.3]) * expected_overlaps
    @test transfer ≈ expected_transfer

    eigs = leading_transfer_eigenvalues(transfer; count = 2)
    expected_eigs = sort(collect(eigvals(expected_transfer)); by = value -> -abs(value))
    @test eigs ≈ expected_eigs
    @test abs(eigs[1]) >= abs(eigs[2])
end

@testset "Fig1 Ising smoke tests" begin
    pdqpt = run_fig1_ising_quench(;
        preset = :pdqpt,
        dt = 0.1,
        steps = 2,
        grow_steps = 2,
        grow_by = 1,
    )
    @test pdqpt.preset == :pdqpt
    @test length(pdqpt.times) == 3
    @test length(pdqpt.rate) == 3
    @test length(pdqpt.s1) == 3
    @test length(pdqpt.s2) == 3
    @test length(pdqpt.lambda1) == 3
    @test length(pdqpt.lambda2) == 3
    @test length(pdqpt.o11) == 3
    @test length(pdqpt.ood) == 3
    @test length(pdqpt.tf1_abs) == 3
    @test length(pdqpt.tf2_abs) == 3
    @test isapprox(pdqpt.rate[1], 0.0; atol = 1e-9)
    @test all(isfinite, pdqpt.rate)
    @test all(isfinite, pdqpt.s1)
    @test all(isfinite, pdqpt.s2)
    @test all(isfinite, pdqpt.lambda1)
    @test all(isfinite, pdqpt.lambda2)
    @test all(isfinite, pdqpt.o11)
    @test all(isfinite, pdqpt.ood)
    @test all(isfinite, pdqpt.tf1_abs)
    @test all(isfinite, pdqpt.tf2_abs)

    edqpt = run_fig1_ising_quench(;
        preset = :edqpt,
        dt = 0.1,
        steps = 2,
        grow_steps = 2,
        grow_by = 1,
    )
    @test edqpt.preset == :edqpt
    @test length(edqpt.times) == 3
    @test length(edqpt.rate) == 3
    @test all(isfinite, edqpt.rate)
    @test all(isfinite, edqpt.s1)
    @test all(isfinite, edqpt.s2)
    @test all(isfinite, edqpt.lambda1)
    @test all(isfinite, edqpt.lambda2)
    @test all(isfinite, edqpt.o11)
    @test all(isfinite, edqpt.ood)
    @test all(isfinite, edqpt.tf1_abs)
    @test all(isfinite, edqpt.tf2_abs)
end

@testset "Fig1 output and plotting helpers" begin
    paths = planned_fig1_output_paths(; output_root = "outputs", figure_root = "figures/report")
    @test occursin("outputs/fig1_pdqpt_denicola_2021.tsv", paths[:pdqpt_tsv])
    @test occursin("outputs/fig1_edqpt_denicola_2021.tsv", paths[:edqpt_tsv])
    @test occursin("figures/report/dqpt_fig1_pdqpt_denicola_2021.png", paths[:pdqpt_figure])
    @test occursin("figures/report/dqpt_fig1_edqpt_denicola_2021.png", paths[:edqpt_figure])

    mock = (
        preset = :pdqpt,
        times = [0.0, 0.1],
        rate = [0.0, 0.2],
        s1 = [1.0, 0.9],
        s2 = [0.0, 0.2],
        lambda1 = [1.0, 0.81],
        lambda2 = [0.0, 0.04],
        o11 = [1.0, 0.3],
        ood = [0.0, 0.7],
        tf1 = ComplexF64[1.0 + 0.0im, 0.8 + 0.1im],
        tf2 = ComplexF64[0.0 + 0.0im, 0.2 - 0.1im],
        tf1_abs = [1.0, hypot(0.8, 0.1)],
        tf2_abs = [0.0, hypot(0.2, 0.1)],
    )

    path, io = mktemp()
    close(io)
    save_fig1_result(mock, path)
    table = load_fig1_table(path)
    @test haskey(table, "time")
    @test haskey(table, "tf1_re")
    @test haskey(table, "tf2_im")
    @test table["o11"] ≈ mock.o11
    @test table["tf1_abs"] ≈ mock.tf1_abs

    fig = build_fig1_plot(table; preset = :pdqpt)
    @test fig isa Plots.Plot
end
