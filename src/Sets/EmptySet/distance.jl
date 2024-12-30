function distance(∅₁::EmptySet, ∅₂::EmptySet; p::Real=2.0)
    return _distance_emptyset(∅₁, ∅₂; p=p)
end

function _distance_emptyset(∅::EmptySet, X::LazySet; p::Real=2.0)
    @assert dim(∅) == dim(X) "the dimensions of the given sets should match, " *
                             "but they are $(dim(∅)) and $(dim(X)), respectively"

    N = promote_type(eltype(∅), eltype(X))
    return N(Inf)
end
