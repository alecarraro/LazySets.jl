import Base: rand,
             ∈,
             isempty

export Line,
       an_element,
       translate,
       translate!

"""
    Line{N, VN<:AbstractVector{N}} <: AbstractPolyhedron{N}

Type that represents a line of the form

```math
    \\{y ∈ ℝ^n: y = p + λd, λ ∈ ℝ\\}
```
where ``p`` is a point on the line and ``d`` is its direction vector (not
necessarily normalized).

### Fields

- `p` -- point on the line
- `d` -- direction

### Examples

There are three constructors. The optional keyword argument `normalize`
(default: `false`) can be used to normalize the direction of the resulting line
to have norm 1 (w.r.t. the Euclidean norm).

1) The default constructor takes the fields `p` and `d`:

The line passing through the point ``[-1, 2, 3]`` and parallel to the vector
``[3, 0, -1]``:

```jldoctest
julia> Line([-1.0, 2, 3], [3.0, 0, -1])
Line{Float64, Vector{Float64}}([-1.0, 2.0, 3.0], [3.0, 0.0, -1.0])

julia> Line([-1.0, 2, 3], [3.0, 0, -1]; normalize=true)
Line{Float64, Vector{Float64}}([-1.0, 2.0, 3.0], [0.9486832980505138, 0.0, -0.31622776601683794])
```

2) The second constructor takes two points, `from` and `to`, as keyword
arguments, and returns the line through them. See the algorithm section for
details.

```jldoctest
julia> Line(from=[-1.0, 2, 3], to=[-4.0, 2, 4])
Line{Float64, Vector{Float64}}([-1.0, 2.0, 3.0], [3.0, 0.0, -1.0])
```

3) The third constructor resembles `Line2D` and only works for two-dimensional
lines. It takes two inputs, `a` and `b`, and constructs the line such that
``a ⋅ x = b``.

```jldoctest
julia> Line([2.0, 0], 1.)
Line{Float64, Vector{Float64}}([0.5, 0.0], [0.0, -1.0])
```

### Algorithm

Given two points ``p ∈ ℝ^n`` and ``q ∈ ℝ^n``, the line that
passes through these two points is
`L: `\\{y ∈ ℝ^n: y = p + λ(q - p), λ ∈ ℝ\\}``.
"""
struct Line{N,VN<:AbstractVector{N}} <: AbstractPolyhedron{N}
    p::VN
    d::VN

    # default constructor with length constraint
    function Line(p::VN, d::VN; check_direction::Bool=true,
                  normalize=false) where {N,VN<:AbstractVector{N}}
        if check_direction
            @assert !iszero(d) "a line needs a non-zero direction vector"
        end
        d_n = normalize ? LinearAlgebra.normalize(d) : d
        return new{N,VN}(p, d_n)
    end
end

function Line(; from::AbstractVector, to::AbstractVector, normalize=false)
    d = from - to
    @assert !iszero(d) "points `$from` and `$to` should be distinct"
    return Line(from, d; normalize=normalize)
end

function Line(a::AbstractVector{N}, b::N; normalize=false) where {N}
    @assert length(a) == 2 "expected a normal vector of length two, but it " *
                           "is $(length(a))-dimensional"

    got_horizontal = iszero(a[1])
    got_vertical = iszero(a[2])

    if got_horizontal && got_vertical
        throw(ArgumentError("the vector $a must be non-zero"))
    end

    if got_horizontal
        α = b / a[2]
        p = [zero(N), α]
        q = [one(N), α]
    elseif got_vertical
        β = b / a[1]
        p = [β, zero(N)]
        q = [β, one(N)]
    else
        α = b / a[2]
        μ = a[1] / a[2]
        p = [zero(N), α]
        q = [one(N), α - μ]
    end
    return Line(; from=p, to=q, normalize=normalize)
end

isoperationtype(::Type{<:Line}) = false

"""
    direction(L::Line)

Return the direction of the line.

### Input

- `L` -- line

### Output

The direction of the line.

### Notes

The direction is not necessarily normalized.
See [`normalize(::Line, ::Real)`](@ref) / [`normalize!(::Line, ::Real)`](@ref).
"""
direction(L::Line) = L.d

