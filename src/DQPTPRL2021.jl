module DQPTPRL2021

using LinearAlgebra
using MPSKit
using MPSKitModels
using Statistics: mean
using TensorKit
using Printf
using DelimitedFiles

export build_two_site_product_state
export build_dense_ising_hamiltonian
export ensure_dir
export inverse_participation_ratio
export level_density_proxy
export loschmidt_rate_infinite
export parse_cli
export parse_esqpt_cli
export prl2021_protocol_config
export run_esqpt_scan
export run_ising_esqpt_scan
export run_prl2021_dqpt_esqpt_comparison
export run_prl2021_esqpt_projection
export run_prl2021_esqpt_stability_scan
export run_prl2021_finite_dqpt
export run_ising_baseline
export run_xxz_neel_protocol
export save_prl2021_finite_dqpt
export save_prl2021_esqpt_projection
export save_prl2021_esqpt_stability_scan
export save_esqpt_spectrum
export save_ising_result
export save_xxz_result
export write_prl2021_dqpt_esqpt_comparison_summary
export write_prl2021_esqpt_projection_summary
export write_prl2021_esqpt_stability_summary
export write_esqpt_summary

const ID2_DENSE = ComplexF64[1 0; 0 1]
const SX_DENSE = ComplexF64[0 1; 1 0]
const SY_DENSE = ComplexF64[0 -im; im 0]
const SZ_DENSE = ComplexF64[1 0; 0 -1]

function loschmidt_rate_infinite(overlap::Number)
    return -2 * log(abs(overlap))
end

function ensure_dir(path::AbstractString)
    mkpath(path)
    return path
end

function _product_tensor(amplitudes::AbstractVector{<:Number})
    length(amplitudes) == 2 || throw(ArgumentError("expected a spin-1/2 state vector"))
    data = reshape(ComplexF64.(collect(amplitudes)), 1, 2, 1)
    return TensorMap(data, ℂ^1 ⊗ ℂ^2 ← ℂ^1)
end

function build_two_site_product_state(
    site1::AbstractVector{<:Number},
    site2::AbstractVector{<:Number},
)
    return InfiniteMPS([_product_tensor(site1), _product_tensor(site2)])
end

function _mean_real(values)
    return mean(real.(collect(values)))
end

function _unit_cell_expectation(psi::InfiniteMPS, op)
    return _mean_real(expectation_value(psi, i => op) for i in 1:length(psi))
end

function _unit_cell_entropy(psi::InfiniteMPS)
    return _mean_real(entropy(psi))
end

function _dense_kron_chain(ops::Vector{Matrix{ComplexF64}})
    result = ops[1]
    for op in Iterators.drop(ops, 1)
        result = kron(result, op)
    end
    return result
end

function _dense_state_from_locals(states::Vector{Vector{ComplexF64}})
    result = states[1]
    for state in Iterators.drop(states, 1)
        result = kron(result, state)
    end
    return result ./ norm(result)
end

function _local_spinor(label::Symbol)
    if label == :up
        return ComplexF64[1.0, 0.0]
    elseif label == :down
        return ComplexF64[0.0, 1.0]
    elseif label == :plusx
        return ComplexF64[1.0, 1.0] ./ sqrt(2.0)
    elseif label == :minusx
        return ComplexF64[1.0, -1.0] ./ sqrt(2.0)
    else
        throw(ArgumentError("unknown local spinor label: $label"))
    end
end

function _build_dense_initial_state(L::Integer, initial_state::Symbol)
    if initial_state in (:up, :down, :plusx, :minusx)
        return _dense_state_from_locals([_local_spinor(initial_state) for _ in 1:L])
    elseif initial_state == :neel
        locals = [_local_spinor(isodd(site) ? :up : :down) for site in 1:L]
        return _dense_state_from_locals(locals)
    else
        throw(ArgumentError("unknown initial state: $initial_state"))
    end
end

function _single_site_operator_dense(L::Integer, site::Integer, op::Matrix{ComplexF64})
    1 <= site <= L || throw(BoundsError(1:L, site))
    ops = [idx == site ? op : ID2_DENSE for idx in 1:L]
    return _dense_kron_chain(ops)
end

function _two_site_operator_dense(
    L::Integer,
    site1::Integer,
    site2::Integer,
    op1::Matrix{ComplexF64},
    op2::Matrix{ComplexF64},
)
    site1 == site2 && throw(ArgumentError("site indices must differ"))
    1 <= site1 <= L || throw(BoundsError(1:L, site1))
    1 <= site2 <= L || throw(BoundsError(1:L, site2))

    ops = Vector{Matrix{ComplexF64}}(undef, L)
    for idx in 1:L
        if idx == site1
            ops[idx] = op1
        elseif idx == site2
            ops[idx] = op2
        else
            ops[idx] = ID2_DENSE
        end
    end

    return _dense_kron_chain(ops)
