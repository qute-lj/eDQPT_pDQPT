using Test
using LinearAlgebra
using TensorKit

include("../src/DeNicola2021Canonical.jl")
using .DeNicola2021Canonical

@testset "De Nicola 2021 canonical local states" begin
    down = build_local_spinor(:down)
    @test down == ComplexF64[0.0, 1.0]
    @test isapprox(norm(down), 1.0; atol = 1e-12)

    right = build_local_spinor(:right)
    @test right ≈ ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    @test isapprox(norm(right), 1.0; atol = 1e-12)

    psi = build_single_site_product_state(right)
    @test length(psi) == 1
end

@testset "De Nicola 2021 canonical diagnostics" begin
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

    recovered = canonical_gamma_from_left(ac, schmidt; count = 2)
    @test abs.(recovered) ≈ abs.(gamma)

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

@testset "De Nicola 2021 diagnostics with non-diagonal gauge tensor" begin
    schmidt = DiagonalTensorMap(ComplexF64[0.9, 0.3], ℂ^2)
    gamma = zeros(ComplexF64, 2, 2, 2)
    gamma[1, :, 1] .= ComplexF64[1.0, 0.0]
    gamma[1, :, 2] .= ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    gamma[2, :, 1] .= ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    gamma[2, :, 2] .= ComplexF64[0.0, 1.0]

    a_data = similar(gamma)
    for i in axes(gamma, 1), sigma in axes(gamma, 2), j in axes(gamma, 3)
        a_data[i, sigma, j] = schmidt[i, i] * gamma[i, sigma, j]
    end

    U = ComplexF64[
        inv(sqrt(2)) inv(sqrt(2));
        inv(sqrt(2)) -inv(sqrt(2));
    ]
    V = ComplexF64[
        1.0 0.0;
        0.0 im;
    ]

    c_data = U * ComplexF64.(convert(Array, schmidt)) * V'
    ac_data = similar(a_data)
    for sigma in axes(a_data, 2)
        ac_data[:, sigma, :] .= U * a_data[:, sigma, :] * V'
    end

    c = TensorMap(c_data, ℂ^2 ← ℂ^2)
    ac = TensorMap(ac_data, ℂ^2 ⊗ ℂ^2 ← ℂ^2)

    recovered = canonical_gamma_from_left(ac, c; count = 2)
    @test abs.(recovered) ≈ abs.(gamma)

    singular_values = leading_singular_values(c; count = 2)
    @test singular_values ≈ [0.9, 0.3]

    overlaps = overlap_matrix(recovered, ComplexF64[1.0, 0.0]; count = 2)
    expected_overlaps = ComplexF64[
        1.0 inv(sqrt(2));
        inv(sqrt(2)) 0.0;
    ]
    @test abs.(overlaps) ≈ abs.(expected_overlaps)
end
