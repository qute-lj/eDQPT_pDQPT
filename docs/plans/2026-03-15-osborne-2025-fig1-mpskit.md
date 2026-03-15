# Osborne 2025 Fig. 1 MPSKit Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Julia/MPSKit workflow that targets Fig. 1 of Osborne, McCulloch, Halimeh (2025): the inverse-square long-range TFIC quench showing `branch` DQPTs below `h_c^d` and `manifold` DQPTs above `h_c^d`.

**Architecture:** Start from the current minimal worktree state and build the reproduction in layers. First create a small Julia project with helper utilities and a one-site polarized iMPS state, then validate the `InfiniteMPS + TDVP() + changebonds(...)` route on a nearest-neighbor smoke Hamiltonian, then add the paper-specific inverse-square long-range Hamiltonian by fitting `1 / r^2` with a sum of five exponentials and encoding that fit in an `InfiniteMPOHamiltonian` Jordan-block MPO. Finally add mixed-transfer return-rate branch diagnostics, a CLI script, and verification runs for `h_f = 1.25J` and `h_f = 2.5J`.

**Tech Stack:** Julia, MPSKit, MPSKitModels, TensorKit, Test, DelimitedFiles, Printf, LinearAlgebra, Optim

---

### Task 1: Create the Julia project and helper smoke tests

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/Project.toml`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/src/OsborneFig1MPSKit.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/runtests.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/test_osborne_fig1_helpers.jl`

**Step 1: Write the failing test**

```julia
using Test

include("../src/OsborneFig1MPSKit.jl")
using .OsborneFig1MPSKit

@testset "Osborne Fig1 helpers" begin
    @test isapprox(infinite_loschmidt_rate(1.0 + 0im), 0.0; atol = 1e-12)

    params = default_fig1_params()
    @test params.alpha == 2.0
    @test params.hi == 0.0

    psi_up = build_polarized_imps(; up = true)
    psi_dn = build_polarized_imps(; up = false)
    @test length(psi_up) == 1
    @test length(psi_dn) == 1
end
```

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_osborne_fig1_helpers.jl`

Expected: FAIL because the project file and module do not exist yet.

**Step 3: Write minimal implementation**

`Project.toml`:

```toml
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
MPSKit = "bb1c41ca-d63c-52ed-829e-0821da828d05"
MPSKitModels = "1ce3ff0f-5e67-4578-9591-72bf9a3e0583"
Optim = "429524aa-4258-5aef-a3af-852621145aeb"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
TensorKit = "07d62d18-f89d-51d2-bb53-8d45d0085e3f"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
```

`src/OsborneFig1MPSKit.jl`:

```julia
module OsborneFig1MPSKit

using MPSKit
using TensorKit

export infinite_loschmidt_rate
export default_fig1_params
export build_polarized_imps

infinite_loschmidt_rate(overlap::Number) = -2 * log(abs(overlap))

default_fig1_params() = (
    J = 1.0,
    hi = 0.0,
    hf = 1.25,
    alpha = 2.0,
    dt = 0.01,
    steps = 10,
    bond_dim = 8,
    grow_steps = 4,
    grow_by = 1,
)

function _product_tensor(amplitudes::AbstractVector{<:Number})
    data = reshape(ComplexF64.(collect(amplitudes)), 1, 2, 1)
    return TensorMap(data, ℂ^1 ⊗ ℂ^2 ← ℂ^1)
end

function build_polarized_imps(; up::Bool = true)
    amplitudes = up ? ComplexF64[1.0, 0.0] : ComplexF64[0.0, 1.0]
    return InfiniteMPS([_product_tensor(amplitudes)])
end

end
```

`test/runtests.jl`:

```julia
include("test_osborne_fig1_helpers.jl")
```

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_osborne_fig1_helpers.jl`

Expected: PASS.

**Step 5: Commit**

```bash
git add Project.toml src/OsborneFig1MPSKit.jl test/runtests.jl test/test_osborne_fig1_helpers.jl
git commit -m "feat: scaffold osborne fig1 mpskit helpers"
```

### Task 2: Add a nearest-neighbor iMPS quench smoke route

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/src/OsborneFig1MPSKit.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/test_osborne_fig1_smoke.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/runtests.jl`

**Step 1: Write the failing test**

```julia
using Test