end

function _bond_pairs(L::Integer, boundary::Symbol)
    if boundary == :open
        return [(i, i + 1) for i in 1:(L - 1)]
    elseif boundary == :periodic
        return vcat([(i, i + 1) for i in 1:(L - 1)], [(L, 1)])
    else
        throw(ArgumentError("unknown boundary condition: $boundary"))
    end
end

function build_dense_ising_hamiltonian(
    L::Integer;
    J::Real = 1.0,
    hx::Real = 0.1,
    hz::Real = 0.15,
    boundary::Symbol = :open,
)
    L >= 2 || throw(ArgumentError("length must be at least 2"))
    H = zeros(ComplexF64, 2^L, 2^L)

    for (i, j) in _bond_pairs(L, boundary)
        H .+= Float64(J) .* _two_site_operator_dense(L, i, j, SZ_DENSE, SZ_DENSE)
    end

    for i in 1:L
        H .+= Float64(hx) .* _single_site_operator_dense(L, i, SX_DENSE)
        H .+= Float64(hz) .* _single_site_operator_dense(L, i, SZ_DENSE)
    end

    return H
end

function _build_dense_xxz_hamiltonian(
    L::Integer;
    Jx::Real = 0.3,
    Jy::Real = 0.3,
    Jz::Real = 1.0,
    hx::Real = 0.3,
    hz::Real = 0.1,
    boundary::Symbol = :open,
)
    L >= 2 || throw(ArgumentError("length must be at least 2"))
    H = zeros(ComplexF64, 2^L, 2^L)

    for (i, j) in _bond_pairs(L, boundary)
        H .+= Float64(Jx) .* _two_site_operator_dense(L, i, j, SX_DENSE, SX_DENSE)
        H .+= Float64(Jy) .* _two_site_operator_dense(L, i, j, SY_DENSE, SY_DENSE)
        H .+= Float64(Jz) .* _two_site_operator_dense(L, i, j, SZ_DENSE, SZ_DENSE)
    end

    for i in 1:L
        H .+= Float64(hx) .* _single_site_operator_dense(L, i, SX_DENSE)
        H .+= Float64(hz) .* _single_site_operator_dense(L, i, SZ_DENSE)
    end

    return H
end

function inverse_participation_ratio(state::AbstractVector{<:Number})
    weights = abs2.(state)
    return sum(weights .^ 2)
end

function level_density_proxy(energies::AbstractVector{<:Real})
    length(energies) >= 2 || throw(ArgumentError("need at least two energies"))
    rho = Vector{Float64}(undef, length(energies))
    eps_scale = eps(Float64)

    rho[1] = 1.0 / max(Float64(energies[2] - energies[1]), eps_scale)
    for i in 2:(length(energies) - 1)
        rho[i] = 2.0 / max(Float64(energies[i + 1] - energies[i - 1]), eps_scale)
    end
    rho[end] = 1.0 / max(Float64(energies[end] - energies[end - 1]), eps_scale)

    return rho
end

function _observable_curvature(energies::AbstractVector{<:Real}, observable::AbstractVector{<:Real})
    length(energies) == length(observable) || throw(ArgumentError("length mismatch"))
    curvature = zeros(Float64, length(energies))
    eps_scale = eps(Float64)

    for i in 2:(length(energies) - 1)
        dx_left = max(Float64(energies[i] - energies[i - 1]), eps_scale)
        dx_right = max(Float64(energies[i + 1] - energies[i]), eps_scale)
        slope_left = Float64(observable[i] - observable[i - 1]) / dx_left
        slope_right = Float64(observable[i + 1] - observable[i]) / dx_right
        curvature[i] = abs(slope_right - slope_left) / max(0.5 * (dx_left + dx_right), eps_scale)
    end

    return curvature
end

function _dense_eigensystem(H::AbstractMatrix{<:Number})
    decomposition = eigen(Hermitian(Matrix(H)))
    return Float64.(decomposition.values), decomposition.vectors
end

function _mean_operator_dense(L::Integer, op::Matrix{ComplexF64})
    result = zeros(ComplexF64, 2^L, 2^L)
    for site in 1:L
        result .+= _single_site_operator_dense(L, site, op)
    end
    return result ./ L
end

function _staggered_operator_dense(L::Integer, op::Matrix{ComplexF64})
    result = zeros(ComplexF64, 2^L, 2^L)
    for site in 1:L
        result .+= ((isodd(site) ? 1.0 : -1.0) / L) .* _single_site_operator_dense(L, site, op)
    end
    return result
