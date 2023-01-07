
function load_economy(
    factract_path,
    fac_path,
    vars::Vars,
    nI = 100
)

@unpack tvar, jvar, xvars, zvars, fevars, qvar, mvar, dvars = vars

factract = DataFrame(CSV.File(factract_path));

dropmissing!(factract, cat(tvar, jvar, mvar, dvars, xvars, qvar, fevars, zvars, dims=1));
# drop if any variable is missing, including the facility-level ones

@subset!(factract, factract[!,qvar] .> 0.)
# select only facilities with quantity>0

rename!(factract, 
    tvar => :t, 
    jvar => :j, 
    mvar => :m)

sort!(factract, :j);

firm_IDs_long = factract.j;
firm_IDs_unique = unique(factract.j);
tract_IDs_long = factract.t;

M = factract.m;
D = Matrix(factract[!, dvars])

# Facility-level data
fac_df = DataFrame(CSV.File(fac_path));
rename!(fac_df, jvar => :j)
dropmissing!(fac_df, cat(xvars, zvars, fevars, qvar, dims=1))
@subset!(fac_df, fac_df[!,qvar] .> 0.)

sort!(fac_df, :j);

rename!(fac_df, qvar => "q")



# X = Matrix(fac_df[!, xvars])
# Z = Matrix(fac_df[!, zvars])
# FE = Matrix(fac_df[!, fevars])
Q = fac_df[!, :q]

# ec = make_Economy(
#     firm_IDs_long,
#     firm_IDs_unique,
#     tract_IDs_long,
#     X, FE, Z, D, Q, M, nI
# )

ec = make_Economy(
    firm_IDs_long,
    firm_IDs_unique,
    tract_IDs_long,
    D, Q, M, nI
)

return ec, fac_df
end