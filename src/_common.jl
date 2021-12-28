"""
Return 6 surfaces of B-spline solid
"""
function _bsplinesurfaces(M::AbstractBSplineManifold)
    a = controlpoints(M)
    P1, P2, P3 = bsplinespaces(M)
    I1, I2, I3 = bsplineunity(P1), bsplineunity(P2), bsplineunity(P3)
    n1, n2, n3 = dim(P1), dim(P2), dim(P3)

    t_⚀ = minimum(I1)
    t_⚁ = minimum(I2)
    t_⚂ = minimum(I3)
    t_⚃ = maximum(I1)
    t_⚄ = maximum(I2)
    t_⚅ = maximum(I3)

    B_⚀ = [bsplinebasis(i,P1,t_⚀) for i in 1:n1]
    B_⚁ = [bsplinebasis(i,P2,t_⚁) for i in 1:n2]
    B_⚂ = [bsplinebasis(i,P3,t_⚂) for i in 1:n3]
    B_⚃ = [bsplinebasis(i,P1,t_⚃) for i in 1:n1]
    B_⚄ = [bsplinebasis(i,P2,t_⚄) for i in 1:n2]
    B_⚅ = [bsplinebasis(i,P3,t_⚅) for i in 1:n3]

    a_⚀ = sum(a[i1,:,:,:]*B_⚀[i1] for i1 in 1:n1)
    a_⚁ = sum(a[:,i2,:,:]*B_⚁[i2] for i2 in 1:n2)
    a_⚂ = sum(a[:,:,i3,:]*B_⚂[i3] for i3 in 1:n3)
    a_⚃ = sum(a[i1,:,:,:]*B_⚃[i1] for i1 in 1:n1)
    a_⚄ = sum(a[:,i2,:,:]*B_⚄[i2] for i2 in 1:n2)
    a_⚅ = sum(a[:,:,i3,:]*B_⚅[i3] for i3 in 1:n3)

    M_⚀ = BSplineSurface([P2,P3], a_⚀)
    M_⚁ = BSplineSurface([P1,P3], a_⚁)
    M_⚂ = BSplineSurface([P1,P2], a_⚂)
    M_⚃ = BSplineSurface([P2,P3], a_⚃)
    M_⚄ = BSplineSurface([P1,P3], a_⚄)
    M_⚅ = BSplineSurface([P1,P2], a_⚅)

    return (M_⚀, M_⚁, M_⚂, M_⚃, M_⚄, M_⚅)
end
