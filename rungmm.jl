
using Optim, Revise, Serialization, DebuggingUtilities

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__);
using BLPmodule; const m = BLPmodule;

pars = deserialize("jls/pars.jls");
ec = deserialize("jls/ec.jls");

# linear characteristics (staffing variables):
X1 = vcat(transpose.([ec.firms[i].X for i in eachindex(ec.firms)])...);
Z = X1;


# optim with finite diff
initial_θ2 = [1.,1.]

# closure 
# function closure_gmm(θ2)
#     return m.gmm_lm(θ2, ec, pars, X1)
# end

# res = optimize(closure_gmm, initial_θ2, LBFGS(), Optim.Options(show_trace = true))
pts = []
for theta21 in range(-2., 2., step = 0.2)
    for theta22 in range(-2., 2., step = 0.2)
        θ2 = [theta21,theta22]
        push!(pts, (theta21, theta22, m.gmm_lm(θ2, ec, pars, X1)))
    end
end

using Plots
scatter(pts...)

serialize("/mnt/staff/zhli/blp-quantities/jls/res.jls", res)




