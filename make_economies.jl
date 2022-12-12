using DataFrames, LinearAlgebra, Distributions, Revise, Serialization, DebuggingUtilities

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__)
using BLPmodule; const m = BLPmodule;

# test mode
test1state = true
if test1state 
    data = DataFrame(CSV.File("$datadir/analysis/factract_FL.csv"));
    dirpath = "/export/storage_adgandhi/MiscLi/factract/analysis"
else
    data = DataFrame(CSV.File("$datadir/analysis/factract.csv"));
    dirpath = "jls"
end;

# Get dataframe made in make_df.jl
df = @select(data, 
    :t = :tractyear, 
    :tract = :tractid, 
    :year = :year, 
    :state = :state, 
    :j = :facid, 
    :q = :restot,
    :avg_dailycensus,
    :nres_mcare,
    :nres_mcaid,
    :M = :mktpop,
    :d = :dist, 
    :d2 = :dist .^ 2,
    :x1 = :dchrppd,
    :x2 = :rnhrppd,
    :z1 = :nbr_dchrppd,
    :z2 = :nbr_rnhrppd,
);

dropmissing!(df);
sort!(df, :j);


firm_IDs_long = df.j;
tract_IDs_long = df.t;
X = Matrix(df[!, [:x1, :x2]])
Z = Matrix(df[!, [:z1, :z2]])
D = Matrix(df[!, [:d, :d2]])
Q = df.q
M = df.M;
nJ = length(unique(firm_IDs_long));

# economy for BLP
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
