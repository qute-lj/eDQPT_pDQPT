module DQPTFig1DeNicola2021

using DelimitedFiles
using LinearAlgebra
using MPSKit
using MPSKitModels
using TensorKit
ENV["GKSwstype"] = get(ENV, "GKSwstype", "100")
using Plots

include("DeNicola2021Canonical.jl")
using .DeNicola2021Canonical: build_local_spinor,
    build_single_site_product_state,
    canonical_gamma_from_left,
    fidelity_transfer_matrix,
    leading_entanglement_spectrum,
    leading_singular_values,
    leading_transfer_eigenvalues,
    overlap_matrix

export build_local_spinor
export build_single_site_product_state
export build_fig1_ising_hamiltonian
export build_fig1_plot
export canonical_gamma_from_left
export fidelity_transfer_matrix
export leading_entanglement_spectrum
export leading_singular_values
export leading_transfer_eigenvalues
export load_fig1_table
export overlap_matrix
export paper_fig1_preset
export parse_fig1_cli
export planned_fig1_output_paths
export run_fig1_ising_quench
export save_fig1_result

function _loschmidt_rate_density(overlap::Number)
    return -2 * log(abs(overlap))
end

function build_fig1_ising_hamiltonian(; J::Real, hx::Real, hz::Real)
    sx = σˣ()
    sz = σᶻ()
    zz = σᶻᶻ()
    lattice = [space(sx, 1)]

    h_x = InfiniteMPOHamiltonian(lattice, (i,) => Float64(hx) * sx for i in 1:1)
    h_z = InfiniteMPOHamiltonian(lattice, (i,) => Float64(hz) * sz for i in 1:1)
    h_zz = InfiniteMPOHamiltonian(lattice, (i, i + 1) => Float64(J) * zz for i in 1:1)
    return h_x + h_z + h_zz
end

function _padded_singular_values(schmidt; count::Int = 2)
    singular_values = svdvals(ComplexF64.(convert(Array, schmidt)))
    padded = zeros(Float64, count)
    n = min(count, length(singular_values))
    padded[1:n] .= singular_values[1:n]
    return padded
end

function _padded_gamma_from_left(center_tensor, schmidt; count::Int = 2, tol::Real = 1e-12)
    center_data = DeNicola2021Canonical._tensor_data(center_tensor)
    n = min(count, length(svdvals(ComplexF64.(convert(Array, schmidt)))))
    gamma = zeros(ComplexF64, count, size(center_data, 2), count)
    n == 0 && return gamma
    gamma[1:n, :, 1:n] .= canonical_gamma_from_left(center_tensor, schmidt; count = n, tol = tol)
    return gamma
end

function _state_transfer_diagnostics(psi::InfiniteMPS, amplitudes::AbstractVector{<:Number}; count::Int = 2)
    singular_values = _padded_singular_values(psi.C[1]; count = count)
    gamma = _padded_gamma_from_left(psi.AC[1], psi.C[1]; count = count)
    overlaps = overlap_matrix(gamma, amplitudes; count = count)
    transfer = fidelity_transfer_matrix(singular_values, overlaps)
    eigs = leading_transfer_eigenvalues(transfer; count = count)

    return (
        singular_values = singular_values,
        entanglement_weights = abs2.(singular_values),
        overlaps = overlaps,
        transfer = transfer,
        eigs = eigs,
    )
end

