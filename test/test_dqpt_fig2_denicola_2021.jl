using Test
using LinearAlgebra
using Plots
using TensorKit

include("../src/DQPTFig2DeNicola2021.jl")
using .DQPTFig2DeNicola2021

function _ket_to_density(psi::AbstractVector{<:Number})
    data = ComplexF64.(collect(psi))
    return data * data'
end

function _product_state_4spin()
    return ComplexF64[1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
end

function _bell_pair_12_tensor_product_34()
    psi12 = ComplexF64[inv(sqrt(2)), 0.0, 0.0, inv(sqrt(2))]
    psi34 = ComplexF64[1.0, 0.0, 0.0, 0.0]
    # Julia's kron + reshape convention makes the first site the fastest index,
    # so the target 1-2 subsystem must appear in the trailing kron factor.
    return kron(psi34, psi12)
end

@testset "Fig2 paper presets" begin
    pdqpt = paper_fig2_preset(:pdqpt)
    @test pdqpt.label == :pdqpt
    @test pdqpt.initial_state == :right
    @test isapprox(pdqpt.Jx, 0.9; atol = 1e-12)
    @test isapprox(pdqpt.Jy, 0.9; atol = 1e-12)
    @test isapprox(pdqpt.Jz, 1.0; atol = 1e-12)
    @test isapprox(pdqpt.hx, 0.1; atol = 1e-12)
    @test isapprox(pdqpt.hz, 1.0; atol = 1e-12)

    edqpt = paper_fig2_preset(:edqpt)
    @test edqpt.label == :edqpt
    @test edqpt.initial_state == :right
    @test isapprox(edqpt.Jx, 0.3; atol = 1e-12)
    @test isapprox(edqpt.Jy, 0.3; atol = 1e-12)
    @test isapprox(edqpt.Jz, 1.0; atol = 1e-12)
    @test isapprox(edqpt.hx, 0.3; atol = 1e-12)
    @test isapprox(edqpt.hz, 0.1; atol = 1e-12)
end

@testset "Fig2 CLI parsing" begin
    parsed = parse_fig2_cli([
        "pdqpt",
        "--steps",
        "8",
        "--dt",
        "0.05",
        "--output-prefix",
        "demo",
        "--backend",
        "tdvp_optimal",
        "--refine-start",
        "1.0",
        "--refine-stop",
        "1.3",
        "--refine-dt",
        "0.01",
    ])
    @test parsed.mode == :pdqpt
    @test parsed.steps == 8
    @test parsed.dt == 0.05
    @test parsed.output_prefix == "demo"
    @test parsed.backend == :tdvp_optimal
    @test parsed.refine_start == 1.0
    @test parsed.refine_stop == 1.3
    @test parsed.refine_dt == 0.01

    defaults = parse_fig2_cli(String[])
    @test defaults.mode == :all
    @test defaults.output_prefix == "dqpt_fig2_denicola_2021"
    @test defaults.backend == :tdvp_optimal
    @test isnothing(defaults.refine_start)
    @test isnothing(defaults.refine_stop)
    @test isnothing(defaults.refine_dt)
end

@testset "Fig2 time-grid refinement helper" begin
    coarse = DQPTFig2DeNicola2021.build_fig2_time_grid(; dt = 0.05, steps = 6)
    @test coarse ≈ collect(0.0:0.05:0.30)

    refined = DQPTFig2DeNicola2021.build_fig2_time_grid(;
        dt = 0.05,
        steps = 6,
        refine_start = 0.10,
        refine_stop = 0.20,
        refine_dt = 0.02,
    )
    @test refined ≈ [0.0, 0.05, 0.10, 0.12, 0.14, 0.16, 0.18, 0.20, 0.25, 0.30]
end

@testset "Fig2 reduced density and mutual information helpers" begin
    rho_prod = _ket_to_density(_product_state_4spin())
    rho1 = partial_trace_sites(rho_prod, [1], 4)
    @test size(rho1) == (2, 2)
    @test rho1 ≈ ComplexF64[1.0 0.0; 0.0 0.0]
    @test isapprox(von_neumann_entropy(rho_prod), 0.0; atol = 1e-12)
    @test isapprox(mutual_information_from_rho(rho_prod, [1], [2], 4), 0.0; atol = 1e-12)

    rho_bell = _ket_to_density(_bell_pair_12_tensor_product_34())
    rho12 = partial_trace_sites(rho_bell, [1, 2], 4)
    @test size(rho12) == (4, 4)
    @test isapprox(tr(rho12), 1.0; atol = 1e-12)
    @test isapprox(mutual_information_from_rho(rho_bell, [1], [2], 4), 2 * log(2); atol = 1e-10)
    @test isapprox(mutual_information_from_rho(rho_bell, [1], [3], 4), 0.0; atol = 1e-10)

    mi = mutual_information_bundle(rho_bell)
    @test keys(mi) == Set(["I12", "I13", "I12_3", "I12_4"])
end

@testset "Fig2 transfer diagnostics helper" begin
    schmidt = DiagonalTensorMap(ComplexF64[0.9, 0.3], ℂ^2)
    gamma = zeros(ComplexF64, 2, 2, 2)
    gamma[1, :, 1] .= ComplexF64[1.0, 0.0]
    gamma[1, :, 2] .= ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    gamma[2, :, 1] .= ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    gamma[2, :, 2] .= ComplexF64[0.0, 1.0]

    ac_data = similar(gamma)
    for i in axes(gamma, 1), sigma in axes(gamma, 2), j in axes(gamma, 3)
        ac_data[i, sigma, j] = schmidt[i, i] * gamma[i, sigma, j]
    end
    ac = TensorMap(ac_data, ℂ^2 ⊗ ℂ^2 ← ℂ^2)

    @test DQPTFig2DeNicola2021._padded_gamma_from_left(ac, schmidt; count = 2) ≈ gamma
end

@testset "Fig2 XXZ smoke tests" begin
    pdqpt = run_fig2_xxz_quench(;
        preset = :pdqpt,
        dt = 0.05,
        steps = 2,
        max_bond = 16,
        cutoff = 1e-8,
    )
    @test pdqpt.preset == :pdqpt
    @test pdqpt.parameters.backend == :tdvp_optimal
    @test length(pdqpt.times) == 3
    @test length(pdqpt.rate) == 3
    @test length(pdqpt.mx) == 3
    @test length(pdqpt.s1) == 3
    @test length(pdqpt.s2) == 3
    @test length(pdqpt.lambda1) == 3
    @test length(pdqpt.lambda2) == 3
    @test length(pdqpt.o11) == 3
    @test length(pdqpt.ood) == 3
    @test length(pdqpt.I12) == 3
    @test length(pdqpt.I13) == 3
    @test length(pdqpt.I12_3) == 3
    @test length(pdqpt.I12_4) == 3
    @test isapprox(pdqpt.rate[1], 0.0; atol = 1e-9)
    @test isapprox(pdqpt.mx[1], 1.0; atol = 1e-9)
    @test isapprox(pdqpt.I12[1], 0.0; atol = 1e-9)
    @test isapprox(pdqpt.I13[1], 0.0; atol = 1e-9)
    @test isapprox(pdqpt.I12_3[1], 0.0; atol = 1e-9)
    @test isapprox(pdqpt.I12_4[1], 0.0; atol = 1e-9)
    @test all(isfinite, pdqpt.rate)
    @test all(isfinite, pdqpt.mx)
    @test all(isfinite, pdqpt.s1)
    @test all(isfinite, pdqpt.s2)
    @test all(isfinite, pdqpt.lambda1)
    @test all(isfinite, pdqpt.lambda2)
    @test all(isfinite, pdqpt.o11)
    @test all(isfinite, pdqpt.ood)
    @test all(isfinite, pdqpt.I12)
    @test all(isfinite, pdqpt.I13)
    @test all(isfinite, pdqpt.I12_3)
    @test all(isfinite, pdqpt.I12_4)

    edqpt = run_fig2_xxz_quench(;
        preset = :edqpt,
        dt = 0.05,
        steps = 2,
        max_bond = 16,
        cutoff = 1e-8,
    )
    @test edqpt.preset == :edqpt
    @test edqpt.parameters.backend == :tdvp_optimal
    @test length(edqpt.times) == 3
    @test isapprox(edqpt.rate[1], 0.0; atol = 1e-9)
    @test isapprox(edqpt.mx[1], 1.0; atol = 1e-9)
    @test isapprox(edqpt.I12[1], 0.0; atol = 1e-9)
    @test isapprox(edqpt.I13[1], 0.0; atol = 1e-9)
    @test isapprox(edqpt.I12_3[1], 0.0; atol = 1e-9)
    @test isapprox(edqpt.I12_4[1], 0.0; atol = 1e-9)
    @test all(isfinite, edqpt.rate)
    @test all(isfinite, edqpt.mx)
    @test all(isfinite, edqpt.s1)
    @test all(isfinite, edqpt.s2)
    @test all(isfinite, edqpt.lambda1)
    @test all(isfinite, edqpt.lambda2)
    @test all(isfinite, edqpt.o11)
    @test all(isfinite, edqpt.ood)
    @test all(isfinite, edqpt.I12)
    @test all(isfinite, edqpt.I13)
    @test all(isfinite, edqpt.I12_3)
    @test all(isfinite, edqpt.I12_4)

    tdvp = run_fig2_xxz_quench(;
        preset = :pdqpt,
        dt = 0.05,
        steps = 2,
        max_bond = 16,
        cutoff = 1e-8,
        backend = :tdvp_optimal,
    )
    @test tdvp.parameters.backend == :tdvp_optimal
    @test length(tdvp.times) == 3
    @test isapprox(tdvp.rate[1], 0.0; atol = 1e-9)
    @test isapprox(tdvp.mx[1], 1.0; atol = 1e-9)
    @test all(isfinite, tdvp.rate)
    @test all(isfinite, tdvp.mx)
    @test all(isfinite, tdvp.o11)
    @test all(isfinite, tdvp.ood)
    @test maximum(tdvp.o11) <= 1 + 1e-9

    refined = run_fig2_xxz_quench(;
        preset = :edqpt,
        dt = 0.05,
        steps = 4,
        refine_start = 0.05,
        refine_stop = 0.10,
        refine_dt = 0.025,
        max_bond = 8,
        cutoff = 1e-8,
        backend = :wii_svdcut,
    )
    @test refined.times ≈ [0.0, 0.05, 0.075, 0.10, 0.15, 0.20]
    @test length(refined.rate) == length(refined.times)
    @test length(refined.mx) == length(refined.times)
    @test refined.parameters.backend == :wii_svdcut
end

@testset "Fig2 output and plotting helpers" begin
    paths = planned_fig2_output_paths(; output_root = "outputs", figure_root = "figures/report")
    @test occursin("outputs/fig2_pdqpt_denicola_2021.tsv", paths[:pdqpt_tsv])
    @test occursin("outputs/fig2_edqpt_denicola_2021.tsv", paths[:edqpt_tsv])
    @test occursin("figures/report/dqpt_fig2_denicola_2021.png", paths[:figure])
    @test occursin("figures/report/dqpt_fig2_xxz_audit_denicola_2021.png", paths[:audit_figure])

    mock = (
        preset = :pdqpt,
        times = [0.0, 0.1],
        rate = [0.0, 0.2],
        mx = [1.0, 0.8],
        s1 = [1.0, 0.9],
        s2 = [0.0, 0.2],
        s3 = [0.0, 0.05],
        s4 = [0.0, 0.01],
        lambda1 = [1.0, 0.81],
        lambda2 = [0.0, 0.04],
        lambda3 = [0.0, 0.0025],
        lambda4 = [0.0, 0.0001],
        o11 = [1.0, 0.3],
        ood = [0.0, 0.7],
        tf1 = ComplexF64[1.0 + 0.0im, 0.8 + 0.1im],
        tf2 = ComplexF64[0.0 + 0.0im, 0.2 - 0.1im],
        tf1_abs = [1.0, hypot(0.8, 0.1)],
        tf2_abs = [0.0, hypot(0.2, 0.1)],
        I12 = [0.0, 0.1],
        I13 = [0.0, 0.05],
        I12_3 = [0.0, 0.12],
        I12_4 = [0.0, 0.08],
    )

    path, io = mktemp()
    close(io)
    save_fig2_result(mock, path)
    table = load_fig2_table(path)
    @test haskey(table, "time")
    @test haskey(table, "mx")
    @test haskey(table, "lambda4")
    @test haskey(table, "tf2_im")
    @test haskey(table, "I12_4")
    @test table["o11"] ≈ mock.o11
    @test table["I12_3"] ≈ mock.I12_3

    main_fig = build_fig2_plot(table, table)
    audit_fig = build_fig2_audit_plot(table, table)
    @test main_fig isa Plots.Plot
    @test audit_fig isa Plots.Plot
end
