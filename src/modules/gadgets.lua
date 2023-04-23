--[[
===========================================================================

Gadgets

===========================================================================
]]

local M = {}

M.sideView = { x = 1, y = 1, w = camera.width - 2, h = camera.height / 5, zoom = 2, offs = 0 }
M.topView = { x = 1, y = M.sideView.h + 25, w = camera.width - 2, h = camera.height / 5, zoom = 2, offs = 0 }
M.isDrawBulletStats = false
M.dpredict = 0
local canvasOverlay = love.graphics.newCanvas()

--[[
========================
gadgets.GetDistancePrediction

TODO: need the equation for bullet trajectory
========================
]]
function M.GetDistancePrediction()
	local t = - 2 * 880 * math.sin( world.shotAngle ) / config.GRAVITY
	local a = config.AIR_RESISTANCE_COEF
	M.dpredict =  ( 1 / a ) * math.log( 1 / ( 1 - a * 880 * math.cos( world.shotAngle ) * t ) )
end

--[[
========================
gadgets.DetectTargetCollision

Detects the segment collision with the targets
========================
]]
function M.DetectTargetCollision( a, b )
	for i, v in ipairs( world.targets ) do
		local at = render.ReverseTransformPoint( v.matrix, a )
		local bt = render.ReverseTransformPoint( v.matrix, b )
		if at.z > 0 and bt.z <= 0 then
			local ratio = at.z / ( at.z - bt.z )
			local poi = {
				x = at.x + ( bt.x - at.x ) * ratio,
				y = at.y + ( bt.y - at.y ) * ratio,
				z = 0
			}
			-- check if ray hits the target
			if poi.x > v.vertices[4].x and poi.x < v.vertices[1].x and
			   poi.y > v.vertices[1].y and poi.y < v.vertices[2].y then
				local c = render.TransformPoint( v.matrix, poi )
				return utils.GetHorizontalDistance( a, c )
			end
		end
	end
end

--[[
========================
gadgets.GetDistanceToTarget
========================
]]
function M.GetDistanceToTarget()
	-- get the ray of sight
	local a = {
		x = camera.x,
		y = camera.y,
		z = camera.z,
	}
	b = {
		x = 0,
		y = 0,
		z = 10000,
	}
	b = render.TransformPoint( camera.matrix, b )
	-- detect collision with targets
	local d = M.DetectTargetCollision( a, b )
	if d then
		d = tostring( utils.Round( d ) ) .. " m"
	else
		-- detect collision with ground
		if camera.rx < 0 then
			d = - camera.y / math.tan( camera.rx )
			if d > 10000 then d = "10000+ m"
			else d = tostring( utils.Round( d ) ) .. " m" end
		else
			d = "N/A"
		end
	end
	return d
end

