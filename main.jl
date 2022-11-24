# using DataFrames, Revise, Serialization, LinearAlgebra, Parameters
using Serialization

const datadir = "/export/storage_adgandhi/MiscLi/factract";
string(@__DIR__) in LOAD_PATH || push!(LOAD_PATH, @__DIR__)
using BLPmodule; const m = BLPmodule;


ec = deserialize("ec.jls"); 

@code_warntype m.compute_deltas(ec,max_iter=1)
# m.compute_deltas(ec,max_iter=100)