end

function _expectation_values_dense(eigenvectors::AbstractMatrix{<:Number}, op::AbstractMatrix{<:Number})
    values = Vector{Float64}(undef, size(eigenvectors, 2))
    for idx in 1:size(eigenvectors, 2)
        state = view(eigenvectors, :, idx)
        values[idx] = real(dot(state, op * state))
    end
    return values
end

function _iprs_dense(eigenvectors::AbstractMatrix{<:Number})
    return [inverse_participation_ratio(view(eigenvectors, :, idx)) for idx in 1:size(eigenvectors, 2)]
end

function _ising_observable(L::Integer, observable::Symbol)
    if observable == :mx
        return ("mx", _mean_operator_dense(L, SX_DENSE))
    elseif observable == :mz
        return ("mz", _mean_operator_dense(L, SZ_DENSE))
    else
        throw(ArgumentError("unknown Ising observable: $observable"))
    end
end

function _xxz_observable(L::Integer, observable::Symbol)
    if observable == :mx
        return ("mx", _mean_operator_dense(L, SX_DENSE))
    elseif observable == :mz
        return ("mz", _mean_operator_dense(L, SZ_DENSE))
    elseif observable == :staggered_mz
        return ("staggered_mz", _staggered_operator_dense(L, SZ_DENSE))
    else
        throw(ArgumentError("unknown XXZ observable: $observable"))
    end
end

function run_ising_esqpt_scan(;
    length::Integer = 8,
    J::Real = 1.0,
    hx::Real = 0.1,
    hz::Real = 0.15,
    boundary::Symbol = :open,
    observable::Symbol = :mx,
)
    H = build_dense_ising_hamiltonian(length; J = J, hx = hx, hz = hz, boundary = boundary)
    energies, eigenvectors = _dense_eigensystem(H)
    observable_name, observable_operator = _ising_observable(length, observable)
    observable_values = _expectation_values_dense(eigenvectors, observable_operator)

    return (
        model = :ising,
        observable_name = observable_name,
        energies = energies,
        eigenvectors = eigenvectors,
        density_proxy = level_density_proxy(energies),
        observable = observable_values,
        observable_curvature = _observable_curvature(energies, observable_values),
        ipr = _iprs_dense(eigenvectors),
        parameters = (
            length = Int(length),
            boundary = boundary,
            J = Float64(J),
            hx = Float64(hx),
            hz = Float64(hz),
        ),
    )
end

function _run_xxz_esqpt_scan(;
    length::Integer = 8,
    Jx::Real = 0.3,
    Jy::Real = 0.3,
    Jz::Real = 1.0,
    hx::Real = 0.3,
    hz::Real = 0.1,
    boundary::Symbol = :open,
    observable::Symbol = :staggered_mz,
)
    H = _build_dense_xxz_hamiltonian(
        length;
        Jx = Jx,
        Jy = Jy,
        Jz = Jz,
        hx = hx,
        hz = hz,
        boundary = boundary,
    )
    energies, eigenvectors = _dense_eigensystem(H)
    observable_name, observable_operator = _xxz_observable(length, observable)
    observable_values = _expectation_values_dense(eigenvectors, observable_operator)

    return (
        model = :xxz,
        observable_name = observable_name,
        energies = energies,
        eigenvectors = eigenvectors,
        density_proxy = level_density_proxy(energies),
        observable = observable_values,
        observable_curvature = _observable_curvature(energies, observable_values),
        ipr = _iprs_dense(eigenvectors),
        parameters = (
            length = Int(length),
            boundary = boundary,
            Jx = Float64(Jx),
            Jy = Float64(Jy),
            Jz = Float64(Jz),
            hx = Float64(hx),
            hz = Float64(hz),
        ),
    )
end

function parse_esqpt_cli(args::Vector{String})
    model = :ising
    chain_length = 8
    output_prefix = "prl2021_esqpt"
    boundary = :open
    J = 1.0
    Jx = 0.3
    Jy = 0.3
    Jz = 1.0
    hx = 0.1
    hz = 0.15
    observable = :mx

    i = 1
    if !isempty(args) && args[1] in ("ising", "xxz")
        model = Symbol(args[1])
        observable = model == :ising ? :mx : :staggered_mz
        hx = model == :ising ? 0.1 : 0.3
        hz = 0.15
        i += 1
    end

    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--length"
            chain_length = parse(Int, value)
        elseif key == "--output-prefix"
            output_prefix = value
        elseif key == "--boundary"
            boundary = Symbol(value)
        elseif key == "--J"
            J = parse(Float64, value)
        elseif key == "--Jx"
            Jx = parse(Float64, value)
        elseif key == "--Jy"
            Jy = parse(Float64, value)
        elseif key == "--Jz"
            Jz = parse(Float64, value)
        elseif key == "--hx"
            hx = parse(Float64, value)
        elseif key == "--hz"
            hz = parse(Float64, value)
        elseif key == "--observable"
            observable = Symbol(value)
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    return (
        model = model,
        length = chain_length,
        output_prefix = output_prefix,
        boundary = boundary,
        J = J,
        Jx = Jx,
        Jy = Jy,
        Jz = Jz,
        hx = hx,
        hz = hz,
        observable = observable,
    )
