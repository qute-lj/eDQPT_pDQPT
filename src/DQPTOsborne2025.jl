module DQPTOsborne2025

using MPSKit
using MPSKitModels
using Statistics: mean
using TensorKit

export finite_loschmidt_rate
export parse_osborne_cli
export build_polarized_state
export build_osborne_hamiltonian
export ensure_dir
export run_osborne_quench
export save_osborne_result
export classify_dqpt_event
export summarize_osborne_regimes

function finite_loschmidt_rate(overlap::Number, L::Integer)
    L >= 1 || throw(ArgumentError("L must be positive"))
    return -log(abs2(overlap)) / L
end

function parse_osborne_cli(args::Vector{String})
    mode = :single
    backend = :longrange
    chain_length = 20
    steps = 20
    dt = 0.05
    output_prefix = "osborne2025"
    J = 1.0
    g = 0.7
    alpha = 3.0
    hz = 0.2
    bond_dim = 16
    compare_hz = nothing

    i = 1
    if !isempty(args) && args[1] in ("single", "compare")
        mode = Symbol(args[1])
        i += 1
    end

    while i <= length(args)
        key = args[i]
        i == length(args) && throw(ArgumentError("missing value for $key"))
        value = args[i + 1]

        if key == "--backend"
            backend = Symbol(value)
        elseif key == "--length"
            chain_length = parse(Int, value)
        elseif key == "--steps"
            steps = parse(Int, value)
        elseif key == "--dt"
            dt = parse(Float64, value)
        elseif key == "--output-prefix"
            output_prefix = value
        elseif key == "--J"
            J = parse(Float64, value)
        elseif key == "--g"
            g = parse(Float64, value)
        elseif key == "--alpha"
            alpha = parse(Float64, value)
        elseif key == "--hz"
            hz = parse(Float64, value)
        elseif key == "--bond-dim"
            bond_dim = parse(Int, value)
        elseif key == "--compare-hz"
            compare_hz = parse(Float64, value)
        else
            throw(ArgumentError("unknown argument: $key"))
        end

        i += 2
    end

    compare_hz = compare_hz === nothing ? hz + 0.4 : compare_hz

    return (
        mode = mode,
        backend = backend,
        length = chain_length,
        steps = steps,
        dt = dt,
        output_prefix = output_prefix,
        J = J,
        g = g,
        alpha = alpha,
        hz = hz,
        bond_dim = bond_dim,
        compare_hz = compare_hz,
    )
end

function _product_tensor(amplitudes::AbstractVector{<:Number})
    length(amplitudes) == 2 || throw(ArgumentError("expected a spin-1/2 state vector"))
    data = reshape(ComplexF64.(collect(amplitudes)), 1, 2, 1)
    return TensorMap(data, ℂ^1 ⊗ ℂ^2 ← ℂ^1)
end

function build_polarized_state(L::Integer; up::Bool = true)
    L >= 1 || throw(ArgumentError("L must be positive"))
    amplitudes = up ? ComplexF64[1.0, 0.0] : ComplexF64[0.0, 1.0]
    return FiniteMPS([_product_tensor(amplitudes) for _ in 1:L])
end

function build_osborne_hamiltonian(
    backend::Symbol,
    L::Integer;
    J::Real = 1.0,
    g::Real = 0.7,
    alpha::Real = 3.0,
    hz::Real = 0.0,
)
    L >= 2 || throw(ArgumentError("L must be at least 2"))
    sx = S_x()
    sz = S_z()
    lattice = fill(space(sx, 1), L)

    local_x = FiniteMPOHamiltonian(lattice, (i,) => -Float64(g) * sx for i in 1:L)
    local_z = FiniteMPOHamiltonian(lattice, (i,) => -Float64(hz) * sz for i in 1:L)

    pair_terms = if backend == :longrange
        ((i, j) => -(Float64(J) / abs(i - j)^Float64(alpha)) * (sz ⊗ sz) for
            i in 1:(L - 1) for j in (i + 1):L)
    elseif backend == :proxy
        ((i, i + 1) => -Float64(J) * (sz ⊗ sz) for i in 1:(L - 1))
    else
        throw(ArgumentError("unknown backend: $backend"))
    end

    return local_x + local_z + FiniteMPOHamiltonian(lattice, pair_terms)
end

function ensure_dir(path::AbstractString)
    mkpath(path)
    return path
end

function _mean_entropy(psi::FiniteMPS)
    Base.length(psi) == 1 && return 0.0
    return mean(real(entropy(psi, cut)) for cut in 1:(Base.length(psi) - 1))
end

function _mean_mz(psi::FiniteMPS)
    sz = S_z()
    return mean(real(expectation_value(psi, i => sz)) for i in 1:Base.length(psi))
end