--[[
========================
gadgets.DrawScope
========================
]]
function M.DrawScope()
	if camera.view == camera then
		love.graphics.setLineWidth( 1 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.line( camera.width / 2 - 10, camera.height / 2, camera.width / 2 + 10, camera.height / 2 )
		love.graphics.line( camera.width / 2, camera.height / 2 - 10, camera.width / 2, camera.height / 2 + 10 )
	else
		scope.current.reticle()
		scope.DrawScopeFrame()
	end
	-- zoom and distance info
	local infoX, infoY = camera.width - 200, 20
	local distance = M.GetDistanceToTarget()
	local zoom = utils.Round( math.tan( math.rad( 20 ) ) / math.tan( camera.view.fov / 2 ), 1 )
	local strings = {
		{ "SCOPE", 		scope.types[scope.type], 	140 },
		{ "ZEROING", 	scope.current.zeroing,		140 },
		{ "ZOOM", 		"x " .. zoom, 				140 },
		{ "TARGET",		distance, 					110 },
	}
	love.graphics.setColor( 32, 32, 32, 128 )
	for i = 1, #strings do love.graphics.rectangle( "fill", infoX - 5, infoY - 5 + ( i - 1 ) * 25, 185, 23 ) end
	love.graphics.setColor( 255, 255, 255 )
	for i = 1, #strings do
		love.graphics.print( strings[i][1], 	infoX, 					infoY + ( i - 1 ) * 25 )
		love.graphics.print( strings[i][2],		infoX + strings[i][3],	infoY + ( i - 1 ) * 25 )
	end
end

--[[
========================
gadgets.DrawBulletTrajectories
========================
]]
function M.DrawBulletTrajectories()
	for i = 1, #world.bullets do
		-- trajectory
		if camera.view ~= camera then
				local DrawStencil = function()
					love.graphics.circle( "fill", camera.width / 2, camera.height / 2, camera.width / 4, 128 )
				end
				love.graphics.stencil( DrawStencil, "replace", 1 )
				love.graphics.setStencilTest("equal", 0)
		end
		for j = 2, #world.bullets[i].points do
			local color = { world.bullets[i].points[j].c.r, world.bullets[i].points[j].c.g, world.bullets[i].points[j].c.b }
			local a = world.bullets[i].points[j-1]
			local b = world.bullets[i].points[j]
			render.DrawLine( a, b, color, 1 )
		end
		local color = { world.bullets[i].color.r, world.bullets[i].color.g, world.bullets[i].color.b }
		local a = world.bullets[i].points[#world.bullets[i].points]
		local b = world.bullets[i]
		render.DrawLine( a, b, color, 1 )
		if camera.view ~= camer then love.graphics.setStencilTest() end
		-- bullet and stats
		bScreen = render.CameraToScreenPoint( render.ReverseTransformPoint ( camera.matrix, b ) )
		if bScreen then
			-- bullet
			love.graphics.setColor( world.bullets[i].color.r, world.bullets[i].color.g, world.bullets[i].color.b )
			love.graphics.circle( "fill", bScreen.x, bScreen.y, 2, 16 )
			-- stats
			if M.isDrawBulletStats then
				love.graphics.setColor( 32, 32, 32, 128 )
				love.graphics.rectangle(
					"fill",
					bScreen.x + 3, bScreen.y - 47,
					55, 47
				)
				love.graphics.setColor( 200, 200, 200 )
				love.graphics.print(
					utils.Round( world.bullets[i].v ) .. " m/s",
					utils.Round( bScreen.x ) + 5, utils.Round( bScreen.y ) - 45
				)
				love.graphics.print(
					utils.Round( world.bullets[i].dt, 2 ) .. " s",
					utils.Round( bScreen.x ) + 5, utils.Round( bScreen.y ) - 30
				)
				local d = utils.GetHorizontalDistance( world.bullets[i].points[1], world.bullets[i] )
				love.graphics.print(
					utils.Round( d ) .. " m",
					utils.Round( bScreen.x ) + 5, utils.Round( bScreen.y ) - 15
				)
			end
		end
	end
end

--[[
========================
gadgets.DrawView

Draws orthogonal views with trajectories and stats
========================
]]
function M.DrawView( type, params )
	-- parameters
	local origin, GetX, GetY = nil, nil, nil
	if type == "side" then
		origin = { x = params.x, y = params.y + params.h }
		GetX = function( obj ) return origin.x + obj.z * params.zoom  + params.offs end
		GetY = function( obj ) return origin.y - obj.y * params.zoom end
	elseif type == "top" then
		origin = { x = params.x, y = params.y + params.h / 2 }
		GetX = function( obj ) return origin.x + obj.z * params.zoom  + params.offs end
		GetY = function( obj ) return origin.y + obj.x * params.zoom end
	end
	-- set up canvas
	local DrawStencil = function()
		love.graphics.rectangle( "fill", params.x, params.y, params.w, params.h )
	end
	love.graphics.setCanvas( canvasOverlay )
	love.graphics.clear()
	love.graphics.stencil( DrawStencil, "replace", 1 )
	love.graphics.setStencilTest("greater", 0)
	love.graphics.setColor( 0, 0, 0, 32 )
	DrawStencil()
	-- frame
	love.graphics.setLineWidth( 1 )
	love.graphics.setColor( 32, 32, 32 )
	love.graphics.rectangle( "line", params.x, params.y, params.w, params.h )
	love.graphics.print( type .. " view", params.x + 3, params.y + 3 )
	if type == "side" then
		love.graphics.print( "camera angle = " .. utils.Round( math.deg( camera.rx ), 2 ), params.x + 3, params.y + 18 )
	elseif type == "top" then
		love.graphics.print( "camera angle = " .. utils.Round( math.deg( camera.ry ), 2 ), params.x + 3, params.y + 18 )
	end
	-- camera
	love.graphics.setColor( 200, 0, 0 )
	love.graphics.circle( "fill", GetX( camera ), GetY( camera ), 3, 16 )
	-- line of sight
	love.graphics.setColor( 32, 32, 32 )
	if type == "side" then
		love.graphics.line(
			GetX( camera ), GetY( camera ),
			GetX( camera ) + 100 * camera.matrix.front.z, GetY( camera ) - 100 * camera.matrix.front.y
		)
	elseif type == "top" then
		love.graphics.line(
			GetX( camera ), GetY( camera ),
			GetX( camera ) + 100 * camera.matrix.front.z, GetY( camera ) + 100 * camera.matrix.front.x
		)
	end
	-- trajectories
	for i = 1, #world.bullets do
		-- trajectory
		for j = 2, #world.bullets[i].points do
			love.graphics.setColor( world.bullets[i].points[j].c.r, world.bullets[i].points[j].c.g, world.bullets[i].points[j].c.b )
			love.graphics.line(
				GetX( world.bullets[i].points[j-1] ), GetY( world.bullets[i].points[j-1] ),
				GetX( world.bullets[i].points[j] ), GetY( world.bullets[i].points[j] )
			)
		end
		love.graphics.setColor( world.bullets[i].color.r, world.bullets[i].color.g, world.bullets[i].color.b )
		love.graphics.line(
			GetX( world.bullets[i].points[#world.bullets[i].points] ), GetY( world.bullets[i].points[#world.bullets[i].points] ),
			GetX( world.bullets[i] ), GetY( world.bullets[i] )
		)
		-- bullet
		love.graphics.setColor( world.bullets[i].color.r, world.bullets[i].color.g, world.bullets[i].color.b )
		love.graphics.circle( "fill", GetX( world.bullets[i] ), GetY( world.bullets[i] ), 2, 16 )
		-- stats
		love.graphics.setColor( 32, 32, 32 )
		love.graphics.rectangle(
			"fill",
			GetX( world.bullets[i] ) + 3, GetY( world.bullets[i] ) - 47,
			55, 47
		)
		love.graphics.setColor( 200, 200, 200 )
		love.graphics.print(
			utils.Round( world.bullets[i].v ) .. " m/s",
			utils.Round( GetX( world.bullets[i] ) ) + 5, utils.Round( GetY( world.bullets[i] ) ) - 45
		)
		love.graphics.print(
			utils.Round( world.bullets[i].dt, 2 ) .. " s",
			utils.Round( GetX( world.bullets[i] ) ) + 5, utils.Round( GetY( world.bullets[i] ) ) - 30
		)
		local d = utils.GetHorizontalDistance( world.bullets[i].points[1], world.bullets[i] )
		love.graphics.print(
			utils.Round( d ) .. " m",
			utils.Round( GetX( world.bullets[i] ) ) + 5, utils.Round( GetY( world.bullets[i] ) ) - 15
		)
	end
	love.graphics.setStencilTest()
	-- distance scale
	love.graphics.setColor( 32, 32, 32 )
	for i = utils.Round( - params.offs / params.zoom, -2 ), ( params.w - params.offs ) / params.zoom, 100 do
		love.graphics.line(
			params.x + i * params.zoom + params.offs, params.y + params.h,
			params.x + i * params.zoom + params.offs, params.y + params.h + 5
		)
		love.graphics.print( i, params.x + i * params.zoom + 2 + params.offs, params.y + params.h + 2 )
	end
	-- draw canvas
	love.graphics.setCanvas()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw( canvasOverlay )
end

--[[
========================
gadgets.DrawHint
========================
]]
function M.DrawHint()
	local y = 0
	if world.isDrawOverlays then y = M.sideView.h + M.topView.h + 35 end
	local strings = {
		{ "------------------------------", 16 },
		{ "Game Controls", 16 },
		{ "------------------------------", 16 },
		{ "w s a d : movement", 53 },
		{ "q e : elevation", 77 },
		{ "Shift : move super fast", 69 },
		{ "Mouse 1 : shoot", 44 },
		{ "Mouse 2 : look through scope", 44 },
		{ "[ ] : change scope", 83 },
		{ "Mouse wheel : scope zoom", 16 },
		{ "PgUp PgDown : adjust scope zeroing", 10 },
		{ "Space : hold breath", 58 },
		{ "Tab : show/hide bullet metrics", 75 },
		{ "z : show/hide orthogonal views", 92 },
		{ "c : walk/free camera", 90 },
		{ "r : reset camera", 92 },
		{ "t : reset targets and trajectories", 92 },
	}
	if camera.view == camera then love.graphics.setColor( 32, 32, 32 )
	else love.graphics.setColor( 200, 200, 200 ) end
	for i, v in ipairs(strings) do
		love.graphics.print( v[1], v[2], y + 15 * i )
	end
end

--[[
========================
gadgets.DrawCameraAndWeapon

Draws close-up of camera and weapon vectors
========================
]]
function M.DrawCameraAndWeapon()
	-- ----------
	-- side view
	-- ----------
	camX, camY = 100, 1000
	wepX, wepY = camX + ( weapon.matrix.offset.z - camera.z ) * 500, camY - ( weapon.matrix.offset.y - camera.y ) * 500
	local SideViewDrawNormal = function ( object, normal, size )
		local x, y = nil, nil
		if 		object == camera then x, y = camX, camY
		elseif 	object == weapon then x, y = wepX, wepY end
		local dark =	{ side = { 128, 0, 0 }, top = { 0, 128, 0 }, front = { 0, 0, 128 } }
		local bright =	{ side = { 255, 0, 0 }, top = { 0, 255, 0 }, front = { 0, 0, 255 } }
		if object.matrix[normal].x < 0 then
			love.graphics.setColor( dark[normal][1], dark[normal][2], dark[normal][3] )
		else
			love.graphics.setColor( bright[normal][1], bright[normal][2], bright[normal][3] )
		end
		love.graphics.setLineWidth( 1 )
		love.graphics.line( x, y, x + size * object.matrix[normal].z, y - size * object.matrix[normal].y )
	end
	-- weapon
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.circle( "fill", wepX, wepY, 3, 16 )
	SideViewDrawNormal( weapon, "front", 100 )
	-- camera
	love.graphics.setColor( 200, 200, 200 )
	love.graphics.circle( "fill", camX, camY, 3, 16 )
	SideViewDrawNormal( camera, "side", 40 )
	SideViewDrawNormal( camera, "top", 40 )
	SideViewDrawNormal( camera, "front", 100 )
	-- ----------
	-- top view
	-- ----------
	camX, camY = camX, camY + 200
	wepX, wepY = camX + ( weapon.matrix.offset.x - camera.x ) * 500, camY - ( weapon.matrix.offset.z - camera.z ) * 500
	local TopViewDrawNormal = function ( object, normal, size )
		local x, y = nil, nil
		if 		object == camera then x, y = camX, camY
		elseif 	object == weapon then x, y = wepX, wepY end
		local dark =	{ side = { 128, 0, 0 }, top = { 0, 128, 0 }, front = { 0, 0, 128 } }
		local bright =	{ side = { 255, 0, 0 }, top = { 0, 255, 0 }, front = { 0, 0, 255 } }
		if object.matrix[normal].y < 0 then
			love.graphics.setColor( dark[normal][1], dark[normal][2], dark[normal][3] )
		else
			love.graphics.setColor( bright[normal][1], bright[normal][2], bright[normal][3] )
		end
		love.graphics.setLineWidth( 1 )
		love.graphics.line( x, y, x + size * object.matrix[normal].x, y - size * object.matrix[normal].z )
	end
	-- weapon
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.circle( "fill", wepX, wepY, 3, 16 )
	TopViewDrawNormal( weapon, "front", 100 )
	-- camera
	love.graphics.setColor( 200, 200, 200 )
	love.graphics.circle( "fill", camX, camY, 3, 16 )
	TopViewDrawNormal( camera, "side", 40 )
	TopViewDrawNormal( camera, "front", 100 )
	TopViewDrawNormal( camera, "top", 40 )
end

--[[
========================
gadgets.RotateCube
========================
]]
function M.RotateCube( dt, c )
	c.rx = c.rx + dt
	c.ry = c.ry + dt
	render.UpdateMatrix( "yxz", c )
end

--[[
========================
gadgets.DrawCube
========================
]]
function M.DrawCube( c )
	local color = { 0, 255, 64 }
	for i, v in ipairs(c.edges) do
		local a = render.TransformPoint( c.matrix, c.vertices[v[1]] )
		local b = render.TransformPoint( c.matrix, c.vertices[v[2]] )
		render.DrawLine( a, b, color, 1 )
	end
end

--[[
========================
gadgets.DrawTarget
========================
]]
function M.DrawTarget( target )
	if render.ReverseTransformPoint( target.matrix, camera ).z > 0 then
		render.DrawPolygon( target, target.color )
	else
		local color = { 0, 255, 64 }
		for i, v in ipairs(target.edges) do
			local a = render.TransformPoint( target.matrix, target.vertices[v[1]] )
			local b = render.TransformPoint( target.matrix, target.vertices[v[2]] )
			render.DrawLine( a, b, color, 1 )
		end
	end
end

--[[
========================
gadgets.DrawTargets
========================
]]
function M.DrawTargets()
	for i = #world.targets, 1, -1  do
		M.DrawTarget( world.targets[i] )
	end
end

return M