end

function prl2021_protocol_config(protocol::Symbol)
    if protocol == :ising_p
        return (
            protocol = protocol,
            model = :ising,
            observable = :mz,
            initial_state = :down,
            couplings = (J = 0.1, hx = 1.0, hz = 0.15),
            description = "Ising precession-dominated quench",
        )
    elseif protocol == :ising_e
        return (
            protocol = protocol,
            model = :ising,
            observable = :mx,
            initial_state = :plusx,
            couplings = (J = 1.0, hx = 0.1, hz = 0.15),
            description = "Ising entanglement-dominated quench",
        )
    elseif protocol == :xxz_p
        return (
            protocol = protocol,
            model = :xxz,
            observable = :mx,
            initial_state = :plusx,
            couplings = (Jx = 0.9, Jy = 0.9, Jz = 1.0, hx = 0.1, hz = 1.0),
            description = "XXZ precession-dominated quench",
        )
    elseif protocol == :xxz_e
        return (
            protocol = protocol,
            model = :xxz,
            observable = :mx,
            initial_state = :plusx,
            couplings = (Jx = 0.3, Jy = 0.3, Jz = 1.0, hx = 0.3, hz = 0.1),
            description = "XXZ entanglement-dominated quench",
        )
    else
        throw(ArgumentError("unknown PRL 2021 protocol: $protocol"))
    end
end

function run_esqpt_scan(cfg)
    if cfg.model == :ising
        return run_ising_esqpt_scan(;
            length = cfg.length,
            J = cfg.J,
            hx = cfg.hx,
            hz = cfg.hz,
            boundary = cfg.boundary,
            observable = cfg.observable,
        )
    elseif cfg.model == :xxz
        return _run_xxz_esqpt_scan(;
            length = cfg.length,
            Jx = cfg.Jx,
            Jy = cfg.Jy,
            Jz = cfg.Jz,
            hx = cfg.hx,
            hz = cfg.hz,
            boundary = cfg.boundary,
            observable = cfg.observable,
        )
    else
        throw(ArgumentError("unknown ESQPT model: $(cfg.model)"))
    end
end

function _scan_from_protocol(protocol::Symbol; length::Integer, boundary::Symbol)
    cfg = prl2021_protocol_config(protocol)
    if cfg.model == :ising
        return run_ising_esqpt_scan(;
            length = length,
            boundary = boundary,
            observable = cfg.observable,
            cfg.couplings...,
        )
    else
        return _run_xxz_esqpt_scan(;
            length = length,
            boundary = boundary,
            observable = cfg.observable,
            cfg.couplings...,
        )
    end
end

function _scan_candidate_indices(scan)
    return (
        density = argmax(scan.density_proxy),
        observable = argmax(scan.observable_curvature),
        ipr = argmax(scan.ipr),
    )
end

function _candidate_projection(scan, weights, index::Integer)
    nearest3 = max(1, index - 1):min(length(weights), index + 1)
    return (
        index = index,
        energy = scan.energies[index],
        nearest_weight = weights[index],
        nearest3_weight = sum(weights[nearest3]),
    )
end

function _dominant_peak_index(rate::AbstractVector{<:Real})
    length(rate) >= 2 || throw(ArgumentError("need at least two time points"))
    return argmax(rate[2:end]) + 1
end

function run_prl2021_esqpt_projection(protocol::Symbol; length::Integer = 8, boundary::Symbol = :open)
    cfg = prl2021_protocol_config(protocol)
    scan = _scan_from_protocol(protocol; length = length, boundary = boundary)
    psi0 = _build_dense_initial_state(length, cfg.initial_state)
    amplitudes = scan.eigenvectors' * psi0
    weights = abs2.(amplitudes)
    weights ./= sum(weights)
    mean_energy = sum(scan.energies .* weights)
    variance = sum(((scan.energies .- mean_energy) .^ 2) .* weights)
    candidate_indices = _scan_candidate_indices(scan)

    return (
        protocol = protocol,
        description = cfg.description,
        model = cfg.model,
        initial_state = cfg.initial_state,
        boundary = boundary,
        length = length,
        energies = scan.energies,
        weights = weights,
        density_proxy = scan.density_proxy,
        observable_name = scan.observable_name,
        observable = scan.observable,
        ipr = scan.ipr,
        mean_energy = mean_energy,
        energy_std = sqrt(max(variance, 0.0)),
        candidates = (
            density = _candidate_projection(scan, weights, candidate_indices.density),
            observable = _candidate_projection(scan, weights, candidate_indices.observable),
            ipr = _candidate_projection(scan, weights, candidate_indices.ipr),
        ),
    )