function run_fig1_ising_quench(;
    preset::Symbol = :pdqpt,
    dt::Real = 0.05,
    steps::Integer = 80,
    grow_steps::Integer = 20,
    grow_by::Integer = 1,
)
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    grow_steps >= 0 || throw(ArgumentError("grow_steps must be nonnegative"))
    grow_by >= 0 || throw(ArgumentError("grow_by must be nonnegative"))

    cfg = paper_fig1_preset(preset)
    amplitudes = build_local_spinor(cfg.initial_state)
    psi0 = build_single_site_product_state(amplitudes)
    psi = deepcopy(psi0)
    H = build_fig1_ising_hamiltonian(; J = cfg.J, hx = cfg.hx, hz = cfg.hz)
    evolution_mpo = MPSKit.DenseMPO(make_time_mpo(H, Float64(dt), WII()))

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Vector{Float64}(undef, length(times))
    s1 = Vector{Float64}(undef, length(times))
    s2 = Vector{Float64}(undef, length(times))
    lambda1 = Vector{Float64}(undef, length(times))
    lambda2 = Vector{Float64}(undef, length(times))
    o11 = Vector{Float64}(undef, length(times))
    ood = Vector{Float64}(undef, length(times))
    tf1 = Vector{ComplexF64}(undef, length(times))
    tf2 = Vector{ComplexF64}(undef, length(times))
    tf1_abs = Vector{Float64}(undef, length(times))
    tf2_abs = Vector{Float64}(undef, length(times))

    for (k, t) in enumerate(times)
        diagnostics = _state_transfer_diagnostics(psi, amplitudes; count = 2)
        rate[k] = _loschmidt_rate_density(dot(psi0, psi))
        s1[k], s2[k] = diagnostics.singular_values
        lambda1[k], lambda2[k] = diagnostics.entanglement_weights
        o11[k] = abs(diagnostics.overlaps[1, 1])
        ood[k] = max(abs(diagnostics.overlaps[1, 2]), abs(diagnostics.overlaps[2, 1]))
        tf1[k], tf2[k] = diagnostics.eigs
        tf1_abs[k], tf2_abs[k] = abs.(diagnostics.eigs)

        if k < length(times)
            target_rank = 1 + min(k, grow_steps) * grow_by
            psi = changebonds(
                evolution_mpo * psi,
                SvdCut(; trscheme = MPSKit.truncrank(max(target_rank, 1))),
            )
            normalize!(psi)
        end
    end

    return (
        preset = preset,
        initial_state = cfg.initial_state,
        times = times,
        rate = rate,
        s1 = s1,
        s2 = s2,
        lambda1 = lambda1,
        lambda2 = lambda2,
        o11 = o11,
        ood = ood,
        tf1 = tf1,
        tf2 = tf2,
        tf1_abs = tf1_abs,
        tf2_abs = tf2_abs,
        parameters = (
            dt = Float64(dt),
            steps = Int(steps),
            grow_steps = Int(grow_steps),
            grow_by = Int(grow_by),
            J = cfg.J,
            hx = cfg.hx,
            hz = cfg.hz,
        ),
    )
end

function _ensure_dir(path::AbstractString)
    mkpath(path)
    return path
end

function planned_fig1_output_paths(;
    output_root::AbstractString = "outputs",
    figure_root::AbstractString = joinpath("figures", "report"),
)
    return Dict(
        :pdqpt_tsv => joinpath(output_root, "fig1_pdqpt_denicola_2021.tsv"),
        :edqpt_tsv => joinpath(output_root, "fig1_edqpt_denicola_2021.tsv"),
        :pdqpt_figure => joinpath(figure_root, "dqpt_fig1_pdqpt_denicola_2021.png"),
        :edqpt_figure => joinpath(figure_root, "dqpt_fig1_edqpt_denicola_2021.png"),
    )
end

function save_fig1_result(result, path::AbstractString)
    columns = [
        "time",
        "rate",
        "s1",
        "s2",
        "lambda1",
        "lambda2",
        "o11",
        "ood",
        "tf1_re",
        "tf1_im",
        "tf1_abs",
        "tf2_re",
        "tf2_im",
        "tf2_abs",
    ]

    _ensure_dir(dirname(path))
    open(path, "w") do io
        println(io, join(columns, '\t'))
        for i in eachindex(result.times)
            row = (
                result.times[i],
                result.rate[i],
                result.s1[i],
                result.s2[i],
                result.lambda1[i],
                result.lambda2[i],
                result.o11[i],
                result.ood[i],
                real(result.tf1[i]),
                imag(result.tf1[i]),
                result.tf1_abs[i],
                real(result.tf2[i]),
                imag(result.tf2[i]),
                result.tf2_abs[i],
            )
            println(io, join(string.(row), '\t'))
        end
    end
    return path
