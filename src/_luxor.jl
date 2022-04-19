"""
control points of Bézier curve from given function and range
"""
function _bezier(f,a,b)
    f(a),
    3*(f(2*a/3+b/3)-(8*f(a)+f(b))/27)-3*(f(a/3+2*b/3)-(f(a)+8*f(b))/27)/2,
    -3*(f(2*a/3+b/3)-(8*f(a)+f(b))/27)/2+3*(f(a/3+2*b/3)-(f(a)+8*f(b))/27),
    f(b)
end

function _luxor_pt(p::AbstractVector{<:Real}, unitlength)
    Luxor.Point(unitlength*[1,-1].*p...)
end

"""
export svg file
"""
function save_svg(name::AbstractString, M::AbstractBSplineManifold{1}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    split(name,'.')[end] ≠ "svg" && error("extension shuould be .svg")
    _save_luxor_1d2d(name, M, xlims=xlims, ylims=ylims, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export svg file
"""
function save_svg(name::AbstractString, M::AbstractBSplineManifold{2}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    split(name,'.')[end] ≠ "svg" && error("extension shuould be .svg")
    _save_luxor_2d2d(name, M, xlims=xlims, ylims=ylims, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export png file
"""
function save_png(name::AbstractString, M::AbstractBSplineManifold{1}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    split(name,'.')[end] ≠ "png" && error("extension shuould be .png")
    _save_luxor_1d2d(name, M, xlims=xlims, ylims=ylims, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export png file
"""
function save_png(name::AbstractString, M::AbstractBSplineManifold{2}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    split(name,'.')[end] ≠ "png" && error("extension shuould be .png")
    _save_luxor_2d2d(name, M, xlims=xlims, ylims=ylims, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export png file
"""
function save_png(name::AbstractString, M::AbstractBSplineManifold{2}, colors::AbstractArray{<:Colorant,2}; xlims=(-5,5), ylims=(-5,5), unitlength=100)
    split(name,'.')[end] ≠ "png" && error("extension shuould be .png")

    _save_luxor_2d2d_color(name, M, colors, xlims=xlims, ylims=ylims, unitlength=unitlength)
end

"""
export png file
"""
function save_png(name::AbstractString, M::AbstractBSplineManifold{2}, colorfunc::Function; xlims=(-5,5), ylims=(-5,5), unitlength=100)
    split(name,'.')[end] ≠ "png" && error("extension shuould be .png")

    _save_luxor_2d2d_color(name, M, colorfunc, xlims=xlims, ylims=ylims, unitlength=unitlength)
end


function _save_luxor_2d2d(name::AbstractString, M::BSplineManifold{2, Deg, <:StaticVector{2}}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0), subcolor=RGB(0.5,0.5,0.5)) where Deg
    left, right = xlims
    down, up = ylims
    linecolor = maincolor
    fillcolor = weighted_color_mean(0.5, maincolor, colorant"white")
    segmentcolor = subcolor
    pointcolor = weighted_color_mean(0.5, subcolor, colorant"black")

    P = bsplinespaces(M)
    p = degree.(P)
    k = knotvector.(P)
    a = controlpoints(M)
    n¹, n² = n = dim.(P)

    K¹, K² = K = [unique(k[i][1+p[i]:end-p[i]]) for i in 1:2]
    N¹, N² = length.(K).-1
    m¹, m² = mesh

    Drawing(unitlength*(right-left),unitlength*(up-down),name)
    Luxor.origin(-unitlength*left,unitlength*up)
    setline(thickness)
    background(backgroundcolor)

    setcolor(fillcolor)
    drawbezierpath(BezierPath(vcat(
        [BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u¹->M(u¹,K²[1]),K¹[i],K¹[i+1]))...) for i in 1:N¹],
        [BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u²->M(K¹[end],u²),K²[i],K²[i+1]))...) for i in 1:N²],
        [BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u¹->M(u¹,K²[end]),K¹[end-i+1],K¹[end-i]))...) for i in 1:N¹],
        [BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u²->M(K¹[1],u²),K²[end-i+1],K²[end-i]))...) for i in 1:N²]
    )),:fill,close=true)

    setcolor(linecolor)
    for u¹ in range(K¹[1],stop=K¹[end],length=m¹+1)
        drawbezierpath(BezierPath([BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u²->M(u¹,u²),K²[i],K²[i+1]))...) for i in 1:N²]),:stroke)
    end
    for u² in range(K²[1],stop=K²[end],length=m²+1)
        drawbezierpath(BezierPath([BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u¹->M(u¹,u²),K¹[i],K¹[i+1]))...) for i in 1:N¹]),:stroke)
    end

    if points
        CtrlPts = [_luxor_pt(a[i,j],unitlength) for i in 1:n¹, j in 1:n²]

        setcolor(segmentcolor)
        setline(thickness)
        for i in 1:n[1]
            poly(CtrlPts[i,:], :stroke)
        end
        for j in 1:n[2]
            poly(CtrlPts[:,j], :stroke)
        end

        setcolor(pointcolor)
        map(p->circle(p,3*thickness,:fill), CtrlPts)
    end
    finish()
    return nothing