include("../src/OsborneFig1MPSKit.jl")
using .OsborneFig1MPSKit

@testset "Nearest-neighbor iMPS smoke" begin
    result = run_nearest_neighbor_smoke(; h = 1.25, dt = 0.05, steps = 2, grow_steps = 2, grow_by = 1)

    @test length(result.times) == 3
    @test length(result.rate) == 3
    @test length(result.mz) == 3
    @test length(result.entropy) == 3
    @test isapprox(result.rate[1], 0.0; atol = 1e-12)
    @test all(isfinite, result.rate)
    @test all(isfinite, result.mz)
    @test all(isfinite, result.entropy)
end
```

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_osborne_fig1_smoke.jl`

Expected: FAIL because `run_nearest_neighbor_smoke` does not exist yet.

**Step 3: Write minimal implementation**

Add to `src/OsborneFig1MPSKit.jl`:

```julia
using MPSKit
using MPSKitModels
using Statistics: mean

export build_nearest_neighbor_tfic
export run_nearest_neighbor_smoke

function build_nearest_neighbor_tfic(; J::Real = 1.0, h::Real = 1.25)
    return @mpoham sum(-J * S_zz(){i, i + 1} - h * S_x(){i} for i in -Inf:Inf)
end

_mean_entropy(psi::InfiniteMPS) = mean(real.(entropy(psi)))
_mean_mz(psi::InfiniteMPS) = mean(real(expectation_value(psi, i => S_z()) for i in 1:length(psi)))

function run_nearest_neighbor_smoke(; h::Real = 1.25, dt::Real = 0.05, steps::Integer = 2, grow_steps::Integer = 2, grow_by::Integer = 1)
    psi0 = build_polarized_imps(; up = true)
    H = build_nearest_neighbor_tfic(; h = h)

    psi = deepcopy(psi0)
    envs = environments(psi, H)

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Float64[]
    mz = Float64[]
    entropy_vals = Float64[]

    for (k, t) in enumerate(times)
        push!(rate, infinite_loschmidt_rate(dot(psi0, psi)))
        push!(mz, _mean_mz(psi))
        push!(entropy_vals, _mean_entropy(psi))

        if k < length(times)
            if k <= grow_steps && grow_by > 0
                psi, envs = changebonds(psi, H, OptimalExpand(; trscheme = truncrank(grow_by)), envs)
            end
            psi, envs = timestep(psi, H, t, dt, TDVP(), envs)
        end
    end

    return (times = times, rate = rate, mz = mz, entropy = entropy_vals)
end
```

Update `test/runtests.jl`:

```julia
include("test_osborne_fig1_helpers.jl")
include("test_osborne_fig1_smoke.jl")
```

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_osborne_fig1_smoke.jl`

Expected: PASS.

**Step 5: Commit**

```bash
git add src/OsborneFig1MPSKit.jl test/test_osborne_fig1_smoke.jl test/runtests.jl
git commit -m "feat: add nearest-neighbor imps smoke route"
```

### Task 3: Fit the inverse-square coupling by a sum of five exponentials

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/src/OsborneFig1MPSKit.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/test_osborne_fig1_fit.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/runtests.jl`

**Step 1: Write the failing test**

```julia
using Test

include("../src/OsborneFig1MPSKit.jl")
using .OsborneFig1MPSKit

@testset "Inverse-square exponential fit" begin
    fit = fit_powerlaw_exponentials(2.0; nterms = 5, rmax = 100)
    approx = [reconstruct_powerlaw(fit, r) for r in 1:100]
    target = [1 / r^2 for r in 1:100]

    @test length(fit.weights) == 5
    @test length(fit.betas) == 5
    @test maximum(abs.(approx .- target)) < 1e-6
end
```

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_osborne_fig1_fit.jl`

Expected: FAIL because the fit helpers do not exist yet.

**Step 3: Write minimal implementation**

Add to `src/OsborneFig1MPSKit.jl`:

```julia
using Optim

export fit_powerlaw_exponentials
export reconstruct_powerlaw

