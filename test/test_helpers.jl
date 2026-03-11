using Test
using TensorKit

include("../src/DQPTPRL2021.jl")
using .DQPTPRL2021

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
