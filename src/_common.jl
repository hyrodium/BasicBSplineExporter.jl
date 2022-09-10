"""
Return 6 surfaces of B-spline solid
"""
function _bsplinesurfaces(M::BSplineManifold{3})
    P1, P2, P3 = bsplinespaces(M)
    I1, I2, I3 = domain(P1), domain(P2), domain(P3)

    t_⚀ = minimum(I1)
    t_⚁ = minimum(I2)
    t_⚂ = minimum(I3)
    t_⚃ = maximum(I1)
    t_⚄ = maximum(I2)
    t_⚅ = maximum(I3)

    M_⚀ = M(t_⚀,:,:)
    M_⚁ = M(:,t_⚁,:)
    M_⚂ = M(:,:,t_⚂)
    M_⚃ = M(t_⚃,:,:)
    M_⚄ = M(:,t_⚄,:)
    M_⚅ = M(:,:,t_⚅)

    return (M_⚀, M_⚁, M_⚂, M_⚃, M_⚄, M_⚅)
end

function _arrayofvector2array(a::AbstractArray{<:AbstractVector{T},d})::Array{T,d+1} where {d, T<:Real}
    d̂ = length(a[1])
    s = size(a)
    N = prod(s)
    a_2dim = [a[i][j] for i in 1:N, j in 1:d̂]
    a′ = reshape(a_2dim, s..., d̂)
    return a′
end

function _array2arrayofvector(a::AbstractArray{T,d}) where {d, T<:Real}
    s = size(a)
    d̂ = s[end]
    N = s[1:end-1]
    a_flat = reshape(a,prod(N),d̂)
    a_vec = [SVector{d̂}(a_flat[i,:]) for i in 1:prod(N)]
    a′ = reshape(a_vec,N)
    return a′
end
