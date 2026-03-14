using Test

include("../src/DQPTFig2DeNicola2021.jl")
using .DQPTFig2DeNicola2021

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
