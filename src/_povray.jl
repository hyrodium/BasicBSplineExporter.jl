HEADER = "// Generated by [BasicBSplineExporter.jl](https://github.com/hyrodium/BasicBSplineExporter.jl)\n"

"""
2 -> "2"
"""
function _scriptpov(x::Integer)
    if isfinite(x)
        return repr(x)
        # return @sprintf "%1.24f" x
    else
        error("numerical value must be finite")
    end
end

"""
2.3 -> "2.3"
"""
function _scriptpov(x::Real)
    if isfinite(x)
        return repr(convert(Float64,x))
        # return @sprintf "%1.24f" x
    else
        error("numerical value must be finite")
    end
end

"""
[2.3, -5.2] -> "<2.3,-5.2>"
"""
function _scriptpov(x::AbstractVector{<:Real})
    return "<"*join(_scriptpov.(x), ", ")*">"
end

"""
[[2.3, -5.2], [-1.1, 8.2]] -> "<2.3,-5.2>, <-1.1,8.2>"
"""
function _scriptpov(x::AbstractVector{<:AbstractVector{<:Real}})
    return join(_scriptpov.(x), ", ")
end

"""
RGB(1,2,3) -> "rgb<1,2,3>"
"""
function _scriptpov(c::AbstractRGB)
    _c = RGB(c)
    v = [_c.r,_c.g,_c.b]
    return "rgb"*_scriptpov(v)
end

"""
RGB(1,2,3) -> "rgb<1,2,3>"
"""
function _scriptpov(c::ColorAlpha)
    _c = RGBA(c)
    v = [_c.r,_c.g,_c.b,1-_c.alpha]
    return "rgbt"*_scriptpov(v)
end

function _spheres(M::BSplineManifold{Dim, Deg, <:StaticVector{3}}; preindent=0, radius_name="radius_sphere") where {Dim,Deg}
    _spheres(controlpoints(M), preindent=preindent, radius_name=radius_name)
end

function _cylinders(M::BSplineManifold{Dim, Deg, <:StaticVector{3}}; preindent=0, radius_name="radius_cylinder") where {Dim,Deg}
    _cylinders(controlpoints(M), preindent=preindent, radius_name=radius_name)
end

function _spheres(a::AbstractArray{<:AbstractVector{<:Real}}; preindent=0, radius_name="radius_sphere")
    script = "  "^(preindent)
    script *= "union{\n" * "  "^(preindent)
    for ai in a
        script *= "  sphere{$(_scriptpov(ai)), $(radius_name)}\n" * "  "^(preindent)
    end
    script *= "}\n"
end

function _cylinders(a::AbstractArray{<:AbstractVector{<:Real},1}; preindent=0, radius_name="radius_cylinder")
    n = length(a)
    script = "  "^(preindent)
    script *= "union{\n" * "  "^(preindent)
    for i in 1:n-1
        script *= "  cylinder{$(_scriptpov(a[i])), $(_scriptpov(a[i+1])), $(radius_name)}\n" * "  "^(preindent)
    end
    script *= "}\n"
end

function _cylinders(a::AbstractArray{<:AbstractVector{<:Real},2}; preindent=0, radius_name="radius_cylinder")
    n1, n2 = size(a)
    script = "  "^(preindent)
    script *= "union{\n"
    for i1 in 1:n1
        script *= _cylinders(a[i1,:], preindent=preindent+1, radius_name=radius_name)
    end
    for i2 in 1:n2
        script *= _cylinders(a[:,i2], preindent=preindent+1, radius_name=radius_name)
    end
    script *= "  "^(preindent)
    script *= "}\n"
end

function _cylinders(a::AbstractArray{<:AbstractVector{<:Real},3}; preindent=0, radius_name="radius_cylinder")
    n1, n2, n3 = size(a)
    script = "  "^(preindent)
    script *= "union{\n"
    for i2 in 1:n2, i3 in 1:n3
        script *= _cylinders(a[:,i2,i3], preindent=preindent+1, radius_name=radius_name)
    end
    for i1 in 1:n1, i3 in 1:n3
        script *= _cylinders(a[i1,:,i3], preindent=preindent+1, radius_name=radius_name)
    end
    for i1 in 1:n1, i2 in 1:n2
        script *= _cylinders(a[i1,i2,:], preindent=preindent+1, radius_name=radius_name)
    end
    script *= "  "^(preindent)
    script *= "}\n"
end

function _curve(M::BSplineManifold{1, Deg, <:StaticVector{3}}; mesh=10, preindent=0, radius_name="radius_curve") where Deg
    P = bsplinespaces(M)[1]
    p = degree(P)
    k = knotvector(P)
    l = length(k)
    m = mesh

    ts = unique!(vcat([range(k[i],k[i+1],length = m+1) for i in p+1:l-p-1]...))

    𝒑s = M.(ts)

    script = "  "^(preindent)
    script *= "union{\n" * "  "^(preindent)
    script *= "  object{\n"
    script *= _spheres(𝒑s, preindent=preindent+2, radius_name=radius_name) * "  "^(preindent)
    script *= "  }\n" * "  "^(preindent)
    script *= "  object{\n"
    script *= _cylinders(𝒑s, preindent=preindent+2, radius_name=radius_name) * "  "^(preindent)
    script *= "  }\n" * "  "^(preindent)
    script *= "}\n"

    return script
