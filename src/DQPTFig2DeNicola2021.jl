module DQPTFig2DeNicola2021

using LinearAlgebra
using MPSKit
using MPSKitModels
using TensorKit

include("DeNicola2021Canonical.jl")
using .DeNicola2021Canonical: build_local_spinor,
    build_single_site_product_state,
    fidelity_transfer_matrix,
    leading_transfer_eigenvalues,
    overlap_matrix

export build_fig2_xxz_hamiltonian
export mutual_information_bundle
export mutual_information_from_rho
export paper_fig2_preset
export partial_trace_sites
export parse_fig2_cli
export run_fig2_xxz_quench
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

function _loschmidt_rate_density(overlap::Number)
    return -2 * log(abs(overlap))
end

function _padded_singular_values(schmidt; count::Int = 4)
    diagonal = abs.(DeNicola2021Canonical._schmidt_diagonal(schmidt))
    padded = zeros(Float64, count)
    n = min(count, length(diagonal))
    padded[1:n] .= diagonal[1:n]
    return padded
end

function _padded_gamma_from_left(left_tensor, schmidt; count::Int = 2, tol::Real = 1e-12)
    left_data = DeNicola2021Canonical._tensor_data(left_tensor)
    diagonal = DeNicola2021Canonical._schmidt_diagonal(schmidt)
    n = min(count, size(left_data, 1), size(left_data, 3), length(diagonal))
    gamma = zeros(ComplexF64, count, size(left_data, 2), count)
    for i in 1:n
        abs(diagonal[i]) > tol || continue
        gamma[i, :, 1:n] .= left_data[i, :, 1:n] ./ diagonal[i]
    end
    return gamma
end

function _state_transfer_diagnostics(psi::InfiniteMPS, amplitudes::AbstractVector{<:Number})
    singular_values = _padded_singular_values(psi.C[1]; count = 4)
    gamma = _padded_gamma_from_left(psi.AL[1], psi.C[1]; count = 2)
    overlaps = overlap_matrix(gamma, amplitudes; count = 2)
    transfer = fidelity_transfer_matrix(singular_values[1:2], overlaps)
    eigs = leading_transfer_eigenvalues(transfer; count = 2)

    return (
        singular_values = singular_values,
        entanglement_weights = abs2.(singular_values),
        overlaps = overlaps,
        transfer = transfer,
        eigs = eigs,
    )
end

function _append_site_tensor(block::Array{ComplexF64}, site_tensor::Array{ComplexF64})
    size(block, ndims(block)) == size(site_tensor, 1) ||
        throw(ArgumentError("bond mismatch while building block tensor"))
    merged = reshape(block, :, size(block, ndims(block))) *
        reshape(site_tensor, size(site_tensor, 1), :)
    return reshape(
        merged,
        size(block, 1),
        size(block)[2:(end - 1)]...,
        size(site_tensor, 2),
        size(site_tensor, 3),
    )
end

function contiguous_block_density_matrix(psi::InfiniteMPS; nsites::Int = 4)
    nsites >= 1 || throw(ArgumentError("nsites must be positive"))

    block = ComplexF64.(convert(Array, psi.AC[1]))
    for site in 2:nsites
        block = _append_site_tensor(block, ComplexF64.(convert(Array, psi.AR[site])))
    end

    block_matrix = reshape(block, size(block, 1), 2^nsites, size(block, ndims(block)))
    rho = zeros(ComplexF64, 2^nsites, 2^nsites)
    for left in axes(block_matrix, 1), right in axes(block_matrix, 3)
        state = @view block_matrix[left, :, right]
        rho .+= state * state'
    end

    norm = real(tr(rho))
    norm > 0 || throw(ArgumentError("block density matrix has zero trace"))
    return rho / norm
end

function _single_site_expectation(psi::InfiniteMPS, op)
    return real(expectation_value(psi, 1 => op))
end

