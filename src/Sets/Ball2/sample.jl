"""
    sample(B::Ball2{N}, [nsamples]::Int;
           [rng]::AbstractRNG=GLOBAL_RNG,
           [seed]::Union{Int, Nothing}=nothing) where {N}

Return samples from a uniform distribution on the given ball in the 2-norm.

### Input

- `B`        -- ball in the 2-norm
- `nsamples` -- number of random samples
- `rng`      -- (optional, default: `GLOBAL_RNG`) random number generator
- `seed`     -- (optional, default: `nothing`) seed for reseeding

### Output

A linear array of `nsamples` elements drawn from a uniform distribution in `B`.

### Algorithm

Random sampling with uniform distribution in `B` is computed using Muller's method
of normalized Gaussians. This function requires the package `Distributions`.
See `_sample_unit_nball_muller!` for implementation details.
"""
function sample(B::Ball2{N}, nsamples::Int;
                rng::AbstractRNG=GLOBAL_RNG,
                seed::Union{Int,Nothing}=nothing) where {N}
    require(@__MODULE__, :Distributions; fun_name="sample")
    n = dim(B)
    D = Vector{Vector{N}}(undef, nsamples) # preallocate output
    _sample_unit_nball_muller!(D, n, nsamples; rng=rng, seed=seed)

    # customize for the given ball
    r, c = B.radius, B.center
    @inbounds for i in 1:nsamples
        axpby!(one(N), c, r, D[i])
    end
    return D
end

"""
    _sample_unit_nball_muller!(D::Vector{Vector{N}}, n::Int, p::Int;
                               [rng]::AbstractRNG=GLOBAL_RNG,
                               [seed]::Union{Int, Nothing}=nothing) where {N}

Draw samples from a uniform distribution on an ``n``-dimensional unit ball
using Muller's method.

### Input

- `D`    -- output, vector of points
- `n`    -- dimension of the ball
- `p`    -- number of random samples
- `rng`  -- (optional, default: `GLOBAL_RNG`) random number generator
- `seed` -- (optional, default: `nothing`) seed for reseeding

### Output

The modified vector `D`.

### Algorithm

This function implements Muller's method of normalized Gaussians [1] to
uniformly sample from the interior of the unit ball.

Given ``n`` Gaussian random variables ``Z₁, Z₂, …, Z_n`` and a uniformly
distributed random variable ``r`` with support in ``[0, 1]``, the distribution
of the vectors

```math
\\dfrac{r^{1/n}}{α} \\left(z₁, z₂, …, z_n\\right)^T,
```
where ``α := \\sqrt{z₁² + z₂² + … + z_n²}``, is uniform over the
``n``-dimensional unit ball.

[1] Muller, Mervin E. *A note on a method for generating points uniformly on
    n-dimensional spheres.* Communications of the ACM 2.4 (1959): 19-20.
"""
function _sample_unit_nball_muller!(D::Vector{Vector{N}}, n::Int, p::Int;
                                    rng::AbstractRNG=GLOBAL_RNG,
                                    seed::Union{Int,Nothing}=nothing) where {N}
    return _sample_unit_nball_muller_distributions!(D, n, p; rng=rng, seed=seed)
end

function load_distributions_samples()
    return quote
        using .Distributions: Uniform, Normal

        function _sample_unit_nball_muller_distributions!(D::Vector{Vector{N}}, n::Int,
                                                          p::Int;
                                                          rng::AbstractRNG=GLOBAL_RNG,
                                                          seed::Union{Int,Nothing}=nothing) where {N}
            rng = reseed!(rng, seed)
            Zdims = [Normal() for _ in 1:n] # normal distributions for each dimension
            Zrad = Uniform() # distribution to pick random radius
            one_over_n = one(N) / n
            v = Vector{N}(undef, n) # sample direction
            @inbounds for j in 1:p
                α = zero(N)
                for i in 1:n
                    v[i] = rand(rng, Zdims[i])
                    α += v[i]^2
                end
                r = rand(rng, Zrad)
                β = r^one_over_n / sqrt(α)
                D[j] = v .* β
            end
            return D
        end
    end
end  # quote / load_distributions_samples()
