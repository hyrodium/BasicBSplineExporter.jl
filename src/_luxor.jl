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
    Point(unitlength*[1,-1].*p...)
end

"""
export svg file
"""
function save_svg(name::String, M::BSplineManifold{1}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    left, right = xlims
    down, up = ylims
    if split(name,'.')[end] ≠ "svg"
        name = name * ".svg"
    end
    _save_luxor_1d2d(name, M, up=up, down=down, right=right, left=left, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export svg file
"""
function save_svg(name::String, M::BSplineManifold{2}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    left, right = xlims
    down, up = ylims
    if split(name,'.')[end] ≠ "svg"
        name = name * ".svg"
    end
    _save_luxor_2d2d(name, M, up=up, down=down, right=right, left=left, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export png file
"""
function save_png(name::String, M::BSplineManifold{1}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    left, right = xlims
    down, up = ylims
    if split(name,'.')[end] ≠ "png"
        name = name * ".png"
    end
    _save_luxor_1d2d(name, M, up=up, down=down, right=right, left=left, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export png file
"""
function save_png(name::String, M::BSplineManifold{2}; xlims=(-5,5), ylims=(-5,5), mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0))
    left, right = xlims
    down, up = ylims
    if split(name,'.')[end] ≠ "png"
        name = name * ".png"
    end
    _save_luxor_2d2d(name, M, up=up, down=down, right=right, left=left, mesh=mesh, unitlength=unitlength, points=points, thickness=thickness, backgroundcolor=backgroundcolor, maincolor=maincolor)
end

"""
export png file
"""
function save_png(name::String, M::BSplineManifold{2}, colors::AbstractArray{<:Colorant,2}; xlims=(-5,5), ylims=(-5,5), unitlength=100)
    left, right = xlims
    down, up = ylims
    if split(name,'.')[end] ≠ "png"
        name = name * ".png"
    end

    _save_luxor_2d2d_color(name, M, colors, up=up, down=down, right=right, left=left, unitlength=unitlength)
end

"""
export png file
"""
function save_png(name::String, M::BSplineManifold{2}, colorfunc::Function; xlims=(-5,5), ylims=(-5,5), unitlength=100)
    left, right = xlims
    down, up = ylims
    if split(name,'.')[end] ≠ "png"
        name = name * ".png"
    end

    _save_luxor_2d2d_color(name, M, colorfunc, up=up, down=down, right=right, left=left, unitlength=unitlength)
end


function _save_luxor_2d2d(name::String, M::BSplineManifold{2}; up=5, down=-5, right=5, left=-5, mesh=(10,10), unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0), subcolor=RGB(0.5,0.5,0.5))
    linecolor = maincolor
    fillcolor = weighted_color_mean(0.5, maincolor, colorant"white")
    segmentcolor = subcolor
    pointcolor = weighted_color_mean(0.5, subcolor, colorant"black")

    P1, P2 = P = collect(bsplinespaces(M))
    p¹, p² = p = degree.(P)
    k¹, k² = k = knotvector.(P)
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
        CtrlPts = [_luxor_pt(a[i,j,:],unitlength) for i in 1:size(a)[1], j in 1:size(a)[2]]

        setcolor(segmentcolor)
        setline(thickness)
        for i in 1:n¹
            poly(CtrlPts[i,:], :stroke)
        end
        for j in 1:n²
            poly(CtrlPts[:,j], :stroke)
        end

        setcolor(pointcolor)
        map(p->circle(p,3*thickness,:fill), CtrlPts)
    end
    finish()
    return nothing
end

function _save_luxor_1d2d(name::String, M::BSplineManifold{1}; up=5, down=-5, right=5, left=-5, mesh=10, unitlength=100, points=true, thickness=1, backgroundcolor=RGB(1,1,1), maincolor=RGB(1,0,0), subcolor=RGB(.5,.5,.5))
    linecolor = maincolor
    segmentcolor = subcolor
    pointcolor = weighted_color_mean(0.5, subcolor, colorant"black")

    P1, = P = collect(bsplinespaces(M))
    p¹, = p = degree.(P)
    k¹, = k = knotvector.(P)
    a = controlpoints(M)
    n¹, = n = dim.(P)

    K¹, = K = [unique(k[i][1+p[i]:end-p[i]]) for i in 1:1]
    N¹, = length.(K).-1
    m¹, = mesh

    Drawing(unitlength*(right-left),unitlength*(up-down),name)
    Luxor.origin(-unitlength*left,unitlength*up)
    setline(2*thickness)
    background(backgroundcolor)

    setcolor(linecolor)
    drawbezierpath(BezierPath([BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(u¹->M(u¹),K¹[i],K¹[i+1]))...) for i in 1:N¹]),:stroke)

    if points
        CtrlPts = [_luxor_pt(a[i,:],unitlength) for i in 1:size(a)[1]]

        setcolor(segmentcolor)
        setline(thickness)
        poly(CtrlPts[:], :stroke)

        setcolor(pointcolor)
        map(p->circle(p,3*thickness,:fill), CtrlPts)
    end
    finish()
    return nothing
end

function _save_luxor_2d2d_color(name::String, M::BSplineManifold{2}, colors::AbstractArray{<:Colorant,2}; up=5, down=-5, right=5, left=-5, unitlength=100)
    C = CustomBSplineManifold(colors, bsplinespaces(M))
    _save_luxor_2d2d_color(name, M, C; up=up, down=down, right=right, left=left, unitlength=unitlength)
end

function _save_luxor_2d2d_color(name::String, M::BSplineManifold{2}, colorfunc; up=5, down=-5, right=5, left=-5, unitlength=100)
    mesh = 10

    P = collect(bsplinespaces(M))
    p¹, p² = p = degree.(P)
    k¹, k² = k = knotvector.(P)
    a = controlpoints(M)
    n¹, n² = n = dim.(P)

    D = [k[i][1+p[i]]..k[i][end-p[i]] for i in 1:2]

    K¹ = unique(vcat([collect(range(k¹[i], k¹[i+1], length=mesh+1)) for i in 1+p¹:length(k¹)-p¹-1]...))
    K² = unique(vcat([collect(range(k²[i], k²[i+1], length=mesh+1)) for i in 1+p²:length(k²)-p²-1]...))

    Drawing(unitlength*(right-left),unitlength*(up-down),name)
    Luxor.origin(-unitlength*left,unitlength*up)
    background(RGBA(0,0,0,0))

    for I₁ in 1:length(K¹)-1, I₂ in 1:length(K²)-1
        BézPth=BezierPath([
                BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(t->M(t,K²[I₂]),K¹[I₁],K¹[I₁+1]))...),
                BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(t->M(K¹[I₁+1],t),K²[I₂],K²[I₂+1]))...),
                BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(t->M(t,K²[I₂+1]),K¹[I₁+1],K¹[I₁]))...),
                BezierPathSegment(map(p->_luxor_pt(p,unitlength),_bezier(t->M(K¹[I₁],t),K²[I₂+1],K²[I₂]))...)])
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
