function scale(α::Real, P::DensePolynomialZonotope)
    return _scale_copy_inplace(α, P)
end

function scale!(α::Real, P::DensePolynomialZonotope)
    P.c .*= α
    P.E .*= α
    P.F .*= α
    P.G .*= α
    return P
end
