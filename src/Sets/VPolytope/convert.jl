"""
    convert(::Type{VPolytope}, X::LazySet; [prune]::Bool=true)

Convert a polytopic set to a polytope in vertex representation.

### Input

- `VPolytope` -- target type
- `X`         -- polytopic set
- `prune`     -- (optional, default: `true`) option to remove redundant vertices

### Output

The given set represented as a polytope in vertex representation.

### Algorithm

This method uses `vertices_list`. Use the option `prune` to select whether to
remove redundant vertices before constructing the polytope.
"""
function convert(::Type{VPolytope}, X::LazySet; prune::Bool=true)
    return VPolytope(vertices_list(X; prune=prune))
end
