module DeNicola2021Canonical

using LinearAlgebra
using MPSKit
using TensorKit

export build_local_spinor
export build_single_site_product_state
export canonical_gamma_from_left
export fidelity_transfer_matrix
export leading_entanglement_spectrum
export leading_singular_values
export leading_transfer_eigenvalues
export overlap_matrix

function build_local_spinor(label::Symbol)
    if label == :down
        return ComplexF64[0.0, 1.0]
    elseif label == :right
        return ComplexF64[inv(sqrt(2)), inv(sqrt(2))]
    else
        throw(ArgumentError("unknown local spinor label: $label"))
    end
end

function _product_tensor(amplitudes::AbstractVector{<:Number})
    length(amplitudes) == 2 || throw(ArgumentError("expected a spin-1/2 state vector"))
    data = reshape(ComplexF64.(collect(amplitudes)), 1, 2, 1)
    return TensorMap(data, ℂ^1 ⊗ ℂ^2 ← ℂ^1)
end

function build_single_site_product_state(amplitudes::AbstractVector{<:Number})
    return InfiniteMPS([_product_tensor(amplitudes)])
end

function _tensor_data(tensor)
    return ComplexF64.(convert(Array, tensor))
end

function _schmidt_diagonal(schmidt)
    schmidt_matrix = _tensor_data(schmidt)
    size(schmidt_matrix, 1) == size(schmidt_matrix, 2) ||
        throw(ArgumentError("expected a square Schmidt tensor"))
    return ComplexF64.(diag(schmidt_matrix))
end

function leading_singular_values(schmidt; count::Int = 2)
    count > 0 || throw(ArgumentError("count must be positive"))
    diagonal = _schmidt_diagonal(schmidt)
    count <= length(diagonal) || throw(ArgumentError("count exceeds Schmidt rank"))
    return abs.(diagonal[1:count])
end

function leading_entanglement_spectrum(schmidt; count::Int = 2)
    return abs2.(leading_singular_values(schmidt; count = count))
end

function canonical_gamma_from_left(left_tensor, schmidt; count::Int = 2, tol::Real = 1e-12)
    count > 0 || throw(ArgumentError("count must be positive"))
    left_data = _tensor_data(left_tensor)
    singular_values = _schmidt_diagonal(schmidt)
    count <= size(left_data, 1) || throw(ArgumentError("count exceeds left bond dimension"))
    count <= size(left_data, 3) || throw(ArgumentError("count exceeds right bond dimension"))
    count <= length(singular_values) || throw(ArgumentError("count exceeds Schmidt rank"))

    gamma = zeros(ComplexF64, count, size(left_data, 2), count)
    for i in 1:count
        abs(singular_values[i]) > tol ||
            throw(ArgumentError("cannot divide by Schmidt value close to zero at index $i"))
        gamma[i, :, :] .= left_data[i, :, 1:count] ./ singular_values[i]
    end
    return gamma
end

function overlap_matrix(gamma, amplitudes::AbstractVector{<:Number}; count::Int = 2)
    count > 0 || throw(ArgumentError("count must be positive"))
    gamma_data = gamma isa AbstractArray ? ComplexF64.(gamma) : _tensor_data(gamma)
    amplitudes_data = ComplexF64.(collect(amplitudes))

    count <= size(gamma_data, 1) || throw(ArgumentError("count exceeds left bond dimension"))
    count <= size(gamma_data, 3) || throw(ArgumentError("count exceeds right bond dimension"))
    length(amplitudes_data) == size(gamma_data, 2) ||
        throw(ArgumentError("spinor dimension does not match physical dimension"))

    overlaps = Matrix{ComplexF64}(undef, count, count)
    for i in 1:count, j in 1:count
        overlaps[i, j] = dot(amplitudes_data, @view gamma_data[i, :, j])
    end
    return overlaps
end

function fidelity_transfer_matrix(
    singular_values::AbstractVector{<:Number},
    overlaps::AbstractMatrix{<:Number},
)
    size(overlaps, 1) == size(overlaps, 2) ||
        throw(ArgumentError("overlap matrix must be square"))
    length(singular_values) == size(overlaps, 1) ||
        throw(ArgumentError("singular values and overlap matrix size mismatch"))
    return Diagonal(ComplexF64.(collect(singular_values))) * ComplexF64.(overlaps)
end

function leading_transfer_eigenvalues(transfer::AbstractMatrix{<:Number}; count::Int = 2)
    count > 0 || throw(ArgumentError("count must be positive"))
    count <= size(transfer, 1) || throw(ArgumentError("count exceeds transfer-matrix size"))
    values = eigvals(ComplexF64.(transfer))
    return sort!(collect(values); by = value -> -abs(value))[1:count]
end

end
