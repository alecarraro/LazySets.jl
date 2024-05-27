# in 1D, the radius is the same for any `p`
function radius(x::Interval{N}, ::Real=Inf) where {N}
    return (max(x) - min(x)) / N(2)
end
