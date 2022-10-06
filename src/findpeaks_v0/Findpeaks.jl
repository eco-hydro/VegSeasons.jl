# include("season/season.jl")
"""
    findpeaks(
        y::AbstractVector{T},
        x::AbstractVector{S}=collect(1:length(y));
        min_height::T=minimum(y),
        min_prom::T=zero(y[1]),
        min_dist::S=zero(x[1]),
        threshold::T=zero(y[1])
    ) where {T<:Real,S}

Returns indices of local maxima (sorted from highest peaks to lowest)
in 1D array of real numbers. Similar to MATLAB's findpeaks().

*Arguments*:
    `y` -- data
    *Optional*:
    `   x` -- x-data
    *Keyword*:
        + `min_height` -- minimal peak height
        + `min_prom` -- minimal peak prominence
        + `min_dist` -- minimal peak distance (keeping highest peaks)
        + `threshold` -- minimal difference (absolute value) between
        peak and neighboring points
"""
function findpeaks(
    y::AbstractVector{T},
    x::AbstractVector{S}=collect(1:length(y));
    min_height::T=minimum(y),
    min_prom::T=zero(y[1]),
    min_dist::S=zero(x[1]),
    threshold::T=zero(y[1])
) where {T<:Real,S}

    dy = diff(y)
    peaks = in_threshold(dy, threshold)

    yP = y[peaks]
    peaks = with_prominence(y, peaks, min_prom)

    #minimal height refinement
    peaks = peaks[y[peaks].>min_height]
    yP = y[peaks]

    peaks = with_distance(peaks, x, y, min_dist)

    peaks
end

"""
Select peaks that are inside threshold.
"""
function in_threshold(
    dy::AbstractVector{T},
    threshold::T,
) where {T<:Real}

    peaks = 1:length(dy) |> collect

    k = 0
    for i = 2:lastindex(dy)
        if dy[i] <= -threshold && dy[i-1] >= threshold
            k += 1
            peaks[k] = i
        end
    end
    peaks[1:k]
end

"""
Select peaks that have a given prominence
"""
function with_prominence(
    y::AbstractVector{T},
    peaks::AbstractVector{Int},
    min_prom::T,
) where {T<:Real}

    #minimal prominence refinement
    peaks[prominence(y, peaks) .> min_prom]
end


"""
Calculate peaks' prominences
"""
function prominence(y::AbstractVector{T}, peaks::AbstractVector{Int}) where {T<:Real}
    yP = y[peaks]
    proms = zero(yP)

    for (i, p) in enumerate(peaks)
        lP, rP = 1, length(y)
        for j = (i-1):-1:1
            if yP[j] > yP[i]
                lP = peaks[j]
                break
            end
        end
        ml = minimum(y[lP:p])
        for j = (i+1):length(yP)
            if yP[j] > yP[i]
                rP = peaks[j]
                break
            end
        end
        mr = minimum(y[p:rP])
        ref = max(mr, ml)
        proms[i] = yP[i] - ref
    end

    proms
end

"""
Select only peaks that are further apart than `min_dist`
"""
function with_distance(
    peaks::AbstractVector{Int},
    x::AbstractVector{S},
    y::AbstractVector{T},
    min_dist::S,
) where {T<:Real,S}

    peaks2del = zeros(Bool, length(peaks))
    inds = sortperm(y[peaks], rev=true)
    permute!(peaks, inds)
    for i = eachindex(peaks)
        for j = 1:(i-1)
            if abs(x[peaks[i]] - x[peaks[j]]) <= min_dist
                if !peaks2del[j]
                    peaks2del[i] = true
                end
            end
        end
    end

    peaks[.!peaks2del]
end
