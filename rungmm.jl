
using DataFrames, Optim, Revise, Serialization, DebuggingUtilities, CSV, Statistics

const datadir = "/export/storage_adgandhi/MiscLi/factract";
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;


testmodes = ["", "_FL", "_FL17"]
testmode = testmodes[1]################# EDIT THIS ##################
config_tags = ["312", "412"]
for config_tag in config_tags 

pars = deserialize("$datadir/analysis/pars$config_tag$testmode.jls");
ec = deserialize("$datadir/analysis/ec$config_tag$testmode.jls");

# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[i].X for i in eachindex(ec.firms)])...);
Z = vcat(transpose.([ec.firms[i].Z for i in eachindex(ec.firms)])...);

function closure_gmm(θ2)
    return m.gmm_lm(θ2, ec, pars, X1, hcat(Z,X1))
end

res = optimize(closure_gmm, -1., 10., show_trace= true, abs_tol= 1e-3)
serialize("$datadir/temp/res$config_tag$testmode.jls", res)

θ2res = Optim.minimizer(res)
δ = pars.δs
θ1res = X1 \ δ

serialize("$datadir/temp/theta1res$config_tag$testmode.jls", θ1res)
θ1res = deserialize("$datadir/temp/theta1res$config_tag$testmode.jls") #use when testing

# input for compute_elasticity()
n_firms = length(ec.firms)
j_indexer, t_indexer, positionin = m.create_indices(ec.tracts, n_firms);
X_vecs = Vector{Vector{Matrix{Float64}}}(undef, length(θ1res))
for ii in eachindex(θ1res)
    X_vecs[ii] = [t.X[:,[ii]] for t in ec.tracts]
end
share = [tt.shares for tt in ec.tracts]
mktq = [tt.q for tt in ec.tracts]

for ii in eachindex(θ1res)
    strii = string(ii)
    η = m.compute_elasticity(X_vecs[ii], θ1res[ii], share, mktq, t_indexer, positionin, n_firms);
    println(mean(η))
    CSV.write(datadir*"/analysis/elasticities$config_tag$testmode$strii.csv", DataFrame((elast = η)))
end

end
# println(mean(η_rn))
