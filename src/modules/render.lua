--[[
===========================================================================

Render

Has basic functions to convert world coords -> camera coords -> screen coords.
Also has methods to draw 3d line, grid, polygon and horizon.
===========================================================================
]]

local M = {}

--[[
========================
render.UpdateMatrix

Types: xyz, zyx, yxz
========================
]]
function M.UpdateMatrix( type, obj )
	local sin, cos = math.sin, math.cos
	local rx, ry, rz = obj.rx, obj.ry, obj.rz
	local m = {}
	if type == "xyz" then
		m = {
			side = {
				x = cos( ry ) * cos( rz ),
				y = sin( rx ) * sin( ry ) * cos( rz ) - cos( rx ) * sin( rz ),
				z = cos( rx ) * sin( ry ) * cos( rz ) + sin( rx ) * sin( rz ),
			},
			top = {
				x = cos( ry ) * sin( rz ),
				y = sin( rx ) * sin( ry ) * sin( rz ) + cos( rx ) * cos( rz ),
				z = cos( rx ) * sin( ry ) * sin( rz ) - sin( rx ) * cos( rz ),
			},
			front = {
				x = - sin( ry ),
				y =   sin( rx ) * cos( ry ),
				z =   cos( rx ) * cos( ry ),
			},
		}
	elseif type == "zyx" then
		m = {
			side = {
				x =   cos( rz ) * cos( ry ),
				y = - sin( rz ) * cos( ry ),
				z =   sin( ry ),
			},
			top = {
				x =   sin( rz ) * cos( rx ) + cos( rz ) * sin( ry ) * sin( rx ),
				y =   cos( rz ) * cos( rx ) - sin( rz ) * sin( ry ) * sin( rx ),
				z = - cos( ry ) * sin( rx ),
			},
			front = {
				x = sin( rz ) * sin( rx ) - cos( rz ) * sin( ry ) * cos( rx ),
				y = cos( rz ) * sin( rx ) + sin( rz ) * sin( ry ) * cos( rx ),
				z = cos( ry ) * cos( rx ),
			},
		}
	elseif type == "yxz" then
		m = {
			side = {
				x =   cos( ry ) * cos( rz ) - sin( ry ) * sin( rx ) * sin( rz ),
				y = - cos( rx ) * sin( rz ),
				z =   sin( ry ) * cos( rz ) + cos( ry ) * sin( rx ) * sin( rz ),
			},
			top = {
				x =   cos( ry ) * sin( rz ) + sin( ry ) * sin( rx ) * cos( rz ),
				y =   cos( rx ) * cos( rz ),
				z =   sin( ry ) * sin( rz ) - cos( ry ) * sin( rx ) * cos( rz ),
			},
			front = {
				x = - sin( ry ) * cos( rx ),
				y =   sin( rx ),
				z =   cos( ry ) * cos( rx ),
			},
		}
	end
	m.offset = { x = obj.x, y = obj.y, z = obj.z }
	obj.matrix = m
end

--[[
========================
render.CameraToScreenPoint
========================
]]
function M.CameraToScreenPoint( p )
	local ps = nil
	if p.z >= camera.view.nearClip then
		local screenWidth = 2 * math.tan( camera.view.fov / 2 ) * camera.view.nearClip
		ps = {}
		ps.x = camera.width  / 2 + ( camera.width / screenWidth ) * ( camera.view.nearClip /  p.z ) * p.x
		ps.y = camera.height / 2 - ( camera.width / screenWidth ) * ( camera.view.nearClip /  p.z ) * p.y
	end
	return ps
end

--[[
========================
render.CameraToScreenSegment
========================
]]
function M.CameraToScreenSegment( a, b )
	local as, bs = nil, nil
	local GetSegmentScreenPOI = function( a, b ) return
		{
			x = ( camera.view.nearClip - a.z ) * ( a.x - b.x ) / ( a.z - b.z ) + a.x,
			y = ( camera.view.nearClip - a.z ) * ( a.y - b.y ) / ( a.z - b.z ) + a.y,
			z = camera.view.nearClip 
		}
	end
	if a.z > camera.view.nearClip and b.z > camera.view.nearClip then 
		as = M.CameraToScreenPoint( a )
		bs = M.CameraToScreenPoint( b )
	elseif a.z < camera.view.nearClip and b.z > camera.view.nearClip then
		local c = GetSegmentScreenPOI( a, b )
		as = M.CameraToScreenPoint( c )
		bs = M.CameraToScreenPoint( b )
	elseif a.z > camera.view.nearClip and b.z < camera.view.nearClip then
		local c = GetSegmentScreenPOI( b, a )
		as = M.CameraToScreenPoint( a )
		bs = M.CameraToScreenPoint( c )
	end
	return as, bs
end

