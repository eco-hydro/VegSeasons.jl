module VegSeasons

using DataFrames: DataFrame, sort!, nrow
using Statistics: mean, median


include("findpeaks.jl")
include("Peaks/findpeaks_allen.jl")


end # module FindPeaks2
