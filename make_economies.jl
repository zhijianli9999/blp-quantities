using DataFrames, DataFramesMeta, LinearAlgebra, Distributions, Revise, Serialization, DebuggingUtilities, CSV

string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__)
using BLPmodule; const m = BLPmodule;
const datadir = "/export/storage_adgandhi/MiscLi/factract";

testmodes = ["full", "fl", "fl17"]
testmode = testmodes[1]################# EDIT THIS ##################

if testmode=="full"
    data = DataFrame(CSV.File("$datadir/analysis/factract.csv"));
elseif testmode=="fl"
    data = DataFrame(CSV.File("$datadir/analysis/factract_FL.csv"));
elseif testmode=="fl17"
    data = DataFrame(CSV.File("$datadir/analysis/factract_FL17.csv"));
else
    error("testmode")
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
    :d = :dist ./ 1.60934, 
    :d2 = (:dist ./1.60934) .^ 2,
    :x1 = :dchrppd,
    :x2 = :rnhrppd,
    :z1 = :nbr_dchrppd,
    :z2 = :nbr_rnhrppd,
);

@showln maximum(df.d2)

dropmissing!(df);
sort!(df, :j);


firm_IDs_long = df.j;
tract_IDs_long = df.t;
X = Matrix(df[!, [:x1, :x2]])
Z = Matrix(df[!, [:z1, :z2]])

# D = Matrix(df[!, [:d, :d2]])
D = Matrix(df[!, [:d]])
Q = df.q
M = df.M;
nJ = length(unique(firm_IDs_long));

# economy for BLP
nI = 100;
σ = ones(size(D)[2]);
pars = m.set_Pars(K = size(D)[2], nI = nI, δs=ones(nJ));
serialize("$datadir/analysis/pars.jls", pars)

ec = m.make_Economy(
    firm_IDs_long,
    tract_IDs_long,
    X, Z, D, Q, M, nI
);
serialize("$datadir/analysis/ec$testmode.jls", ec)