--[[
========================
render.TransformMatrix
========================
]]
function M.TransformMatrix( m1, m2 )
	local m = {}
	m.side = {
		x = m1.side.x * m2.side.x + m1.top.x * m2.side.y + m1.front.x * m2.side.z,
		y = m1.side.y * m2.side.x + m1.top.y * m2.side.y + m1.front.y * m2.side.z,
		z = m1.side.z * m2.side.x + m1.top.z * m2.side.y + m1.front.z * m2.side.z,
	}
	m.top = {
		x = m1.side.x * m2.top.x + m1.top.x * m2.top.y + m1.front.x * m2.top.z,
		y = m1.side.y * m2.top.x + m1.top.y * m2.top.y + m1.front.y * m2.top.z,
		z = m1.side.z * m2.top.x + m1.top.z * m2.top.y + m1.front.z * m2.top.z,
	}
	m.front = {
		x = m1.side.x * m2.front.x + m1.top.x * m2.front.y + m1.front.x * m2.front.z,
		y = m1.side.y * m2.front.x + m1.top.y * m2.front.y + m1.front.y * m2.front.z,
		z = m1.side.z * m2.front.x + m1.top.z * m2.front.y + m1.front.z * m2.front.z,
	}
	m.offset = {
		x = m1.side.x * m2.offset.x + m1.top.x * m2.offset.y + m1.front.x * m2.offset.z + m1.offset.x,
		y = m1.side.y * m2.offset.x + m1.top.y * m2.offset.y + m1.front.y * m2.offset.z + m1.offset.y,
		z = m1.side.z * m2.offset.x + m1.top.z * m2.offset.y + m1.front.z * m2.offset.z + m1.offset.z,
	}
	return m
end

--[[
========================
render.TransformPoint
========================
]]
function M.TransformPoint( m, p )
	local p_ = {
		x = m.side.x * p.x + m.top.x * p.y + m.front.x * p.z + m.offset.x,
		y = m.side.y * p.x + m.top.y * p.y + m.front.y * p.z + m.offset.y,
		z = m.side.z * p.x + m.top.z * p.y + m.front.z * p.z + m.offset.z,
	}
	return p_
end

--[[
========================
render.ReverseTransformPoint
========================
]]
function M.ReverseTransformPoint( m, p )
	local x, y, z = p.x - m.offset.x, p.y - m.offset.y, p.z - m.offset.z
	local p_ = {
		x =  x * m.side.x  + y * m.side.y  + z * m.side.z,
		y =  x * m.top.x   + y * m.top.y   + z * m.top.z,
		z =  x * m.front.x + y * m.front.y + z * m.front.z,
	}
	return p_
end

--[[
========================
render.DrawHorizon
========================
]]
function M.DrawHorizon()
	local distToHorizon = 10000
	local o = {
		x = camera.x + distToHorizon * math.sin( - camera.ry ),
		y = camera.y,
		z = camera.z + distToHorizon * math.cos(   camera.ry )
	}
	local o = M.CameraToScreenPoint( M.ReverseTransformPoint( camera.matrix, o ) )
	if o.y < camera.height then
		love.graphics.setColor( 211, 186, 133 )
		love.graphics.rectangle( "fill", 0, math.max( o.y, 0 ), camera.width, camera.height - o.y )
	end
end

--[[
========================
render.DrawLine
========================
]]
function M.DrawLine( a, b, color, width )
	a = M.ReverseTransformPoint( camera.matrix, a )
	b = M.ReverseTransformPoint( camera.matrix, b )
	local a, b = M.CameraToScreenSegment( a, b )
	if a then
		love.graphics.setLineWidth( width )
		love.graphics.setColor( color[1], color[2], color[3] )
		love.graphics.line( a.x, a.y, b.x, b.y )
	end
end

--[[
========================
render.DrawGrid
========================
]]
function M.DrawGrid()
	local gridSize, gridStep = 2000, 100
	local a, b = nil, nil
	local color = { 188, 150, 100 }
	for i = - gridSize, gridSize, gridStep do
		-- parallel
		a = { x = - gridSize, y = 0, z = i }
		b = { x =   gridSize, y = 0, z = i }
		M.DrawLine( a, b, color, 1 )
		-- meridian
		a = { x = i, y = 0, z = - gridSize }
		b = { x = i, y = 0, z =   gridSize }
		M.DrawLine( a, b, color, 1 )
	end
end

--[[
========================
render.DrawPolygon
========================
]]
function M.DrawPolygon( p, color )
	-- get vertices in world space
	local verticesWorld = {}
	for i, v in ipairs( p.vertices ) do
		table.insert( verticesWorld, M.TransformPoint( p.matrix, v ) )
	end
	-- get vertices in camera space
	local verticesCamera = {}
	for i, v in ipairs( verticesWorld ) do
		table.insert( verticesCamera, M.ReverseTransformPoint( camera.matrix, v ) )
	end
	-- get vertices in screen space
	local verticesScreen = {}
	for i, v in ipairs( verticesCamera ) do
		table.insert( verticesScreen, M.CameraToScreenPoint( v ) )
	end
	-- check if any vertices are clipped
	if #verticesScreen ~= #verticesCamera then return end
	-- get vertices list
	local vertices = {}
	for i, v in ipairs( verticesScreen ) do
		table.insert( vertices, v.x )
		table.insert( vertices, v.y )
	end
	-- draw polygon
	love.graphics.setColor( color.r, color.g, color.b )
	love.graphics.polygon( "fill", vertices )
end

return M