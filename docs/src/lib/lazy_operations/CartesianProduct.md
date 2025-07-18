```@meta
CurrentModule = LazySets
```

# Cartesian product

## [Binary Cartesian product (CartesianProduct)](@id def_CartesianProduct)

```@docs
CartesianProduct
×(::LazySet, ::LazySet)
*(::LazySet, ::LazySet)
swap(::CartesianProduct)
dim(::CartesianProduct)
ρ(::AbstractVector, ::CartesianProduct)
σ(::AbstractVector, ::CartesianProduct)
isbounded(::CartesianProduct)
∈(::AbstractVector, ::CartesianProduct)
isempty(::CartesianProduct)
center(::CartesianProduct)
constraints_list(::CartesianProduct)
vertices_list(::CartesianProduct)
linear_map(::AbstractMatrix, ::CartesianProduct)
volume(::CartesianProduct)
project(::CartesianProduct{N,<:Interval,<:AbstractHyperrectangle}, ::AbstractVector{Int}) where {N}
project(::CartesianProduct{N,<:Interval,<:AbstractZonotope}, ::AbstractVector{Int}) where {N}
project(::CartesianProduct{N,<:Interval,<:Union{VPolygon,VPolytope}}, ::AbstractVector{Int}) where {N}
```
Inherited from [`LazySet`](@ref):
* [`norm`](@ref norm(::LazySet, ::Real))
* [`radius`](@ref radius(::LazySet, ::Real))
* [`diameter`](@ref diameter(::LazySet, ::Real))
* [`an_element`](@ref an_element(::LazySet)
* [`singleton_list`](@ref singleton_list(::LazySet))
* [`reflect`](@ref reflect(::LazySet))

## [``n``-ary Cartesian product (CartesianProductArray)](@id def_CartesianProductArray)

```@docs
CartesianProductArray
CartesianProduct!
×(::LazySet, ::LazySet...)
*(::LazySet, ::LazySet...)
dim(::CartesianProductArray)
ρ(::AbstractVector, ::CartesianProductArray)
σ(::AbstractVector, ::CartesianProductArray)
isbounded(::CartesianProductArray)
∈(::AbstractVector, ::CartesianProductArray)
isempty(::CartesianProductArray)
center(::CartesianProductArray)
constraints_list(::CartesianProductArray)
vertices_list(::CartesianProductArray)
linear_map(M::AbstractMatrix, ::CartesianProductArray)
array(::CartesianProductArray)
volume(::CartesianProductArray)
block_structure(::CartesianProductArray)
block_to_dimension_indices(::CartesianProductArray, vars::Vector{Int})
substitute_blocks(::CartesianProductArray, ::CartesianProductArray, ::Vector{Tuple{Int,Int}})
```
Inherited from [`LazySet`](@ref):
* [`norm`](@ref norm(::LazySet, ::Real))
* [`radius`](@ref radius(::LazySet, ::Real))
* [`diameter`](@ref diameter(::LazySet, ::Real))
* [`an_element`](@ref an_element(::LazySet)
* [`singleton_list`](@ref singleton_list(::LazySet))
* [`reflect`](@ref reflect(::LazySet))
