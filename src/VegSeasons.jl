module VegSeasons

using DataFrames: DataFrame, sort!, nrow
using Statistics: mean, median


include("findpeaks.jl")
include("findpeaks_allen.jl")


end # module FindPeaks2
