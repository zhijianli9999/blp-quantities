module BLPmodule
    using Optim
    using Distributions
    using Statistics
    using DataFrames
    using DataFramesMeta
    using CSV

    include("BLPmodule/build_data.jl")
    include("BLPmodule/solve.jl")
end