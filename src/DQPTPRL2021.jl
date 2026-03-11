module DQPTPRL2021

using MPSKit
using MPSKitModels
using Statistics: mean
using TensorKit
using Printf
using DelimitedFiles

export build_two_site_product_state
export ensure_dir
export loschmidt_rate_infinite
export parse_cli
export run_ising_baseline
export run_xxz_neel_protocol
export save_ising_result
export save_xxz_result

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

end