"""
    normalize!(L::Line{N}, p::Real=N(2)) where {N}

Normalize the direction of a line storing the result in `L`.

### Input

- `L` -- line
- `p` -- (optional, default: `2.0`) vector `p`-norm used in the normalization

### Output

A line whose direction has unit norm w.r.t. the given `p`-norm.
"""
function normalize!(L::Line{N}, p::Real=N(2)) where {N}
    normalize!(L.d, p)
    return L
end

"""
    normalize(L::Line{N}, p::Real=N(2)) where {N}

Normalize the direction of a line.

### Input

- `L` -- line
- `p` -- (optional, default: `2.0`) vector `p`-norm used in the normalization

### Output

A line whose direction has unit norm w.r.t. the given `p`-norm.

### Notes

See also [`normalize!(::Line, ::Real)`](@ref) for the in-place version.
"""
function normalize(L::Line{N}, p::Real=N(2)) where {N}
    return normalize!(copy(L), p)
end

"""
    constraints_list(L::Line)

Return the list of constraints of a line.

### Input

- `L` -- line

### Output

A list containing `2n-2` half-spaces whose intersection is `L`, where `n` is the
ambient dimension of `L`.
"""
function constraints_list(L::Line)
    p = L.p
    n = length(p)
    d = reshape(L.d, 1, n)
    K = nullspace(d)
    m = size(K, 2)
    @assert m == n - 1 "expected $(n - 1) normal half-spaces, got $m"

    N, VN = _parameters(L)
    out = Vector{HalfSpace{N,VN}}(undef, 2m)
    idx = 1
    @inbounds for j in 1:m
        Kj = K[:, j]
        b = dot(Kj, p)
        out[idx] = HalfSpace(Kj, b)
        out[idx + 1] = HalfSpace(-Kj, -b)
        idx += 2
    end
    return out
end

function _parameters(L::Line{N,VN}) where {N,VN}
    return (N, VN)
end

"""
    dim(L::Line)

Return the ambient dimension of a line.

### Input

- `L` -- line

### Output

The ambient dimension of the line.
"""
dim(L::Line) = length(L.p)

"""
    ρ(d::AbstractVector, L::Line)

Evaluate the support function of a line in a given direction.

### Input

- `d` -- direction
- `L` -- line

### Output

Evaluation of the support function in the given direction.
"""
function ρ(d::AbstractVector, L::Line)
    if isapproxzero(dot(d, L.d))
        return dot(d, L.p)
    else
        N = eltype(L)
        return N(Inf)
    end
end

"""
    σ(d::AbstractVector, L::Line)

Return a support vector of a line in a given direction.

### Input

- `d` -- direction
- `L` -- line

### Output

A support vector in the given direction.
"""
function σ(d::AbstractVector, L::Line)
    if isapproxzero(dot(d, L.d))
        return L.p
    else
        throw(ArgumentError("the support vector is undefined because the " *
                            "line is unbounded in the given direction"))
    end
end

"""
    isbounded(L::Line)

Determine whether a line is bounded.

### Input

- `L` -- line

### Output

`false`.
"""
isbounded(::Line) = false

"""
    isuniversal(L::Line; [witness::Bool]=false)

Check whether a line is universal.

### Input

- `P`       -- line
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` is `false`: `true` if the ambient dimension is one, `false`
otherwise.

* If `witness` is `true`: `(true, [])` if the ambient dimension is one,
`(false, v)` where ``v ∉ P`` otherwise.
"""
isuniversal(L::Line; witness::Bool=false) = isuniversal(L, Val(witness))

# TODO implement case with witness
isuniversal(L::Line, ::Val{false}) = dim(L) == 1

"""
    an_element(L::Line)

Return some element of a line.

### Input

- `L` -- line

### Output

An element on the line.
"""
an_element(L::Line) = L.p

