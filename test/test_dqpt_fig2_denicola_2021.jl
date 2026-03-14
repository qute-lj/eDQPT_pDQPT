using Test
using LinearAlgebra

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
    ])
    @test parsed.mode == :pdqpt
    @test parsed.steps == 8
    @test parsed.dt == 0.05
    @test parsed.output_prefix == "demo"

    defaults = parse_fig2_cli(String[])
    @test defaults.mode == :all
    @test defaults.output_prefix == "dqpt_fig2_denicola_2021"
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
