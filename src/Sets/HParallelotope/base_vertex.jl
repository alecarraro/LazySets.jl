"""
    base_vertex(P::HParallelotope)

Compute the base vertex of a parallelotope in constraint representation.

### Input

- `P` -- parallelotope in constraint representation

### Output

The base vertex of `P`.

### Algorithm

Intuitively, the base vertex is the point from which we get the relative
positions of all the other points.
The base vertex can be computed as the solution of the ``n``-dimensional linear
system ``D_i x = c_{n+i}`` for ``i = 1, …, n``, see [1, Section 3.2.1].

[1] Dreossi, Tommaso, Thao Dang, and Carla Piazza. *Reachability computation for
polynomial dynamical systems.* Formal Methods in System Design 50.1 (2017): 1-38.
"""
function base_vertex(P::HParallelotope)
    D, c = P.directions, P.offset
    n = dim(P)
    v = to_negative_vector(view(c, (n + 1):(2n))) # converts to a dense vector as well
    return D \ v
end