end

"""
Generate POV-Ray script of `mesh2`
http://povray.org/documentation/3.7.0/r3_4.html#r3_4_5_2_4
"""
function _surface(M::BSplineManifold{2, Deg, <:StaticVector{3}}; mesh::Int=10, smooth=true, preindent=0) where Deg
    P = bsplinespaces(M)
    p1, p2 = p = degree.(P)
    k1, k2 = k = knotvector.(P)
    l1, l2 = l = length.(k)
    m1, m2 = m = (mesh, mesh)

    ts1 = unique!(vcat([range(k1[i],k1[i+1],length = m1+1) for i in p1+1:l1-p1-1]...))
    ts2 = unique!(vcat([range(k2[i],k2[i+1],length = m2+1) for i in p2+1:l2-p2-1]...))
    N1 = length(ts1)-1
    N2 = length(ts2)-1
    cs1 = [(ts1[i]+ts1[i+1])/2 for i in 1:N1]
    cs2 = [(ts2[i]+ts2[i+1])/2 for i in 1:N1]

    # 𝒆(t) = normalize(cross(BasicBSpline.tangentvectors(M,t...)...))

    𝒑s = [M(t1,t2) for t1 in ts1, t2 in ts2]
    𝒑c = [M(t1,t2) for t1 in cs1, t2 in cs2]

    # 𝒆s = 𝒆.(ts)
    # 𝒆c = 𝒆.(tc)

    Ns(i1, i2) = i1 + (N1+1) * (i2-1)
    Nc(i1, i2) = i1 + N1 * (i2-1)

    F1 = [[Ns(i1,i2)-1, Ns(i1+1,i2)-1, (N1+1)*(N2+1)+Nc(i1,i2)-1] for i1 in 1:N1, i2 in 1:N2]
    F2 = [[Ns(i1,i2)-1, Ns(i1,i2+1)-1, (N1+1)*(N2+1)+Nc(i1,i2)-1] for i1 in 1:N1, i2 in 1:N2]
    F3 = [[Ns(i1+1,i2+1)-1, Ns(i1+1,i2)-1, (N1+1)*(N2+1)+Nc(i1,i2)-1] for i1 in 1:N1, i2 in 1:N2]
    F4 = [[Ns(i1+1,i2+1)-1, Ns(i1,i2+1)-1, (N1+1)*(N2+1)+Nc(i1,i2)-1] for i1 in 1:N1, i2 in 1:N2]

    np = (N1+1)*(N2+1) + N1*N2
    nf = 4*N1*N2

    script = "  "^(preindent)
    script *= "mesh2{\n" * "  "^(preindent)
    script *= "  vertex_vectors{\n" * "  "^(preindent)
    script *= "    " * _scriptpov(np) * ", \n" * "  "^(preindent)
    script *= "    " * _scriptpov([𝒑s...]) * ", \n" * "  "^(preindent)
    script *= "    " * _scriptpov([𝒑c...]) * "\n" * "  "^(preindent)
    script *= "  }\n" * "  "^(preindent)

    # if smooth
    #     script *= "  normal_vectors{\n" * "  "^(preindent)
    #     script *= "    " * _scriptpov(np) * ", \n" * "  "^(preindent)
    #     script *= "    " * _scriptpov([𝒆s...]) * ", \n" * "  "^(preindent)
    #     script *= "    " * _scriptpov([𝒆c...]) * "\n" * "  "^(preindent)
    #     script *= "  }\n" * "  "^(preindent)
    # end

    script *= "  face_indices{\n" * "  "^(preindent)
    script *= "    " * _scriptpov(nf) * ", \n" * "  "^(preindent)
    script *= "    " * _scriptpov([F1...]) * "\n" * "  "^(preindent)
    script *= "    " * _scriptpov([F2...]) * "\n" * "  "^(preindent)
    script *= "    " * _scriptpov([F3...]) * "\n" * "  "^(preindent)
    script *= "    " * _scriptpov([F4...]) * "\n" * "  "^(preindent)
    script *= "  }\n" * "  "^(preindent)
    script *= "}\n"

    return script
end

function _solid(M::BSplineManifold{3, Deg, <:StaticVector{3}}; mesh=10, smooth=true, preindent=0) where Deg
    surfaces = _bsplinesurfaces(M)

    script = "  "^(preindent)
    script *= "union{\n"
    for M in surfaces
        script *= _surface(M, mesh=mesh, preindent=preindent+1)
    end
    script *= "  "^(preindent)
    script *= "}\n"

    return script
end