end

function run_prl2021_esqpt_stability_scan(
    protocol::Symbol;
    lengths::AbstractVector{<:Integer} = [4, 6, 8],
    boundaries::AbstractVector{Symbol} = [:open, :periodic],
)
    cfg = prl2021_protocol_config(protocol)
    rows = NamedTuple[]

    for boundary in boundaries
        for L in lengths
            scan = _scan_from_protocol(protocol; length = Int(L), boundary = boundary)
            idx = _scan_candidate_indices(scan)
            push!(
                rows,
                (
                    protocol = protocol,
                    model = cfg.model,
                    boundary = boundary,
                    length = Int(L),
                    density_energy = scan.energies[idx.density],
                    density_energy_per_site = scan.energies[idx.density] / L,
                    observable_energy = scan.energies[idx.observable],
                    observable_energy_per_site = scan.energies[idx.observable] / L,
                    ipr_energy = scan.energies[idx.ipr],
                    ipr_energy_per_site = scan.energies[idx.ipr] / L,
                ),
            )
        end
    end

    return (
        protocol = protocol,
        description = cfg.description,
        model = cfg.model,
        rows = rows,
    )
end

function _finite_dqpt_from_projection(
    projection;
    dt::Real = 0.05,
    steps::Integer = 80,
)
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    dt > 0 || throw(ArgumentError("dt must be positive"))

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    amplitudes = ComplexF64[
        sum(projection.weights .* exp.(-im .* projection.energies .* t)) for t in times
    ]
    rate = [-log(max(abs2(amplitude), eps(Float64))) / projection.length for amplitude in amplitudes]
    peak_index = _dominant_peak_index(rate)

    return (
        protocol = projection.protocol,
        length = projection.length,
        boundary = projection.boundary,
        times = times,
        amplitude = amplitudes,
        rate = rate,
        peak_index = peak_index,
        peak_time = times[peak_index],
        peak_rate = rate[peak_index],
    )
end

function run_prl2021_finite_dqpt(
    protocol::Symbol;
    length::Integer = 8,
    dt::Real = 0.05,
    steps::Integer = 80,
    boundary::Symbol = :open,
)
    projection = run_prl2021_esqpt_projection(protocol; length = length, boundary = boundary)
    return _finite_dqpt_from_projection(projection; dt = dt, steps = steps)
end

function run_prl2021_dqpt_esqpt_comparison(
    protocol::Symbol;
    length::Integer = 8,
    dt::Real = 0.05,
    steps::Integer = 80,
    boundary::Symbol = :open,
)
    projection = run_prl2021_esqpt_projection(protocol; length = length, boundary = boundary)
    dqpt = _finite_dqpt_from_projection(projection; dt = dt, steps = steps)

    overlaps = (
        density = projection.candidates.density.nearest3_weight,
        observable = projection.candidates.observable.nearest3_weight,
        ipr = projection.candidates.ipr.nearest3_weight,
    )
    labels = collect(keys(overlaps))
    values = [overlaps[label] for label in labels]
    best_index = argmax(values)
    best_symbol = labels[best_index]

    return (
        protocol = protocol,
        projection = projection,
        dqpt = dqpt,
        esqpt_best_label = string(best_symbol),
        esqpt_best_weight = values[best_index],
        esqpt_best_energy = getproperty(projection.candidates, best_symbol).energy,
    )
end