function _max_allocated_bond(psi::FiniteMPS)
    Base.length(psi) <= 1 && return 1
    return maximum(dim(right_virtualspace(psi, j)) for j in 1:(Base.length(psi) - 1))
end

function run_osborne_quench(;
    backend::Symbol = :proxy,
    length::Integer = 12,
    steps::Integer = 20,
    dt::Real = 0.05,
    J::Real = 1.0,
    g::Real = 0.7,
    alpha::Real = 3.0,
    hz::Real = 0.2,
    bond_dim::Integer = 16,
)
    L = Int(length)
    L >= 2 || throw(ArgumentError("length must be at least 2"))
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    dt > 0 || throw(ArgumentError("dt must be positive"))
    bond_dim >= 1 || throw(ArgumentError("bond_dim must be positive"))

    psi0 = build_polarized_state(L; up = true)
    H = build_osborne_hamiltonian(backend, L; J = J, g = g, alpha = alpha, hz = hz)

    psi = deepcopy(psi0)
    envs = environments(psi, H)

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Vector{Float64}(undef, Base.length(times))
    entropy_vals = Vector{Float64}(undef, Base.length(times))
    mz = Vector{Float64}(undef, Base.length(times))
    energy = Vector{Float64}(undef, Base.length(times))
    max_bond = Vector{Int}(undef, Base.length(times))

    for k in eachindex(times)
        rate[k] = finite_loschmidt_rate(dot(psi0, psi), L)
        entropy_vals[k] = _mean_entropy(psi)
        mz[k] = _mean_mz(psi)
        energy[k] = real(expectation_value(psi, H, envs))
        max_bond[k] = _max_allocated_bond(psi)

        if k < Base.length(times)
            alg = k <= 3 ? TDVP2(; trscheme = truncrank(bond_dim)) : TDVP()
            psi, envs = timestep(psi, H, times[k], dt, alg, envs)
        end
    end

    energy_drift = maximum(abs.(energy .- energy[1]))

    return (
        times = times,
        rate = rate,
        entropy = entropy_vals,
        mz = mz,
        energy = energy,
        max_bond = max_bond,
        energy_drift = energy_drift,
        parameters = (
            backend = backend,
            length = L,
            steps = Int(steps),
            dt = Float64(dt),
            J = Float64(J),
            g = Float64(g),
            alpha = Float64(alpha),
            hz = Float64(hz),
            bond_dim = Int(bond_dim),
        ),
    )
end

function save_osborne_result(result, path::AbstractString)
    ensure_dir(dirname(path))
    open(path, "w") do io
        println(io, "time\trate\tentropy\tmz")
        for i in eachindex(result.times)
            println(
                io,
                string(result.times[i], '\t', result.rate[i], '\t', result.entropy[i], '\t', result.mz[i]),
            )
        end
    end
    return path
end

function _ordered_hz_pair(hz1::Real, hz2::Real)
    return hz1 <= hz2 ? (Float64(hz1), Float64(hz2)) : (Float64(hz2), Float64(hz1))
end

function classify_dqpt_event(mz::AbstractVector{<:Real}, peak_index::Integer; tol::Real = 1e-6)
    1 <= peak_index <= length(mz) || throw(BoundsError(mz, peak_index))
    window_lo = max(1, peak_index - 1)
    window_hi = min(length(mz), peak_index + 1)
    local_window = mz[window_lo:window_hi]

    if minimum(local_window) < -tol && maximum(local_window) > tol
        return :manifold
    elseif any(abs(value) <= tol for value in local_window)
        return :manifold
    else
        return :branch
    end
end

function summarize_osborne_regimes(results::Vector, labels::Vector{String}, path::AbstractString)
    length(results) == length(labels) || throw(ArgumentError("results and labels must match"))
    ensure_dir(dirname(path))

    open(path, "w") do io
        println(io, "# Osborne 2025 Regime Summary")
        for (label, result) in zip(labels, results)
            peak_index = argmax(result.rate)
            cls = classify_dqpt_event(result.mz, peak_index)
            energy_drift = hasproperty(result, :energy_drift) ? result.energy_drift :
                hasproperty(result, :energy) ? maximum(abs.(result.energy .- result.energy[1])) :
                missing
            max_allocated_bond = hasproperty(result, :max_bond) ? maximum(result.max_bond) : missing
            println(io, "")
            println(io, "## " * label)
            println(io, "- peak_time = " * string(result.times[peak_index]))
            println(io, "- peak_rate = " * string(result.rate[peak_index]))
            println(io, "- peak_mz = " * string(result.mz[peak_index]))
            println(io, "- classification = " * string(cls))
            println(io, "- max_entropy = " * string(maximum(result.entropy)))
            println(io, "- energy_drift = " * string(energy_drift))
            println(io, "- max_allocated_bond = " * string(max_allocated_bond))
        end
    end

    return path
end

end
