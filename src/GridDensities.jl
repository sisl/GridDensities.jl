module GridDensities

using Distributions

export GridDensity, pdf

struct GridDensity
    lo::Vector{Float64}
    hi::Vector{Float64}
    bins::Vector{Int64}
    dist::Distributions.Categorical
    volume::Float64
    cart
    linear
end

function GridDensity(data, lo, hi, bins)
    n = prod(bins)
    @assert length(data) == n
    @assert length(lo) == length(hi) == length(bins)
    @assert all(hi .≥ lo)
    volume = prod(hi .- lo)/n # volume for each cell
    p = copy(data) ./ sum(data)
    dist = Categorical(p)
    cart = CartesianIndices(Tuple(bins))
    linear = LinearIndices(Tuple(bins))
    return GridDensity(lo, hi, bins, dist, volume, cart, linear)
end 

function _bin(x, lo, hi, bins)
    if x < lo || x > hi
        return 0
    elseif x < hi
        return Int64(floor(bins*(x - lo)/(hi - lo)) + 1)
    else
        return bins
    end
end

function pdf(d::GridDensity, x)
    dims = length(d.bins)
    @assert length(x) == dims
    @assert all(d.lo .≤ x .≤ d.hi)
    inds = [_bin(x[i], d.lo[i], d.hi[i], d.bins[i]) for i = 1:dims]
    ind = d.linear[inds...]
    return Distributions.pdf(d.dist, ind) / d.volume
end

function _rand(bin::Int64, lo, hi, bins)
    return lo + (bin-1+Base.rand())*(hi-lo)/bins
end

function Base.rand(d::GridDensity)
    ind = rand(d.dist)
    dims = length(d.bins)
    coords = d.cart[ind]
    return [_rand(coords[i], d.lo[i], d.hi[i], d.bins[i]) for i = 1:dims]
end

function Base.rand(d::GridDensity, n::Int64)
    return [Base.rand(d) for i = 1:n]
end

end # module
