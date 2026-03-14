module DQPTFig2DeNicola2021

using LinearAlgebra
using MPSKit
using MPSKitModels
using TensorKit

include("DeNicola2021Canonical.jl")
using .DeNicola2021Canonical: build_local_spinor

export build_fig2_xxz_hamiltonian
export mutual_information_bundle
export mutual_information_from_rho
export paper_fig2_preset
export partial_trace_sites
export parse_fig2_cli
export von_neumann_entropy

function paper_fig2_preset(label::Symbol)
    if label == :pdqpt
        return (
            label = :pdqpt,
            initial_state = :right,
            Jx = 0.9,
            Jy = 0.9,
            Jz = 1.0,
            hx = 0.1,
            hz = 1.0,
        )
    elseif label == :edqpt
        return (
            label = :edqpt,
            initial_state = :right,
            Jx = 0.3,
            Jy = 0.3,
            Jz = 1.0,
            hx = 0.3,
            hz = 0.1,
        )
    else
        throw(ArgumentError("unknown Fig. 2 preset: $label"))
    end
end

function build_fig2_xxz_hamiltonian(;
    Jx::Real,
    Jy::Real,
    Jz::Real,
    hx::Real,
    hz::Real,
)
    sx = σˣ()
    sz = σᶻ()
    sxx = σˣˣ()
    syy = σʸʸ()
    szz = σᶻᶻ()
    lattice = [space(sx, 1)]

    h_x = InfiniteMPOHamiltonian(lattice, (i,) => Float64(hx) * sx for i in 1:1)
    h_z = InfiniteMPOHamiltonian(lattice, (i,) => Float64(hz) * sz for i in 1:1)
    h_xx = InfiniteMPOHamiltonian(lattice, (i, i + 1) => Float64(Jx) * sxx for i in 1:1)
    h_yy = InfiniteMPOHamiltonian(lattice, (i, i + 1) => Float64(Jy) * syy for i in 1:1)
    h_zz = InfiniteMPOHamiltonian(lattice, (i, i + 1) => Float64(Jz) * szz for i in 1:1)
    return h_x + h_z + h_xx + h_yy + h_zz
end

function parse_fig2_cli(args::Vector{String})
    mode = :all
    steps = 80
    dt = 0.05
    output_prefix = "dqpt_fig2_denicola_2021"

    i = 1
    if !isempty(args) && args[1] in ("pdqpt", "edqpt", "all")
        mode = Symbol(args[1])
        i += 1
    end

    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--steps"
            steps = parse(Int, value)
        elseif key == "--dt"
            dt = parse(Float64, value)
        elseif key == "--output-prefix"
            output_prefix = value
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    return (
        mode = mode,
        steps = steps,
        dt = dt,
        output_prefix = output_prefix,
    )
end

function _validate_density_matrix(rho::AbstractMatrix{<:Number}, nsites::Int)
    size(rho, 1) == size(rho, 2) || throw(ArgumentError("density matrix must be square"))
    size(rho, 1) == 2^nsites || throw(ArgumentError("density matrix size does not match nsites"))
    return ComplexF64.(rho)
end

function _normalize_sites(sites::AbstractVector{<:Integer}, nsites::Int)
    normalized = sort!(unique(Int.(collect(sites))))
    all(1 .<= normalized .<= nsites) || throw(ArgumentError("site index out of bounds"))
    return normalized
end

function partial_trace_sites(rho::AbstractMatrix{<:Number}, keep_sites::AbstractVector{<:Integer}, nsites::Int)
    data = _validate_density_matrix(rho, nsites)
    keep = _normalize_sites(keep_sites, nsites)
    traced = setdiff(collect(1:nsites), keep)

    dims = ntuple(_ -> 2, nsites)
    tensor = reshape(data, dims..., dims...)
    permutation = vcat(keep, traced, keep .+ nsites, traced .+ nsites)
    permuted = permutedims(tensor, permutation)

    keep_dim = 2^length(keep)
    trace_dim = 2^length(traced)
    reshaped = reshape(permuted, keep_dim, trace_dim, keep_dim, trace_dim)

    reduced = zeros(ComplexF64, keep_dim, keep_dim)
    for i in 1:keep_dim, j in 1:keep_dim, t in 1:trace_dim
        reduced[i, j] += reshaped[i, t, j, t]
    end
    return reduced
end

function von_neumann_entropy(rho::AbstractMatrix{<:Number}; tol::Real = 1e-12)
    values = eigvals(Hermitian((ComplexF64.(rho) + ComplexF64.(rho)') / 2))
    entropy = 0.0
    for value in real.(values)
        p = max(value, 0.0)
        p > tol || continue
        entropy -= p * log(p)
    end
    return entropy
end

function mutual_information_from_rho(
    rho::AbstractMatrix{<:Number},
    region_a::AbstractVector{<:Integer},
    region_b::AbstractVector{<:Integer},
    nsites::Int,
)
    a = _normalize_sites(region_a, nsites)
    b = _normalize_sites(region_b, nsites)
    isempty(intersect(a, b)) || throw(ArgumentError("regions A and B must be disjoint"))
    ab = sort!(vcat(a, b))

    rho_a = partial_trace_sites(rho, a, nsites)
    rho_b = partial_trace_sites(rho, b, nsites)
    rho_ab = partial_trace_sites(rho, ab, nsites)
    return von_neumann_entropy(rho_a) + von_neumann_entropy(rho_b) - von_neumann_entropy(rho_ab)
end

function mutual_information_bundle(rho::AbstractMatrix{<:Number})
    nsites = round(Int, log2(size(rho, 1)))
    size(rho, 1) == 2^nsites || throw(ArgumentError("expected a power-of-two density matrix"))
    size(rho, 1) == size(rho, 2) || throw(ArgumentError("density matrix must be square"))

    return Dict(
        "I12" => mutual_information_from_rho(rho, [1], [2], nsites),
        "I13" => mutual_information_from_rho(rho, [1], [3], nsites),
        "I12_3" => mutual_information_from_rho(rho, [1, 2], [3], nsites),
        "I12_4" => mutual_information_from_rho(rho, [1, 2], [4], nsites),
    )
end

end