function reconstruct_powerlaw(fit, r::Integer)
    return sum(fit.weights[k] * exp(-fit.betas[k] * (r - 1)) for k in eachindex(fit.weights))
end

function fit_powerlaw_exponentials(alpha::Real; nterms::Integer = 5, rmax::Integer = 100)
    rs = collect(1:rmax)
    target = Float64.(rs .^ (-alpha))

    function unpack(x)
        weights = exp.(x[1:nterms])
        betas = exp.(x[(nterms + 1):(2nterms)])
        return weights, betas
    end

    function loss(x)
        weights, betas = unpack(x)
        approx = [sum(weights[k] * exp(-betas[k] * (r - 1)) for k in 1:nterms) for r in rs]
        return sum(abs2, approx .- target)
    end

    x0 = vcat(log.(fill(0.2, nterms)), log.(collect(range(0.05, 1.0; length = nterms))))
    result = optimize(loss, x0, NelderMead(); iterations = 20_000)
    weights, betas = unpack(Optim.minimizer(result))

    return (weights = weights, betas = betas, alpha = Float64(alpha), rmax = rmax)
end
```

Update `test/runtests.jl`:

```julia
include("test_osborne_fig1_helpers.jl")
include("test_osborne_fig1_smoke.jl")
include("test_osborne_fig1_fit.jl")
```

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_osborne_fig1_fit.jl`

Expected: PASS with max error below the test threshold.

**Step 5: Commit**

```bash
git add src/OsborneFig1MPSKit.jl test/test_osborne_fig1_fit.jl test/runtests.jl
git commit -m "feat: fit inverse-square couplings with five exponentials"
```

### Task 4: Build the long-range inverse-square TFIC MPO and quench driver

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/src/OsborneFig1MPSKit.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/test_osborne_fig1_longrange.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/runtests.jl`

**Step 1: Write the failing test**

```julia
using Test

include("../src/OsborneFig1MPSKit.jl")
using .OsborneFig1MPSKit
using MPSKit

@testset "Long-range TFIC iMPS quench" begin
    fit = fit_powerlaw_exponentials(2.0; nterms = 5, rmax = 100)
    H = build_longrange_tfic(; h = 1.25, fit = fit)
    @test H isa InfiniteMPOHamiltonian

    result = run_longrange_quench(; hf = 1.25, dt = 0.05, steps = 2, fit = fit, grow_steps = 2, grow_by = 1)
    @test length(result.times) == 3
    @test all(isfinite, result.rate)
    @test all(isfinite, result.mz)
    @test all(isfinite, result.entropy)
end
```

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_osborne_fig1_longrange.jl`

Expected: FAIL because the long-range Hamiltonian builder and quench driver do not exist yet.

**Step 3: Write minimal implementation**

Add to `src/OsborneFig1MPSKit.jl`:

```julia
export build_longrange_tfic
export run_longrange_quench

function build_longrange_tfic(; J::Real = 1.0, h::Real = 1.25, fit)
    sx = S_x()
    sz = S_z()
    n = length(fit.weights)

    W = Matrix{Any}(missing, n + 2, n + 2)
    W[1, 1] = 1
    W[end, end] = 1
    W[1, end] = -Float64(h) * sx

    for k in 1:n
        W[1, k + 1] = sz
        W[k + 1, k + 1] = exp(-fit.betas[k])
        W[k + 1, end] = -Float64(J) * fit.weights[k] * sz
    end

    return InfiniteMPOHamiltonian([W])
end

function run_longrange_quench(; hf::Real = 1.25, dt::Real = 0.01, steps::Integer = 10, fit, grow_steps::Integer = 4, grow_by::Integer = 1)
    psi0 = build_polarized_imps(; up = true)
    H = build_longrange_tfic(; h = hf, fit = fit)

    psi = deepcopy(psi0)
    envs = environments(psi, H)

    times = collect(0.0:Float64(dt):(Float64(dt) * steps))
    rate = Float64[]
    mz = Float64[]
    entropy_vals = Float64[]

    for (k, t) in enumerate(times)
        push!(rate, infinite_loschmidt_rate(dot(psi0, psi)))
        push!(mz, _mean_mz(psi))
        push!(entropy_vals, _mean_entropy(psi))

        if k < length(times)
            if k <= grow_steps && grow_by > 0
                psi, envs = changebonds(psi, H, OptimalExpand(; trscheme = truncrank(grow_by)), envs)
            end
            psi, envs = timestep(psi, H, t, dt, TDVP(), envs)
        end
    end

    return (times = times, rate = rate, mz = mz, entropy = entropy_vals, psi_final = psi)
end
```

