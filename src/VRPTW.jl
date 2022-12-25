module VRPTW

using Revise, JLD2

# Write your package code here.
include("func.jl")
include("load_data.jl")

export load_solomon_data, dir, dir_data

end