end

function _save_luxor_1d2d(name::AbstractString, M::BSplineManifold{1, Deg, <:StaticVector{2}}; xlims=(-5,5), ylims=(-5,5), mesh=10, unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0), subcolor=RGB(.5,.5,.5)) where Deg
    left, right = xlims
    down, up = ylims
    linecolor = maincolor
    segmentcolor = subcolor
    pointcolor = weighted_color_mean(0.5, subcolor, colorant"black")

    a = controlpoints(M)

    P¹ = bsplinespaces(M)[1]
    p¹ = degree(P¹)
    k¹ = knotvector(P¹)
    n¹ = dim(P¹)
 
    K¹ = unique(k¹[1+p¹:end-p¹])

    N¹ = length(K¹)-1

    Drawing(unitlength*(right-left),unitlength*(up-down),name)
    Luxor.origin(-unitlength*left,unitlength*up)
    setline(2*thickness)
    background(backgroundcolor)

    setcolor(linecolor)
    drawbezierpath(BezierPath([BezierPathSegment(map(q->_luxor_pt(q,unitlength),_bezier(u¹->M(u¹),K¹[i],K¹[i+1]))...) for i in 1:N¹]),:stroke)

    if points
        CtrlPts = [_luxor_pt(a[i],unitlength) for i in 1:n¹]

        setcolor(segmentcolor)
        setline(thickness)
        poly(CtrlPts[:], :stroke)

        setcolor(pointcolor)
        map(q->circle(q,3*thickness,:fill), CtrlPts)
    end
    finish()
    return nothing
end

function _save_luxor_2d2d_color(name::AbstractString, M::BSplineManifold{2, Deg, <:StaticVector{2}}, colors::AbstractArray{<:Colorant,2}; xlims=(-5,5), ylims=(-5,5), unitlength=100) where Deg
    C = BSplineManifold(colors, bsplinespaces(M))
    _save_luxor_2d2d_color(name, M, C; xlims=xlims, ylims=ylims, unitlength=unitlength)
end

function _save_luxor_2d2d_color(name::AbstractString, M::BSplineManifold{2, Deg, <:StaticVector{2}}, colorfunc; xlims=(-5,5), ylims=(-5,5), unitlength=100) where Deg
    left, right = xlims
    down, up = ylims
    mesh = 10

    P = bsplinespaces(M)
    p¹, p² = degree.(P)
    k¹, k² = knotvector.(P)

    K¹ = unique(vcat([collect(range(k¹[i], k¹[i+1], length=mesh+1)) for i in 1+p¹:length(k¹)-p¹-1]...))
    K² = unique(vcat([collect(range(k²[i], k²[i+1], length=mesh+1)) for i in 1+p²:length(k²)-p²-1]...))

    Drawing(unitlength*(right-left),unitlength*(up-down),name)
    Luxor.origin(-unitlength*left,unitlength*up)
    background(RGBA(0,0,0,0))

    for I₁ in 1:length(K¹)-1, I₂ in 1:length(K²)-1
        BézPth=BezierPath([
                BezierPathSegment(map(q->_luxor_pt(q,unitlength),_bezier(t->M(t,K²[I₂]),K¹[I₁],K¹[I₁+1]))...),
                BezierPathSegment(map(q->_luxor_pt(q,unitlength),_bezier(t->M(K¹[I₁+1],t),K²[I₂],K²[I₂+1]))...),
                BezierPathSegment(map(q->_luxor_pt(q,unitlength),_bezier(t->M(t,K²[I₂+1]),K¹[I₁+1],K¹[I₁]))...),
                BezierPathSegment(map(q->_luxor_pt(q,unitlength),_bezier(t->M(K¹[I₁],t),K²[I₂+1],K²[I₂]))...)])
        mesh1 = Luxor.mesh(BézPth, [
            colorfunc(K¹[I₁],   K²[I₂]  ),
            colorfunc(K¹[I₁+1], K²[I₂]  ),
            colorfunc(K¹[I₁+1], K²[I₂+1]),
            colorfunc(K¹[I₁],   K²[I₂+1]),
            ])
        setmesh(mesh1)
        box(_luxor_pt([right+left,up+down]/2,unitlength), (right-left)*unitlength,(up-down)*unitlength,:fill)
    end
    finish()
    return nothing
end