Update `test/runtests.jl`:

```julia
include("test_osborne_fig1_helpers.jl")
include("test_osborne_fig1_smoke.jl")
include("test_osborne_fig1_fit.jl")
include("test_osborne_fig1_longrange.jl")
```

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_osborne_fig1_longrange.jl`

Expected: PASS.

**Step 5: Commit**

```bash
git add src/OsborneFig1MPSKit.jl test/test_osborne_fig1_longrange.jl test/runtests.jl
git commit -m "feat: add long-range tfic mpo and quench driver"
```

### Task 5: Add mixed-transfer return-rate branches and `branch/manifold` classification

**Files:**
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/src/OsborneFig1MPSKit.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/test_osborne_fig1_diagnostics.jl`
- Modify: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/test/runtests.jl`

**Step 1: Write the failing test**

```julia
using Test

include("../src/OsborneFig1MPSKit.jl")
using .OsborneFig1MPSKit

@testset "DQPT diagnostics" begin
    manifold = classify_crossing(
        (; λ1p = [0.4, 0.3, 0.2], λ1m = [0.2, 0.3, 0.4], λ2p = [0.8, 0.8, 0.8], λ2m = [0.9, 0.9, 0.9]),
        2,
    )
    branch = classify_crossing(
        (; λ1p = [0.2, 0.4, 0.5], λ1m = [0.9, 0.9, 0.9], λ2p = [0.5, 0.3, 0.2], λ2m = [1.0, 1.0, 1.0]),
        2,
    )

    @test manifold == :manifold
    @test branch == :branch
end
```

**Step 2: Run test to verify it fails**

Run: `julia --project=. test/test_osborne_fig1_diagnostics.jl`

Expected: FAIL because the diagnostics do not exist yet.

**Step 3: Write minimal implementation**

Add to `src/OsborneFig1MPSKit.jl`:

```julia
export mixed_return_branches
export classify_crossing
export summarize_fig1_scan

function mixed_return_branches(psi_t::InfiniteMPS, psi_ref::InfiniteMPS; num_vals::Integer = 2)
    spectrum = transfer_spectrum(psi_t; below = psi_ref, num_vals = num_vals)
    return sort(-log.(abs.(spectrum)))
end

function classify_crossing(branches, idx::Integer)
    vals = [
        (:λ1p, branches.λ1p[idx]),
        (:λ1m, branches.λ1m[idx]),
        (:λ2p, branches.λ2p[idx]),
        (:λ2m, branches.λ2m[idx]),
    ]
    label = first(sort(vals, by = last))
    return label[1] in (:λ1p, :λ1m) ? :manifold : :branch
end

function summarize_fig1_scan(times, λ1p, λ1m, λ2p, λ2m, mz)
    rate = [min(λ1p[i], λ1m[i]) for i in eachindex(times)]
    peak_index = argmax(rate)
    kind = classify_crossing((; λ1p, λ1m, λ2p, λ2m), peak_index)
    return (peak_index = peak_index, peak_time = times[peak_index], peak_rate = rate[peak_index], kind = kind, peak_mz = mz[peak_index])
