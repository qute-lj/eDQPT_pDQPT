using Test
using Plots

isdefined(@__MODULE__, :DQPTPlots) || include("../src/DQPTPlots.jl")

@testset "Osborne summary parsing" begin
    summary = DQPTPlots.load_osborne_summary(
        joinpath(@__DIR__, "..", "outputs", "osborne_longrange_candidate_longrange_summary.md"),
    )
    @test length(summary) == 2
    @test Set(entry.classification for entry in summary) == Set([:manifold, :branch])
    @test any(entry -> isapprox(entry.hz, 0.52; atol = 1e-12), summary)
    @test any(entry -> haskey(entry.metrics, :energy_drift), summary)
end

@testset "Osborne window figure build" begin
    specs = [
        (
            length = 6,
            path = joinpath(
                @__DIR__,
                "..",
                "outputs",
                "osborne_longrange_candidate_longrange_summary.md",
            ),
        ),
        (
            length = 8,
            path = joinpath(
                @__DIR__,
                "..",
                "outputs",
                "osborne_longrange_L8_candidate_longrange_summary.md",
            ),
        ),
        (
            length = 10,
            path = joinpath(
                @__DIR__,
                "..",
                "outputs",
                "osborne_longrange_L10_candidate_longrange_summary.md",
            ),
        ),
        (
            length = 12,
            path = joinpath(
                @__DIR__,
                "..",
                "outputs",
                "osborne_longrange_L12_candidate_longrange_summary.md",
            ),
        ),
    ]

    fig = DQPTPlots.build_osborne_longrange_window_figure(specs)
    @test fig isa Plots.Plot
end
