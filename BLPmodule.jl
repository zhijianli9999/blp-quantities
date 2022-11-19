module BLPmodule
    using Optim
    using Parameters
    using Distributions
    using Statistics
    using DataFrames
    using DataFramesMeta
    using CSV
    using Plots

    # include("BLPmodule/build_data.jl")
    include("BLPmodule/solve.jl")
    include("BLPmodule/solve_simple.jl")
    # include("BLPmodule/structs.jl")
end