"""
    ∈(x::AbstractVector, L::Line)

Check whether a given point is contained in a line.

### Input

- `x` -- point/vector
- `L` -- line

### Output

`true` iff `x ∈ L`.

### Algorithm

The point ``x`` belongs to the line ``L : p + λd`` if and only if ``x - p`` is
proportional to the direction ``d``.
"""
function ∈(x::AbstractVector, L::Line)
    @assert length(x) == dim(L) "expected the point and the line to have the " *
                                "same dimension, but they are $(length(x)) and $(dim(L)) respectively"

    # the following check is necessary because the zero vector is a special case
    _isapprox(x, L.p) && return true

    return first(ismultiple(x - L.p, L.d))
end

"""
    rand(::Type{Line}; [N]::Type{<:Real}=Float64, [dim]::Int=2,
         [rng]::AbstractRNG=GLOBAL_RNG, [seed]::Union{Int, Nothing}=nothing)

Create a random line.

### Input

- `Line` -- type for dispatch
- `N`    -- (optional, default: `Float64`) numeric type
- `dim`  -- (optional, default: 2) dimension
- `rng`  -- (optional, default: `GLOBAL_RNG`) random number generator
- `seed` -- (optional, default: `nothing`) seed for reseeding

### Output

A random line.

### Algorithm

All numbers are normally distributed with mean 0 and standard deviation 1.
"""
function rand(::Type{Line};
              N::Type{<:Real}=Float64,
              dim::Int=2,
              rng::AbstractRNG=GLOBAL_RNG,
              seed::Union{Int,Nothing}=nothing)
    rng = reseed!(rng, seed)
    d = randn(rng, N, dim)
    while iszero(d)
        d = randn(rng, N, dim)
    end
    p = randn(rng, N, dim)
    return Line(p, d)
end

"""
    isempty(L::Line)

Check whether a line is empty or not.

### Input

- `L` -- line

### Output

`false`.
"""
isempty(::Line) = false

"""
    translate(L::Line, v::AbstractVector)

Translate (i.e., shift) a line by a given vector.

### Input

- `L` -- line
- `v` -- translation vector

### Output

A translated line.

### Notes

See also `translate!` for the in-place version.
"""
function translate(L::Line, v::AbstractVector)
    return translate!(copy(L), v)
end

"""
    translate!(L::Line, v::AbstractVector)

Translate (i.e., shift) a line by a given vector, in-place.

### Input

- `L` -- line
- `v` -- translation vector

### Output

The line `L` translated by `v`.
"""
function translate!(L::Line, v::AbstractVector)
    @assert length(v) == dim(L) "cannot translate a $(dim(L))-dimensional " *
                                "set by a $(length(v))-dimensional vector"

    L.p .+= v
    return L
end

"""
    distance(x::AbstractVector, L::Line; [p]::Real=2.0)

Compute the distance between point `x` and the line with respect to the given
`p`-norm.

### Input

- `x` -- point/vector
- `L` -- line
- `p` -- (optional, default: `2.0`) the `p`-norm used; `p = 2.0` corresponds to
         the usual Euclidean norm

### Output

A scalar representing the distance between `x` and the line `L`.
"""
@commutative function distance(x::AbstractVector, L::Line; p::Real=2.0)
    d = L.d  # direction of the line
    t = dot(x - L.p, d) / dot(d, d)
    return distance(x, L.p + t * d; p=p)
end

"""
    linear_map(M::AbstractMatrix, L::Line)

Concrete linear map of a line.

### Input

- `M` -- matrix
- `L` -- line

### Output

The line obtained by applying the linear map, if that still results in a line,
or a `Singleton` otherwise.

### Algorithm

We apply the linear map to the point and direction of `L`.
If the resulting direction is zero, the result is a singleton.
"""
function linear_map(M::AbstractMatrix, L::Line)
    @assert dim(L) == size(M, 2) "a linear map of size $(size(M)) cannot be " *
                                 "applied to a set of dimension $(dim(L))"

    Mp = M * L.p
    Md = M * L.d
    if iszero(Md)
        return Singleton(Mp)
    end
    return Line(Mp, Md)
end

function project(L::Line{N}, block::AbstractVector{Int}; kwargs...) where {N}
    d = L.d[block]
    if iszero(d)
        return Singleton(L.p[block])  # projected out all nontrivial dimensions
    elseif length(d) == 1
        return Universe{N}(1)  # special case: 1D line is a universe
    else
        return Line(L.p[block], d)
    end
end
