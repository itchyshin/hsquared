# Cross-engine parity fixture: HSquared.jl fits the small pedigree DIRECTLY
# (no R, no JuliaCall) and serializes what the hsquared bridge should return.
#
# Run from a checkout of HSquared.jl at the commit recorded in
# expected_metadata.csv (`engine_commit`):
#
#   julia --project=/path/to/HSquared.jl generate.jl /path/to/HSquared.jl
#
# The calls mirror hsquared's default `engine = "fit"` route
# (R/julia-bridge.R, hs_fit_julia_ai_reml_payload): normalize_pedigree ->
# pedigree_inverse -> animal_model_spec(method = :REML, relationship_diag =
# 1 + F) -> fit_ai_reml(initial = (1, 1), iterations = 100, em_warmup = 0).

using HSquared
using SparseArrays
using DelimitedFiles

engine_dir = length(ARGS) >= 1 ? ARGS[1] : dirname(dirname(pathof(HSquared)))
here = @__DIR__

ped_raw, _ = readdlm(joinpath(here, "pedigree.csv"), ',', String; header = true)
ids = ped_raw[:, 1]
sire = [isempty(s) ? "0" : s for s in ped_raw[:, 2]]
dam = [isempty(s) ? "0" : s for s in ped_raw[:, 3]]

ph_raw, _ = readdlm(joinpath(here, "phenotypes.csv"), ',', Any; header = true)
rec_id = String.(string.(ph_raw[:, 1]))
sex = String.(string.(ph_raw[:, 2]))
y = Float64.(ph_raw[:, 3])

# y ~ sex + animal(1 | id, pedigree = ped): treatment contrasts, F baseline,
# matching R's model.matrix column order ("(Intercept)", "sexM").
X = hcat(ones(length(y)), Float64.(sex .== "M"))

ped = HSquared.normalize_pedigree(ids, sire, dam)
Ainv = HSquared.pedigree_inverse(ped)
col = indexin(rec_id, ped.ids)
Z = sparse(collect(1:length(y)), Int.(col), ones(length(y)), length(y), length(ped.ids))
F = HSquared.inbreeding_coefficients(ped)

spec = HSquared.animal_model_spec(
    y, X, Z, Ainv;
    ids = ped.ids, method = :REML, relationship_diag = 1 .+ F,
)
fit = HSquared.fit_ai_reml(
    spec;
    initial = (sigma_a2 = 1.0, sigma_e2 = 1.0),
    iterations = 100, em_warmup = 0,
)
res = HSquared.result_payload(fit)
vcse = HSquared.variance_component_standard_errors(fit)
h2se = HSquared.heritability_standard_error(fit)

commit = strip(read(`git -C $engine_dir rev-parse HEAD`, String))

open(joinpath(here, "expected_variance_components.csv"), "w") do io
    println(io, "component,estimate,se")
    println(io, "animal,", repr(res.variance_components.sigma_a2), ",", repr(vcse.sigma_a2))
    println(io, "residual,", repr(res.variance_components.sigma_e2), ",", repr(vcse.sigma_e2))
end
open(joinpath(here, "expected_beta.csv"), "w") do io
    println(io, "term,estimate")
    println(io, "(Intercept),", repr(res.fixed_effects[1]))
    println(io, "sexM,", repr(res.fixed_effects[2]))
end
open(joinpath(here, "expected_metadata.csv"), "w") do io
    println(io, "key,value")
    println(io, "engine,HSquared.jl")
    println(io, "engine_commit,", commit)
    println(io, "engine_version,", pkgversion(HSquared))
    println(io, "julia_version,", VERSION)
    println(io, "route,fit_ai_reml")
    println(io, "h2,", repr(res.heritability))
    println(io, "h2_se,", repr(h2se))
    println(io, "loglik,", repr(res.loglik))
    println(io, "converged,", fit.converged)
    println(io, "n_records,", length(y))
    println(io, "n_animals,", length(ped.ids))
    println(io, "n_inbred,", count(>(0), F))
end