function run_fig2_xxz_quench(;
    preset::Symbol = :pdqpt,
    dt::Real = 0.05,
    steps::Integer = 80,
    max_bond::Integer = 200,
    cutoff::Real = 1e-9,
)
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    max_bond >= 1 || throw(ArgumentError("max_bond must be positive"))
    cutoff > 0 || throw(ArgumentError("cutoff must be positive"))

    cfg = paper_fig2_preset(preset)
    amplitudes = build_local_spinor(cfg.initial_state)
    psi0 = build_single_site_product_state(amplitudes)
    psi = deepcopy(psi0)

    H = build_fig2_xxz_hamiltonian(;
        Jx = cfg.Jx,
        Jy = cfg.Jy,
        Jz = cfg.Jz,
        hx = cfg.hx,
        hz = cfg.hz,
    )
    evolution_mpo = MPSKit.DenseMPO(make_time_mpo(H, Float64(dt), WII()))
    trscheme = truncrank(max_bond) & trunctol(; atol = cutoff)

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Vector{Float64}(undef, length(times))
    mx = Vector{Float64}(undef, length(times))
    s1 = Vector{Float64}(undef, length(times))
    s2 = Vector{Float64}(undef, length(times))
    s3 = Vector{Float64}(undef, length(times))
    s4 = Vector{Float64}(undef, length(times))
    lambda1 = Vector{Float64}(undef, length(times))
    lambda2 = Vector{Float64}(undef, length(times))
    lambda3 = Vector{Float64}(undef, length(times))
    lambda4 = Vector{Float64}(undef, length(times))
    o11 = Vector{Float64}(undef, length(times))
    ood = Vector{Float64}(undef, length(times))
    tf1 = Vector{ComplexF64}(undef, length(times))
    tf2 = Vector{ComplexF64}(undef, length(times))
    tf1_abs = Vector{Float64}(undef, length(times))
    tf2_abs = Vector{Float64}(undef, length(times))
    I12 = Vector{Float64}(undef, length(times))
    I13 = Vector{Float64}(undef, length(times))
    I12_3 = Vector{Float64}(undef, length(times))
    I12_4 = Vector{Float64}(undef, length(times))

    sx = σˣ()

    for (k, t) in enumerate(times)
        diagnostics = _state_transfer_diagnostics(psi, amplitudes)
        rho1234 = contiguous_block_density_matrix(psi; nsites = 4)
        mi = mutual_information_bundle(rho1234)

        rate[k] = _loschmidt_rate_density(dot(psi0, psi))
        mx[k] = _single_site_expectation(psi, sx)
        s1[k], s2[k], s3[k], s4[k] = diagnostics.singular_values
        lambda1[k], lambda2[k], lambda3[k], lambda4[k] = diagnostics.entanglement_weights
        o11[k] = abs(diagnostics.overlaps[1, 1])
        ood[k] = max(abs(diagnostics.overlaps[1, 2]), abs(diagnostics.overlaps[2, 1]))
        tf1[k], tf2[k] = diagnostics.eigs
        tf1_abs[k], tf2_abs[k] = abs.(diagnostics.eigs)
        I12[k] = mi["I12"]
        I13[k] = mi["I13"]
        I12_3[k] = mi["I12_3"]
        I12_4[k] = mi["I12_4"]

        if k < length(times)
            psi = changebonds(evolution_mpo * psi, SvdCut(; trscheme = trscheme))
            normalize!(psi)
        end
    end

    return (
        preset = preset,
        initial_state = cfg.initial_state,
        times = times,
        rate = rate,
        mx = mx,
        s1 = s1,
        s2 = s2,
        s3 = s3,
        s4 = s4,
        lambda1 = lambda1,
        lambda2 = lambda2,
        lambda3 = lambda3,
        lambda4 = lambda4,
        o11 = o11,
        ood = ood,
        tf1 = tf1,
        tf2 = tf2,
        tf1_abs = tf1_abs,
        tf2_abs = tf2_abs,
        I12 = I12,
        I13 = I13,
        I12_3 = I12_3,
        I12_4 = I12_4,
        parameters = (
            dt = Float64(dt),
            steps = Int(steps),
            max_bond = Int(max_bond),
            cutoff = Float64(cutoff),
            Jx = cfg.Jx,
            Jy = cfg.Jy,
            Jz = cfg.Jz,
            hx = cfg.hx,
            hz = cfg.hz,
        ),
    )
end

end
