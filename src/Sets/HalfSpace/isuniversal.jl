"""
    isuniversal(hs::HalfSpace, [witness]::Bool=false)

Check whether a half-space is universal.

### Input

- `P`       -- half-space
- `witness` -- (optional, default: `false`) compute a witness if activated

### Output

* If `witness` option is deactivated: `false`
* If `witness` option is activated: `(false, v)` where ``v ∉ P``

### Algorithm

Witness production falls back to `an_element(::Hyperplane)`.
"""
function isuniversal(hs::HalfSpace, witness::Bool=false)
    if witness
        v = _non_element_halfspace(hs.a, hs.b)
        return (false, v)
    else
        return false
    end
end

function _non_element_halfspace(a, b)
    return _an_element_helper_hyperplane(a, b) + a
end
