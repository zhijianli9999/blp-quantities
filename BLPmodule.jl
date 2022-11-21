module BLPmodule
    using Optim
    using Parameters
    using Distributions
    using Statistics
    using DataFrames
    using DataFramesMeta
    using CSV
    using Plots
    using LinearAlgebra

    # include("BLPmodule/build_data.jl")
    # include("BLPmodule/solve.jl")
    include("BLPmodule/solve_m.jl")
    # include("BLPmodule/solve_simple.jl")
    # include("BLPmodule/structs.jl")
    include("BLPmodule/gmm.jl")
end