function run_ising_baseline(;
    dt::Real = 0.05,
    steps::Integer = 80,
    g0::Real = -0.5,
    g1::Real = -2.0,
    bond_dim::Integer = 16,
    grow_steps::Integer = 20,
    grow_by::Integer = 1,
    vumps_maxiter::Integer = 80,
    vumps_tol::Real = 1e-10,
    verbosity::Integer = 0,
)
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    bond_dim >= 1 || throw(ArgumentError("bond_dim must be positive"))
    grow_steps >= 0 || throw(ArgumentError("grow_steps must be nonnegative"))
    grow_by >= 0 || throw(ArgumentError("grow_by must be nonnegative"))

    H0 = transverse_field_ising(; g = g0)
    H1 = transverse_field_ising(; g = g1)

    psi0 = InfiniteMPS([ℂ^2], [ℂ^bond_dim])
    psi0, _ = find_groundstate(
        psi0,
        H0,
        VUMPS(; maxiter = vumps_maxiter, tol = vumps_tol, verbosity = verbosity),
    )

    psi = deepcopy(psi0)
    envs = environments(psi, H1)

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Vector{Float64}(undef, length(times))
    entropies = Vector{Float64}(undef, length(times))
    mx = Vector{Float64}(undef, length(times))
    mz = Vector{Float64}(undef, length(times))

    sx = σˣ()
    sz = σᶻ()

    for (k, t) in enumerate(times)
        rate[k] = loschmidt_rate_infinite(dot(psi0, psi))
        entropies[k] = _unit_cell_entropy(psi)
        mx[k] = _unit_cell_expectation(psi, sx)
        mz[k] = _unit_cell_expectation(psi, sz)

        if k < length(times)
            if k <= grow_steps && grow_by > 0
                psi, envs = changebonds(
                    psi,
                    H1,
                    OptimalExpand(; trscheme = truncrank(grow_by)),
                    envs,
                )
            end

            psi, envs = timestep(psi, H1, t, dt, TDVP(), envs)
        end
    end

    return (
        times = times,
        rate = rate,
        entropies = entropies,
        mx = mx,
        mz = mz,
        parameters = (
            dt = Float64(dt),
            steps = Int(steps),
            g0 = Float64(g0),
            g1 = Float64(g1),
            bond_dim = Int(bond_dim),
            grow_steps = Int(grow_steps),
            grow_by = Int(grow_by),
        ),
    )
end

