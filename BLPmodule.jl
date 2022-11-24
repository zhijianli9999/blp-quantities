module BLPmodule
    using Optim
    using Parameters
    using Distributions
    using Statistics
    using DataFrames
    using DataFramesMeta
    using CSV
    using LinearAlgebra
    using DebuggingUtilities

    include("BLPmodule/structs.jl")
    include("BLPmodule/make.jl")
    # include("BLPmodule/solve_m.jl")
    include("BLPmodule/solve_s.jl")
    # include("BLPmodule/gmm.jl")
end