function _save_povray_1d3d(name::String, M::BSplineManifold{1, Deg, <:StaticVector{3}}; mesh::Int=10, points=true, thickness=0.1, maincolor=RGB(1,0,0), subcolor=RGB(.5,.5,.5)) where Deg
    radius_curve = thickness
    radius_cylinder = thickness
    radius_sphere = 2*radius_cylinder
    color_curve = maincolor
    color_cylinder = subcolor
    color_sphere = weighted_color_mean(0.5, subcolor, colorant"black")
    script = HEADER
    script *= "#local radius_curve = $(radius_curve);\n"
    script *= "#local radius_sphere = $(radius_sphere);\n"
    script *= "#local radius_cylinder = $(radius_cylinder);\n"
    script *= "#local color_curve = $(_scriptpov(color_curve));\n"
    script *= "#local color_sphere = $(_scriptpov(color_sphere));\n"
    script *= "#local color_cylinder = $(_scriptpov(color_cylinder));\n"
    script *= "union{\n"
    script *= "  object{\n"
    script *= _curve(M, mesh=mesh, preindent=2, radius_name=radius_curve)
    script *= "    pigment{color_curve}\n"
    script *= "  }\n"
    if points
        script *= "  object{\n"
        script *= _spheres(M, preindent=2)
        script *= "    pigment{color_sphere}\n"
        script *= "  }\n"
        script *= "  object{\n"
        script *= _cylinders(M, preindent=2)
        script *= "    pigment{color_cylinder}\n"
        script *= "  }\n"
    end
    script *= "}"

    open(name, "w") do f
        write(f,script)
    end

    return nothing
end

function _save_povray_2d3d(name::String, M::BSplineManifold{2, Deg, <:StaticVector{3}}; mesh::Int=10, points=true, thickness=0.1, maincolor=RGB(1,0,0), subcolor=RGB(.5,.5,.5)) where Deg
    radius_cylinder = thickness
    radius_sphere = 2*radius_cylinder
    color_cylinder = subcolor
    color_sphere = weighted_color_mean(0.5, subcolor, colorant"black")
    color_surface = maincolor
    script = HEADER
    script *= "#local radius_sphere = $(radius_sphere);\n"
    script *= "#local radius_cylinder = $(radius_cylinder);\n"
    script *= "#local color_sphere = $(_scriptpov(color_sphere));\n"
    script *= "#local color_cylinder = $(_scriptpov(color_cylinder));\n"
    script *= "#local color_surface = $(_scriptpov(color_surface));\n"
    script *= "union{\n"
    script *= "  object{\n"
    script *= _surface(M, mesh=mesh, preindent=2)
    script *= "    pigment{color_surface}\n"
    script *= "  }\n"
    if points
        script *= "  object{\n"
        script *= _spheres(M, preindent=2)
        script *= "    pigment{color_sphere}\n"
        script *= "  }\n"
        script *= "  object{\n"
        script *= _cylinders(M, preindent=2)
        script *= "    pigment{color_cylinder}\n"
        script *= "  }\n"
    end
    script *= "}"

    open(name, "w") do f
        write(f,script)
    end

    return nothing
end

function _save_povray_3d3d(name::String, M::BSplineManifold{3, Deg, <:StaticVector{3}}; mesh::Int=10, points=true, thickness=0.1, maincolor=RGB(1,0,0), subcolor=RGB(.5,.5,.5)) where Deg
    radius_cylinder = thickness
    radius_sphere = 2*radius_cylinder
    color_cylinder = subcolor
    color_sphere = weighted_color_mean(0.5, subcolor, colorant"black")
    color_solid = maincolor
    script = HEADER
    script *= "#local radius_sphere = $(radius_sphere);\n"
    script *= "#local radius_cylinder = $(radius_cylinder);\n"
    script *= "#local color_sphere = $(_scriptpov(color_sphere));\n"
    script *= "#local color_cylinder = $(_scriptpov(color_cylinder));\n"
    script *= "#local color_solid = $(_scriptpov(color_solid));\n"
    script *= "union{\n"
    script *= "  object{\n"
    script *= _solid(M, mesh=mesh, preindent=2)
    script *= "    pigment{color_solid}\n"
    script *= "  }\n"
    if points
        script *= "  object{\n"
        script *= _spheres(M, preindent=2)
        script *= "    pigment{color_sphere}\n"
        script *= "  }\n"
        script *= "  object{\n"
        script *= _cylinders(M, preindent=2)
        script *= "    pigment{color_cylinder}\n"
        script *= "  }\n"
    end
    script *= "}"

    open(name, "w") do f
        write(f,script)
    end

    return nothing
end

function save_pov(name::String, M::AbstractBSplineManifold{Dim}; mesh::Int=10, points=true, thickness=0.1, maincolor=RGB(1,0,0), subcolor=RGB(.5,.5,.5)) where Dim
    if Dim == 1
        _save_povray_1d3d(name,M,mesh=mesh,points=points,thickness=thickness,maincolor=maincolor,subcolor=subcolor)
    elseif Dim == 2
        _save_povray_2d3d(name,M,mesh=mesh,points=points,thickness=thickness,maincolor=maincolor,subcolor=subcolor)
    elseif Dim == 3
        _save_povray_3d3d(name,M,mesh=mesh,points=points,thickness=thickness,maincolor=maincolor,subcolor=subcolor)
    else
        error("the dimension of B-spline manifold must be 3 or less")
    end
end