function run_xxz_neel_protocol(;
    dt::Real = 0.05,
    steps::Integer = 80,
    delta::Real = 1.2,
    grow_steps::Integer = 20,
    grow_by::Integer = 1,
)
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    grow_steps >= 0 || throw(ArgumentError("grow_steps must be nonnegative"))
    grow_by >= 0 || throw(ArgumentError("grow_by must be nonnegative"))

    psi0 = build_two_site_product_state(
        ComplexF64[1.0, 0.0],
        ComplexF64[0.0, 1.0],
    )
    H = heisenberg_XXZ(InfiniteChain(2); Delta = delta, spin = 1 // 2)

    psi = deepcopy(psi0)
    envs = environments(psi, H)

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Vector{Float64}(undef, length(times))
    entropies = Vector{Float64}(undef, length(times))
    mz1 = Vector{Float64}(undef, length(times))
    mz2 = Vector{Float64}(undef, length(times))
    staggered_mz = Vector{Float64}(undef, length(times))

    sz = σᶻ()

    for (k, t) in enumerate(times)
        rate[k] = loschmidt_rate_infinite(dot(psi0, psi))
        entropies[k] = _unit_cell_entropy(psi)
        mz1[k] = real(expectation_value(psi, 1 => sz))
        mz2[k] = real(expectation_value(psi, 2 => sz))
        staggered_mz[k] = 0.5 * (mz1[k] - mz2[k])

        if k < length(times)
            if k <= grow_steps && grow_by > 0
                psi, envs = changebonds(
                    psi,
                    H,
                    OptimalExpand(; trscheme = truncrank(grow_by)),
                    envs,
                )
            end

            psi, envs = timestep(psi, H, t, dt, TDVP(), envs)
        end
    end

    return (
        times = times,
        rate = rate,
        entropies = entropies,
        mz1 = mz1,
        mz2 = mz2,
        staggered_mz = staggered_mz,
        state_unit_cell = collect(1:length(psi)),
        parameters = (
            dt = Float64(dt),
            steps = Int(steps),
            delta = Float64(delta),
            grow_steps = Int(grow_steps),
            grow_by = Int(grow_by),
        ),
    )
end

function parse_cli(args::Vector{String})
    mode = :all
    dt = 0.05
    steps = 80
    output_prefix = "dqpt_prl_2021"
    bond_dim = 16
    grow_steps = 20
    grow_by = 1
    g0 = -0.5
    g1 = -2.0
    delta = 1.2
    vumps_maxiter = 80
    vumps_tol = 1e-10

    i = 1
    if !isempty(args) && args[1] in ("ising", "xxz", "all")
        mode = Symbol(args[1])
        i += 1
    end

    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--dt"
            dt = parse(Float64, value)
        elseif key == "--steps"
            steps = parse(Int, value)
        elseif key == "--output-prefix"
            output_prefix = value
        elseif key == "--bond-dim"
            bond_dim = parse(Int, value)
        elseif key == "--grow-steps"
            grow_steps = parse(Int, value)
        elseif key == "--grow-by"
            grow_by = parse(Int, value)
        elseif key == "--g0"
            g0 = parse(Float64, value)
        elseif key == "--g1"
            g1 = parse(Float64, value)
        elseif key == "--delta"
            delta = parse(Float64, value)
        elseif key == "--vumps-maxiter"
            vumps_maxiter = parse(Int, value)
        elseif key == "--vumps-tol"
            vumps_tol = parse(Float64, value)
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    return (
        mode = mode,
        dt = dt,
        steps = steps,
        output_prefix = output_prefix,
        bond_dim = bond_dim,
        grow_steps = grow_steps,
        grow_by = grow_by,
        g0 = g0,
        g1 = g1,
        delta = delta,
        vumps_maxiter = vumps_maxiter,
        vumps_tol = vumps_tol,
    )
end

function _write_tsv(path::AbstractString, header::Vector{String}, columns::Vector{<:AbstractVector})
    length(header) == length(columns) || throw(ArgumentError("header/column mismatch"))
    nrows = length(columns[1])
    all(length(col) == nrows for col in columns) || throw(ArgumentError("column length mismatch"))

    open(path, "w") do io
        println(io, join(header, '\t'))
        for row in 1:nrows
            values = [columns[col][row] for col in eachindex(columns)]
            println(io, join(values, '\t'))
        end
    end

    return path
end

function save_ising_result(result, path::AbstractString)
    return _write_tsv(
        path,
        ["time", "rate", "entropy", "mx", "mz"],
        [result.times, result.rate, result.entropies, result.mx, result.mz],
    )
end

function save_xxz_result(result, path::AbstractString)
    return _write_tsv(
        path,
        ["time", "rate", "entropy", "mz1", "mz2", "staggered_mz"],
        [
            result.times,
            result.rate,
            result.entropies,
            result.mz1,
            result.mz2,
            result.staggered_mz,
        ],
    )
end

function save_esqpt_spectrum(scan, path::AbstractString)
    ensure_dir(dirname(path))
    return _write_tsv(
        path,
        ["energy", "density_proxy", scan.observable_name, "ipr"],
        [scan.energies, scan.density_proxy, scan.observable, scan.ipr],
    )
end

function write_esqpt_summary(scan, path::AbstractString)
    density_index = argmax(scan.density_proxy)
    curvature = hasproperty(scan, :observable_curvature) ? scan.observable_curvature :
        _observable_curvature(scan.energies, scan.observable)
    observable_index = argmax(curvature)
    ipr_index = argmax(scan.ipr)

    ensure_dir(dirname(path))
    open(path, "w") do io
        println(io, "# ESQPT Proxy Summary")
        println(io, "")
        println(io, "This workflow uses finite-size spectral ESQPT diagnostics.")
        println(io, "It does not identify eDQPT as ESQPT; eDQPT signatures remain separate dynamical evidence.")
        println(io, "")
        println(io, "## Model")
        println(io, "- model = " * string(scan.model))
        println(io, "- length = " * string(scan.parameters.length))
        println(io, "- boundary = " * string(scan.parameters.boundary))
        println(io, "- observable = " * scan.observable_name)
        println(io, "")
        println(io, "## Candidate energies")
        println(io, "- candidate_density_energy = " * string(scan.energies[density_index]))
        println(io, "- candidate_observable_energy = " * string(scan.energies[observable_index]))
        println(io, "- candidate_ipr_energy = " * string(scan.energies[ipr_index]))
    end

    return path
end

function save_prl2021_esqpt_projection(result, path::AbstractString)
    ensure_dir(dirname(path))
    return _write_tsv(
        path,
        ["energy", "weight", "density_proxy", result.observable_name, "ipr"],
        [result.energies, result.weights, result.density_proxy, result.observable, result.ipr],
    )
end

function write_prl2021_esqpt_projection_summary(result, path::AbstractString)
    ensure_dir(dirname(path))
    open(path, "w") do io
        println(io, "# PRL 2021 ESQPT Projection Summary")
        println(io, "")
        println(io, "This report projects the quench-energy distribution of the chosen initial state onto the finite-size spectral ESQPT diagnostics.")
        println(io, "It compares where the initial-state spectral weight sits relative to the candidate ESQPT energies extracted from density, observable, and IPR diagnostics.")
        println(io, "")
        println(io, "## Protocol")
        println(io, "- protocol = " * string(result.protocol))
        println(io, "- description = " * result.description)
        println(io, "- initial_state = " * string(result.initial_state))
        println(io, "- boundary = " * string(result.boundary))
        println(io, "- length = " * string(result.length))
        println(io, "")
        println(io, "## Distribution")
        println(io, "- mean_energy = " * string(result.mean_energy))
        println(io, "- energy_std = " * string(result.energy_std))
        println(io, "")
        println(io, "## Candidate overlap")
        println(io, "- density_energy = " * string(result.candidates.density.energy))
        println(io, "- density_nearest_weight = " * string(result.candidates.density.nearest_weight))
        println(io, "- density_nearest3_weight = " * string(result.candidates.density.nearest3_weight))
        println(io, "- observable_energy = " * string(result.candidates.observable.energy))
        println(io, "- observable_nearest_weight = " * string(result.candidates.observable.nearest_weight))
        println(io, "- observable_nearest3_weight = " * string(result.candidates.observable.nearest3_weight))
        println(io, "- ipr_energy = " * string(result.candidates.ipr.energy))
        println(io, "- ipr_nearest_weight = " * string(result.candidates.ipr.nearest_weight))
        println(io, "- ipr_nearest3_weight = " * string(result.candidates.ipr.nearest3_weight))
    end

    return path
end

function save_prl2021_finite_dqpt(result, path::AbstractString)
    ensure_dir(dirname(path))
    return _write_tsv(
        path,
        ["time", "rate", "amplitude_real", "amplitude_imag"],
        [result.times, result.rate, real.(result.amplitude), imag.(result.amplitude)],
    )
end

function save_prl2021_esqpt_stability_scan(result, path::AbstractString)
    ensure_dir(dirname(path))
    rows = result.rows
    return _write_tsv(
        path,
        [
            "length",
            "boundary",
            "density_energy",
            "density_energy_per_site",
            "observable_energy",
            "observable_energy_per_site",
            "ipr_energy",
            "ipr_energy_per_site",
        ],
        [
            [row.length for row in rows],
            [row.boundary for row in rows],
            [row.density_energy for row in rows],
            [row.density_energy_per_site for row in rows],
            [row.observable_energy for row in rows],
            [row.observable_energy_per_site for row in rows],
            [row.ipr_energy for row in rows],
            [row.ipr_energy_per_site for row in rows],
        ],
    )
end

function _stability_rows_for_boundary(rows, boundary::Symbol)
    return sort(filter(row -> row.boundary == boundary, rows); by = row -> row.length)
end

function _diagnostic_values(rows, field::Symbol)
    return [getproperty(row, field) for row in rows]
end

function write_prl2021_esqpt_stability_summary(result, path::AbstractString)
    ensure_dir(dirname(path))
    open(path, "w") do io
        println(io, "# PRL 2021 ESQPT Stability Summary")
        println(io, "")
        println(io, "This report checks how the candidate ESQPT energies move when chain length and boundary condition are changed.")
        println(io, "All energies are reported as energy densities to make finite-size comparison meaningful.")

        for boundary in unique(row.boundary for row in result.rows)
            rows = _stability_rows_for_boundary(result.rows, boundary)
            println(io, "")
            println(io, "## boundary = " * string(boundary))
            for (label, field) in (
                ("density", :density_energy_per_site),
                ("observable", :observable_energy_per_site),
                ("ipr", :ipr_energy_per_site),
            )
                values = _diagnostic_values(rows, field)
                println(io, "- " * label * "_energy_per_site_values = " * join(string.(values), ", "))
                println(io, "- " * label * "_energy_per_site_span = " * string(maximum(values) - minimum(values)))
                println(io, "- " * label * "_energy_per_site_drift = " * string(last(values) - first(values)))
            end
        end
    end

    return path
end

function write_prl2021_dqpt_esqpt_comparison_summary(result, path::AbstractString)
    ensure_dir(dirname(path))
    open(path, "w") do io
        println(io, "# PRL 2021 DQPT-ESQPT Comparison Summary")
        println(io, "")
        println(io, "This report compares the dominant finite-size DQPT rate peak against the ESQPT proxy carrying the largest nearby quench spectral weight.")
        println(io, "")
        println(io, "## Protocol")
        println(io, "- protocol = " * string(result.protocol))
        println(io, "- boundary = " * string(result.dqpt.boundary))
        println(io, "- length = " * string(result.dqpt.length))
        println(io, "")
        println(io, "## DQPT")
        println(io, "- dqpt_peak_time = " * string(result.dqpt.peak_time))
        println(io, "- dqpt_peak_rate = " * string(result.dqpt.peak_rate))
        println(io, "")
        println(io, "## ESQPT overlap")
        println(io, "- best_esqpt_overlap = " * result.esqpt_best_label)
        println(io, "- best_esqpt_energy = " * string(result.esqpt_best_energy))
        println(io, "- best_esqpt_nearest3_weight = " * string(result.esqpt_best_weight))
        println(io, "- mean_energy = " * string(result.projection.mean_energy))
        println(io, "- energy_std = " * string(result.projection.energy_std))
    end

    return path
end

end
