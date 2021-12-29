"""
Return 6 surfaces of B-spline solid
"""
function _bsplinesurfaces(M::CustomBSplineManifold{3})
    a = controlpoints(M)
    P1, P2, P3 = bsplinespaces(M)
    I1, I2, I3 = domain(P1), domain(P2), domain(P3)
    n1, n2, n3 = dim(P1), dim(P2), dim(P3)

    t_⚀ = minimum(I1)
    t_⚁ = minimum(I2)
    t_⚂ = minimum(I3)
    t_⚃ = maximum(I1)
    t_⚄ = maximum(I2)
    t_⚅ = maximum(I3)

    B_⚀ = [bsplinebasis(P1,i,t_⚀) for i in 1:n1]
    B_⚁ = [bsplinebasis(P2,i,t_⚁) for i in 1:n2]
    B_⚂ = [bsplinebasis(P3,i,t_⚂) for i in 1:n3]
    B_⚃ = [bsplinebasis(P1,i,t_⚃) for i in 1:n1]
    B_⚄ = [bsplinebasis(P2,i,t_⚄) for i in 1:n2]
    B_⚅ = [bsplinebasis(P3,i,t_⚅) for i in 1:n3]

    a_⚀ = sum(a[i1,:,:,]*B_⚀[i1] for i1 in 1:n1)
    a_⚁ = sum(a[:,i2,:,]*B_⚁[i2] for i2 in 1:n2)
    a_⚂ = sum(a[:,:,i3,]*B_⚂[i3] for i3 in 1:n3)
    a_⚃ = sum(a[i1,:,:,]*B_⚃[i1] for i1 in 1:n1)
    a_⚄ = sum(a[:,i2,:,]*B_⚄[i2] for i2 in 1:n2)
    a_⚅ = sum(a[:,:,i3,]*B_⚅[i3] for i3 in 1:n3)

    M_⚀ = CustomBSplineManifold(a_⚀,(P2,P3))
    M_⚁ = CustomBSplineManifold(a_⚁,(P1,P3))
    M_⚂ = CustomBSplineManifold(a_⚂,(P1,P2))
    M_⚃ = CustomBSplineManifold(a_⚃,(P2,P3))
    M_⚄ = CustomBSplineManifold(a_⚄,(P1,P3))
    M_⚅ = CustomBSplineManifold(a_⚅,(P1,P2))

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

function _convert_to_custom(M::BSplineManifold)
    P = bsplinespaces(M)
    a = controlpoints(M)
    a′ = _array2arrayofvector(a)
    CustomBSplineManifold(a′,P)
end

function _convert_to_custom(M::CustomBSplineManifold)
    M
end