end

function load_fig1_table(path::AbstractString)
    lines = readlines(path)
    isempty(lines) && throw(ArgumentError("empty TSV file: $path"))

    header = split(first(lines), '\t')
    table = Dict(name => Float64[] for name in header)
    for line in Iterators.drop(lines, 1)
        isempty(line) && continue
        values = split(line, '\t')
        length(values) == length(header) || throw(ArgumentError("row/header mismatch in $path"))
        for (name, value) in zip(header, values)
            push!(table[name], parse(Float64, value))
        end
    end
    return table
end

function _series(table, name::AbstractString)
    haskey(table, name) || throw(ArgumentError("missing column: $name"))
    return table[name]
end

function build_fig1_plot(table; preset::Symbol)
    default(
        fontfamily = "sans-serif",
        lw = 2.2,
        grid = true,
        framestyle = :box,
        legend = :topright,
        size = (1100, 1300),
    )
    t = _series(table, "time")
    rate = _series(table, "rate")
    s1 = _series(table, "s1")
    s2 = _series(table, "s2")
    o11 = _series(table, "o11")
    ood = _series(table, "ood")
    tf1_abs = _series(table, "tf1_abs")
    tf2_abs = _series(table, "tf2_abs")

    label = preset == :pdqpt ? "pDQPT" : preset == :edqpt ? "eDQPT" : string(preset)
    peak_t = t[argmax(rate)]

    p1 = plot(
        t,
        rate;
        color = :firebrick,
        xlabel = "t",
        ylabel = "rate",
        title = "$label rate",
        label = "rate",
    )
    vline!(p1, [peak_t]; color = :gray40, ls = :dash, label = "peak")

    p2 = plot(
        t,
        tf1_abs;
        color = :navy,
        xlabel = "t",
        ylabel = "|e|",
        title = "$label transfer-matrix eigenvalues",
        label = "|e1|",
    )
    plot!(p2, t, tf2_abs; color = :darkorange, label = "|e2|")
    vline!(p2, [peak_t]; color = :gray40, ls = :dash, label = "peak")

    p3 = plot(
        t,
        s1;
        color = :teal,
        xlabel = "t",
        ylabel = "singular value",
        title = "$label entanglement spectrum",
        label = "s1",
    )
    plot!(p3, t, s2; color = :purple4, label = "s2")
    vline!(p3, [peak_t]; color = :gray40, ls = :dash, label = "peak")

    p4 = plot(
        t,
        o11;
        color = :black,
        xlabel = "t",
        ylabel = "overlap",
        title = "$label overlap matrix",
        label = "|o11|",
    )
    plot!(p4, t, ood; color = :forestgreen, label = "|ood|")
    vline!(p4, [peak_t]; color = :gray40, ls = :dash, label = "peak")

    return plot(p1, p2, p3, p4; layout = (4, 1), size = (1100, 1400))
end

function paper_fig1_preset(label::Symbol)
    if label == :pdqpt
        return (
            label = :pdqpt,
            initial_state = :down,
            J = 0.1,
            hx = 1.0,
            hz = 0.15,
        )
    elseif label == :edqpt
        return (
            label = :edqpt,
            initial_state = :right,
            J = 1.0,
            hx = 0.1,
            hz = 0.15,
        )
    else
        throw(ArgumentError("unknown Fig. 1 preset: $label"))
    end
end

function parse_fig1_cli(args::Vector{String})
    mode = :all
    steps = 80
    dt = 0.05
    output_prefix = "dqpt_fig1_denicola_2021"

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

end
