```@meta
CurrentModule = LazySets
```

# [Linear map (LinearMap)](@id def_LinearMap)

```@docs
LinearMap
*(::Union{AbstractMatrix, UniformScaling, AbstractVector, Real}, ::LazySet)
dim(::LinearMap)
ρ(::AbstractVector, ::LinearMap)
σ(::AbstractVector, ::LinearMap)
∈(::AbstractVector, ::LinearMap)
an_element(::LinearMap)
vertices_list(::LinearMap)
constraints_list(::LinearMap)
linear_map(::AbstractMatrix, ::LinearMap)
project(S::LazySet, ::AbstractVector{Int}, ::Type{<:LinearMap}, ::Int=dim(S))
```
Inherited from [`LazySet`](@ref):
* [`norm`](@ref norm(::LazySet, ::Real))
* [`radius`](@ref radius(::LazySet, ::Real))
* [`diameter`](@ref diameter(::LazySet, ::Real))
* [`singleton_list`](@ref singleton_list(::LazySet))
* [`reflect`](@ref reflect(::LazySet))

Inherited from [`AbstractAffineMap`](@ref):
* [`isempty`](@ref isempty(::AbstractAffineMap))
* [`isbounded`](@ref isbounded(::AbstractAffineMap))

The lazy projection of a set can be conveniently constructed using `Projection`.

```@docs
Projection
```