end
```

Update `test/runtests.jl`:

```julia
include("test_osborne_fig1_helpers.jl")
include("test_osborne_fig1_smoke.jl")
include("test_osborne_fig1_fit.jl")
include("test_osborne_fig1_longrange.jl")
include("test_osborne_fig1_diagnostics.jl")
```

**Step 4: Run test to verify it passes**

Run: `julia --project=. test/test_osborne_fig1_diagnostics.jl`

Expected: PASS.

**Step 5: Commit**

```bash
git add src/OsborneFig1MPSKit.jl test/test_osborne_fig1_diagnostics.jl test/runtests.jl
git commit -m "feat: add fig1 branch and manifold diagnostics"
```

### Task 6: Add the CLI script, output files, and verification runs

**Files:**
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/scripts/reproduce_osborne_fig1.jl`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/outputs/README.md`
- Create: `/home/qute_lj/wsl_workspace/CapsuleEverything/202603/edpqt_pdqpt/.worktrees/osborne-2025-repro/docs/notes/2026-03-15-osborne-2025-fig1-reproduction.md`

**Step 1: Write the failing smoke test**

There is no separate unit test file here. Use the script itself as the smoke target.

Run:

```bash
julia --project=. scripts/reproduce_osborne_fig1.jl --hf 1.25 --steps 2 --dt 0.05 --output-prefix smoke_fig1
```

Expected: FAIL because the script does not exist yet.

**Step 2: Write minimal implementation**

`scripts/reproduce_osborne_fig1.jl`:

```julia
include("../src/OsborneFig1MPSKit.jl")
using .OsborneFig1MPSKit

hf = 1.25
dt = 0.01
steps = 10
output_prefix = "osborne_fig1"

i = 1
while i <= length(ARGS)
    key = ARGS[i]
    value = ARGS[i + 1]
    if key == "--hf"
        hf = parse(Float64, value)
    elseif key == "--dt"
        dt = parse(Float64, value)
    elseif key == "--steps"
        steps = parse(Int, value)
    elseif key == "--output-prefix"
        output_prefix = value
    else
        throw(ArgumentError("unknown argument: $key"))
    end
    i += 2
end

fit = fit_powerlaw_exponentials(2.0; nterms = 5, rmax = 100)
result = run_longrange_quench(; hf = hf, dt = dt, steps = steps, fit = fit)

mkpath("outputs")
open(joinpath("outputs", output_prefix * ".tsv"), "w") do io
    println(io, "time\trate\tmz\tentropy")
    for i in eachindex(result.times)
        println(io, string(result.times[i], '\t', result.rate[i], '\t', result.mz[i], '\t', result.entropy[i]))
    end
end

println("wrote outputs/" * output_prefix * ".tsv")
```

`outputs/README.md` should document:

- the TSV columns
- that `alpha = 2` is approximated by a five-exponential fit
- that this script is targeting Fig. 1 only

`docs/notes/2026-03-15-osborne-2025-fig1-reproduction.md` should record:

- the exact command lines used
- the fit error over `r = 1:100`
- the observed peak time, peak rate, and provisional `branch/manifold` label for `h_f = 1.25` and `h_f = 2.5`
- whether the result is only smoke-level, qualitative, or closer to paper-level

**Step 3: Run verification**

Run unit tests:

```bash
julia --project=. test/runtests.jl
```

Expected: PASS.

Run a smoke script:

```bash
julia --project=. scripts/reproduce_osborne_fig1.jl --hf 1.25 --steps 2 --dt 0.05 --output-prefix smoke_fig1_branch
```

Expected: `outputs/smoke_fig1_branch.tsv` is created.

Run the first meaningful pair:

```bash
julia --project=. scripts/reproduce_osborne_fig1.jl --hf 1.25 --steps 250 --dt 0.005 --output-prefix fig1_branch
julia --project=. scripts/reproduce_osborne_fig1.jl --hf 2.5 --steps 250 --dt 0.005 --output-prefix fig1_manifold
```

Expected:

- the lower-`h_f` run shows constrained `m_z(t)` and a `branch`-leaning return-rate structure
- the higher-`h_f` run shows `m_z(t)` crossing zero and a `manifold`-leaning return-rate structure

If the qualitative separation is too weak, tighten toward the paper setup:

```bash
julia --project=. scripts/reproduce_osborne_fig1.jl --hf 1.25 --steps 1000 --dt 0.001 --output-prefix fig1_branch_refine
julia --project=. scripts/reproduce_osborne_fig1.jl --hf 2.5 --steps 1000 --dt 0.001 --output-prefix fig1_manifold_refine
```

**Step 4: Commit**

```bash
git add scripts/reproduce_osborne_fig1.jl outputs/README.md docs/notes/2026-03-15-osborne-2025-fig1-reproduction.md
git commit -m "feat: add osborne fig1 reproduction script and notes"
```
