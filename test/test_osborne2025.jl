using Test
using MPSKit

include("../src/DQPTOsborne2025.jl")
using .DQPTOsborne2025:
    finite_loschmidt_rate,
    parse_osborne_cli,
    build_polarized_state,
    build_osborne_hamiltonian,
    run_osborne_quench,
    classify_dqpt_event,
    summarize_osborne_regimes

@testset "Osborne helper parsing" begin
    @test isapprox(finite_loschmidt_rate(1.0 + 0.0im, 8), 0.0; atol = 1e-12)

    cfg = parse_osborne_cli([
        "--backend",
        "proxy",
        "--length",
        "10",
        "--steps",
        "4",
        "--dt",
        "0.1",
    ])
    @test cfg.backend == :proxy
    @test cfg.length == 10
    @test cfg.steps == 4
    @test cfg.dt == 0.1

    compare_cfg = parse_osborne_cli(["compare", "--hz", "0.6", "--compare-hz", "0.2"])
    @test compare_cfg.mode == :compare
    @test DQPTOsborne2025._ordered_hz_pair(compare_cfg.hz, compare_cfg.compare_hz) == (0.2, 0.6)
end

@testset "Osborne state and Hamiltonian builders" begin
    psi = build_polarized_state(6; up = true)
    @test length(psi) == 6

    Hlong = build_osborne_hamiltonian(:longrange, 6; J = 1.0, g = 0.7, alpha = 3.0, hz = 0.0)
    Hproxy = build_osborne_hamiltonian(:proxy, 6; J = 1.0, g = 0.7, alpha = 3.0, hz = 0.2)
    @test Hlong isa FiniteMPOHamiltonian
    @test Hproxy isa FiniteMPOHamiltonian
end

@testset "Osborne quench smoke test" begin
    result = run_osborne_quench(;
        backend = :proxy,
        length = 6,
        steps = 2,
        dt = 0.1,
        J = 1.0,
        g = 0.7,
        alpha = 3.0,
        hz = 0.2,
        bond_dim = 8,
    )

    @test length(result.times) == 3
    @test length(result.rate) == 3
    @test length(result.entropy) == 3
    @test length(result.mz) == 3
    @test length(result.energy) == 3
    @test length(result.max_bond) == 3
    @test isapprox(result.rate[1], 0.0; atol = 1e-9)
    @test all(isfinite, result.rate)
    @test all(isfinite, result.entropy)
    @test all(isfinite, result.energy)
    @test all(>=(1), result.max_bond)
    @test result.energy_drift >= 0.0
end

@testset "Osborne regime classification" begin
    @test classify_dqpt_event([0.4, 0.1, -0.2], 2) == :manifold
    @test classify_dqpt_event([0.4, 0.2, 0.1], 2) == :branch

    path, io = mktemp()
    close(io)
    result = (
        times = [0.0, 0.1, 0.2],
        rate = [0.1, 0.4, 0.2],
        entropy = [0.0, 0.0, 0.0],
        mz = [0.4, 0.1, -0.2],
        energy = [-1.0, -1.0, -1.0],
        max_bond = [1, 2, 2],
        energy_drift = 0.0,
    )
    summarize_osborne_regimes([result], ["proxy-low"], path)
    text = read(path, String)
    @test occursin("# Osborne 2025 Regime Summary", text)
    @test occursin("## proxy-low", text)
    @test occursin("classification = manifold", text)
    @test occursin("energy_drift = 0.0", text)
    @test occursin("max_allocated_bond = 2", text)
end
