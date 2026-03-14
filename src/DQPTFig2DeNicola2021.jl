module DQPTFig2DeNicola2021

using MPSKit
using MPSKitModels
using TensorKit

include("DeNicola2021Canonical.jl")
using .DeNicola2021Canonical: build_local_spinor

export build_fig2_xxz_hamiltonian
export paper_fig2_preset
export parse_fig2_cli

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

end
