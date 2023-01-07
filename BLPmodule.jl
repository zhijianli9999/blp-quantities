module BLPmodule
    using Optim
    using Parameters
    using Distributions
    using Statistics
    using DataFrames
    using DataFramesMeta
    using CSV
    using LinearAlgebra
    using Accessors
    using DebuggingUtilities
    using NBInclude
    using FixedEffectModels

    include("BLPmodule/structs.jl")
    include("BLPmodule/make.jl")
    include("BLPmodule/make_economies.jl")
    include("BLPmodule/solve.jl")
    include("BLPmodule/gmm.jl")
    include("BLPmodule/nlls.jl")
    include("BLPmodule/elasticity.jl")
    # @nbinclude("BLPmodule/elasticity.jl")
end

