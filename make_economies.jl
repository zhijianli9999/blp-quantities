using DataFrames, LinearAlgebra, Distributions, Revise, Serialization, DebuggingUtilities

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__)
using BLPmodule; const m = BLPmodule;

# test mode
test1state = false
if test1state 
    dirpath = "/export/storage_adgandhi/MiscLi/factract/analysis"
else
    dirpath = "jls"
end;

# Get dataframe made in make_df.jl
df = deserialize("$dirpath/df.jls");
dropmissing!(df);

# economy for BLP
firm_IDs_long = df.j;
tract_IDs_long = df.t;
X = Matrix(df[!, [:x1, :x2]])
Z = Matrix(df[!, [:z1, :z2]])
D = Matrix(df[!, [:d, :d2]])
Q = df.q
M = df.M;
nJ = length(unique(firm_IDs_long));
nI = 100;
σ = ones(size(D)[2]);
pars = m.set_Pars(K = 2, nI = nI, δs=ones(nJ,1));
serialize("jls/pars.jls", pars)

ec = m.make_Economy(
    firm_IDs_long,
    tract_IDs_long,
    X, Z, D, Q, M, nI
);
serialize("$dirpath/ec.jls", ec)



# economy for NLLS 
ec = m.make_Economy(
    firm_IDs_long,
    tract_IDs_long,
    X, Z, D, Q, M, 1
    );
serialize("$dirpath/ec_nlls.jls", ec)
