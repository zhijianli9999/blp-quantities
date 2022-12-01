
using Optim, Revise, Serialization, DebuggingUtilities

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

pars = deserialize("jls/pars.jls");
ec = deserialize("jls/ec.jls");

# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[i].X for i in eachindex(ec.firms)])...)
Z = X1;


# optim with finite diff
initial_θ2 = [1.,1.]
pars = deserialize("jls/pars.jls");
ec = deserialize("jls/ec.jls");
res = optimize(
    θ2 -> m.gmm_lm(θ2, ec, pars, X1), initial_θ2, LBFGS(),
    Optim.Options(
        show_trace = true,
        allow_f_increases=true
    ))






