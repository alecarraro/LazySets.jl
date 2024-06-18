"""
    isflat(x::Interval)

Check whether an interval is flat, i.e., whether its extreme values coincide.

### Input

- `x` -- interval

### Output

`true` if the interval is flat and `false` otherwise.

### Notes

For robustness with respect to floating-point inputs, this function relies on
the result of `isapproxzero` when applied to the diameter of the interval.
In other words, this function depends on the absolute zero tolerance `ABSZTOL`.
"""
function isflat(x::Interval)
    return isapproxzero(IA.diam(x.dat))
end
