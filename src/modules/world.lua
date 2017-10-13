--[[
===========================================================================

World

World axes in relation to default player position:
	x = right ( up/down head rotation )
	y = top ( left/right head rotation )
	z = forward ( the shooting direction )
Units: meters

===========================================================================
]]

local M = {}

M.bullets = {}
M.targets = {}
M.movingTargets = {}
M.isDrawOverlays = false
M.zSortTimer = 0
M.wander = {
	x = {
		sign = ( math.random( 2 ) - 1.5 ) * 2,
		angle2 = 0,
	},
	y = {
		sign = ( math.random( 2 ) - 1.5 ) * 2,
		angle2 = 0,
	}
}
M.recoil = {
	da = 1.5 * math.pi / config.RECOIL_DURATION,
	amplitude = nil,
}
M.respiration = {
	da = 3.5 * math.pi / config.RESPIRATORY_TIME,
	amplitude = nil,
}
M.holdBreath = {
	isActive = false,
	timer = nil,
	timerRespiratory = nil,
	releaseTime = nil,
	xBuffer = 0,
	yBuffer = 0,
	dx = 0,
	dy = 0,
}
local isUpdating = false

--[[
========================
world.Init
========================
]]
function M.Init()
	render.UpdateMatrix( "yxz", camera )
	camera.UpdateMovementMatrix()
	weapon.UpdateWeaponParenting()
	targetsFactory.CreateTargets()
	M.theCube = cube.New( { x = 0, y = 1, z = 10, rx = 0, ry = 0, rz = 0, size = 1 } )
	M.StartWander( "x" )
	M.StartWander( "y" )
end

--[[
========================
world.update
========================
]]
function M.update( dt )
	if isUpdating then return end
	isUpdating = true
	-- wander
	if M.wander.x.timer then M.AnimateWander( dt ) end
	-- respiration
	if M.holdBreath.timerRespiratory then M.AnimateRespiration( dt ) end
	-- recoil
	if M.recoil.timer then M.AnimateRecoil( dt ) end
	-- update player input
	M.UpdatePlayerInput( dt )
	-- sort targets
	M.zSortTimer = M.zSortTimer + dt
	if M.zSortTimer > 0.05 then
		M.zSortTimer = 0
		M.TargetsZSort()
	end
	gadgets.RotateCube( dt, M.theCube )
	-- update bullets
	for i = 1, #M.bullets do
		M.bullets[i]:Update( dt )
	end
	for i = 1, #M.movingTargets do
		M.movingTargets[i]:Update( dt )
	end
	isUpdating = false
end

--[[
========================
world.draw
========================
]]
function M.draw()
	render.DrawHorizon()
	render.DrawGrid()
	gadgets.DrawTargets()
	gadgets.DrawBulletTrajectories()
	gadgets.DrawCube( M.theCube )
	gadgets.DrawScope()
	if camera.view == camera then
		if M.isDrawOverlays then
			gadgets.DrawView( "side", gadgets.sideView )
			gadgets.DrawView( "top", gadgets.topView )
			gadgets.DrawCameraAndWeapon()
		end
		gadgets.DrawHint()
	end
end

--[[
====================================================================

	Player Input

====================================================================
]]

--[[
========================
world.UpdatePlayerInput
========================
]]
function M.UpdatePlayerInput( dt )
	-- views controls
	if love.keyboard.isDown("up") and gadgets.sideView.zoom < 10 then
		local oldPos = - gadgets.sideView.offs / gadgets.sideView.zoom
		gadgets.sideView.zoom = gadgets.sideView.zoom + dt * gadgets.sideView.zoom
		gadgets.topView.zoom = gadgets.topView.zoom + dt * gadgets.topView.zoom
		local newPos = - gadgets.sideView.offs / gadgets.sideView.zoom
		local d = ( newPos - oldPos ) * gadgets.sideView.zoom
		gadgets.sideView.offs = gadgets.sideView.offs + d
		gadgets.topView.offs = gadgets.topView.offs + d
	end
	if love.keyboard.isDown("down") and gadgets.sideView.zoom > 1 then
		local oldPos = - gadgets.sideView.offs / gadgets.sideView.zoom
		gadgets.sideView.zoom = gadgets.sideView.zoom - dt * gadgets.sideView.zoom
		gadgets.topView.zoom = gadgets.topView.zoom - dt * gadgets.topView.zoom
		local newPos = - gadgets.sideView.offs / gadgets.sideView.zoom
		local d = ( newPos - oldPos ) * gadgets.sideView.zoom
		gadgets.sideView.offs = gadgets.sideView.offs + d
		gadgets.topView.offs = gadgets.topView.offs + d
	end
	if love.keyboard.isDown("right") then
		gadgets.sideView.offs = gadgets.sideView.offs - dt * 1000
		gadgets.topView.offs = gadgets.topView.offs - dt * 1000
	end
	if love.keyboard.isDown("left") then
		gadgets.sideView.offs = gadgets.sideView.offs + dt * 1000
		gadgets.topView.offs = gadgets.topView.offs + dt * 1000
	end
	-- camera controls
	local MoveCamera = function( coef, dir )
		camera.x = camera.x + coef * dt * config.MOVE_SPEED * camera.moveMatrix[dir].x
		camera.y = camera.y + coef * dt * config.MOVE_SPEED * camera.moveMatrix[dir].y
		camera.z = camera.z + coef * dt * config.MOVE_SPEED * camera.moveMatrix[dir].z
		render.UpdateMatrix( "yxz", camera )
		camera.UpdateMovementMatrix()
		weapon.UpdateWeaponParenting()
	end
	local speed = 1
	if love.keyboard.isDown("lshift") then speed = 20 end
	if love.keyboard.isDown("w") then MoveCamera(   speed, "front" ) end
	if love.keyboard.isDown("s") then MoveCamera( - speed, "front" ) end
	if love.keyboard.isDown("a") then MoveCamera( - speed, "side"  ) end
	if love.keyboard.isDown("d") then MoveCamera(   speed, "side"  ) end
	if love.keyboard.isDown("q") then MoveCamera(   speed, "top"   ) end
	if love.keyboard.isDown("e") then MoveCamera( - speed, "top"   ) end
end

--[[
========================
world.keypressed
========================
]]
function M.keypressed( key, scancode, isrepeat )
	local ClearBullets = function()
		local o = {}
		for i, v in ipairs( M.bullets ) do
			if not v.isDead then table.insert ( o, v ) end
		end
		M.bullets = o
	end
	if key == "escape" then love.event.quit() end
	if key == "home" then
		gadgets.sideView.offs = 0
		gadgets.topView.offs = 0
	end
	if key == "delete" then ClearBullets() end
	if key == "`" then M.isDrawOverlays = not M.isDrawOverlays end
	if key == "tab" then gadgets.isDrawBulletStats = not gadgets.isDrawBulletStats end
	if key == "r" then camera.Reset() end
	if key == "t" then
		ClearBullets()
		M.targets = {}
		targetsFactory.CreateTargets()
	end
	if key == "c" then
		if camera.moveType == "free" then camera.moveType = "constr"
		else camera.moveType = "free" end
	end
	if key == "]" then
		scope.type = scope.type + 1
		if scope.type > #scope.types then scope.type = 1 end
		scope.current = scope[scope.types[scope.type]]
		if camera.view ~= camera then camera.view = scope.current end
	end
	if key == "[" then
		scope.type = scope.type - 1
		if scope.type < 1 then scope.type = #scope.types end
		scope.current = scope[scope.types[scope.type]]
		if camera.view ~= camera then camera.view = scope.current end
	end
	if key == "pageup" then
		if scope.current.zeroing + 100 <= scope.current.zeroingData[#scope.current.zeroingData][1] then
			scope.current.zeroing = scope.current.zeroing + 100
			weapon.UpdateWeaponParenting()
		end
	end
	if key == "pagedown" then
		if scope.current.zeroing - 100 >= scope.current.zeroingData[1][1] then
			scope.current.zeroing = scope.current.zeroing - 100
			weapon.UpdateWeaponParenting()
		end
	end
	if key == "space" then
		if not M.holdBreath.timerRespiratory then
			M.holdBreath.isActive = true
			if M.holdBreath.timer then
				if M.holdBreath.releaseTime then
					if os.clock() - M.holdBreath.releaseTime > config.RESPIRATORY_TIME / 2 then
						M.holdBreath.timer:Reset()
					end
				end
				M.holdBreath.timer:Unpause()
			else
				M.holdBreath.timer = timer.New( {
					name = 				"holdBreathTimer",
					callbackModule = 	M,
					basePeriod = 		config.HOLD_BREATH_TIME,
					randomness = 		0,
					isRepeating = 		false,
					isReturnSelf = 		false,		
				} )
			end
		end
	end
end

--[[
========================
world.keyreleased
========================
]]
function M.keyreleased( key, scancode )
	if key == "space" then
		if not M.holdBreath.timerRespiratory then
			M.ReleaseBreath()
			if M.holdBreath.timer then M.holdBreath.timer:Pause() end
		end
	end
end

--[[
========================
world.mousepressed
========================
]]
function M.mousepressed( x, y, button, istouch )
	if button == 1 then M.FireBullet() end
	if button == 2 then 
		if camera.view == camera then camera.view = scope.current
		else camera.view = camera end
	end
end

function M.mousereleased( x, y, button, istouch )
end

--[[
========================
world.mousemoved
========================
]]
function M.mousemoved( x, y, dx, dy )
	-- rotate camera
	camera.rx = camera.rx - math.rad( dy ) * math.tan( camera.view.fov / 2 ) * config.SENSITIVITY * 0.01
	camera.ry = camera.ry - math.rad( dx ) * math.tan( camera.view.fov / 2 ) * config.SENSITIVITY * 0.01
	if camera.rx < camera.rxMin then camera.rx = camera.rxMin end
	if camera.rx > camera.rxMax then camera.rx = camera.rxMax end
	render.UpdateMatrix( "yxz", camera )
	camera.UpdateMovementMatrix()
	weapon.UpdateWeaponParenting()
end

--[[
========================
world.wheelmoved
========================
]]
function M.wheelmoved( x, y )
	if y > 0 then camera.view.fov = camera.view.fovMin
	elseif y < 0 then camera.view.fov = camera.view.fovMax end
end

-- =================================================================

--[[
========================
world.FireBullet
========================
]]
function M.FireBullet()
	-- play sound effect
	local sndShot = love.audio.newSource( sndDataShot )
	sndShot:setVolume(0.5)
	sndShot:play()
	-- create bullet
	local o = M.GetSpread()
	local b = bullet.New( o )
	table.insert( M.bullets, b )
	-- check bullet limit
	if #M.bullets > 10 then table.remove( M.bullets, 1 ) end
	M.StartRecoil()
end

--[[
========================
world.TargetsZSort

Sorts targets relative to camera
========================
]]
function M.TargetsZSort()
	local zList, zList2, targetsSorted = {}, {}, {}
	-- get two copies of a list of camera-relative z coordinates of the targets
	for i, v in ipairs( M.targets ) do
		local t = render.ReverseTransformPoint( camera.matrix, v.matrix.offset )
		table.insert( zList, t.z )
		table.insert( zList2, t.z )
	end
	-- sort the first list
	table.sort( zList )
	-- create a new table of the targets based on the sorted list
	for i = 1, #zList do
		for j, v in ipairs( zList2 ) do
			if v == zList[i] then
				table.insert( targetsSorted, M.targets[j] )
				table.remove( M.targets, j )
				table.remove( zList2, j )
				break
			end
		end
	end
	M.targets = targetsSorted
end

--[[
========================
world.GetSpread
========================
]]
function M.GetSpread()
	math.randomseed(math.floor(os.clock() * 100000))
	local o = {}
	o.x = weapon.x
	o.y = weapon.y
	o.z = weapon.z
	o.rx = weapon.rx + config.SPREAD_ANGLE * ( math.random() * 2 - 1 )
	o.ry = weapon.ry + config.SPREAD_ANGLE * ( math.random() * 2 - 1 )
	o.rz = weapon.rz
	render.UpdateMatrix( "yxz", o )
	o.matrix = render.TransformMatrix( camera.matrix, o.matrix )
	return o
end

--[[
========================
world.StartRecoil
========================
]]
function M.StartRecoil()
	math.randomseed(math.floor(os.clock() * 100000))
	M.recoil.dx = config.RECOIL_ANGLE * ( math.random() * 2 - 0.2) / config.RECOIL_DURATION
	M.recoil.dy = config.RECOIL_ANGLE * ( math.random() * 2 - 1 ) / config.RECOIL_DURATION
	M.recoil.a = math.pi / 2
	M.recoil.amplitude = 1
	M.recoil.timer = timer.New( {
		name = 				"recoilTimer",
		callbackModule = 	M,
		basePeriod = 		config.RECOIL_DURATION,
		randomness = 		0,
		isRepeating = 		false,
		isReturnSelf = 		false,		
	} )
end

--[[
========================
world.AnimateRecoil
========================
]]
function M.AnimateRecoil( dt )
	M.recoil.a = M.recoil.a + M.recoil.da * dt
	if M.recoil.a >= math.pi then M.recoil.amplitude = 0.5 end
	camera.rx = camera.rx + ( M.recoil.dx + M.recoil.amplitude * math.sin( M.recoil.a ) ) * dt
	camera.ry = camera.ry + M.recoil.dy * dt
	render.UpdateMatrix( "yxz", camera )
	camera.UpdateMovementMatrix()
	weapon.UpdateWeaponParenting()
end

--[[
========================
world.StartWander
========================
]]
function M.StartWander( o )
	-- switch the angle sign
	M.wander[o].sign = - M.wander[o].sign
	-- get angle
	M.wander[o].angle1 = M.wander[o].angle2
	M.wander[o].angle2 = config.WANDER_ANGLE_MIN + ( config.WANDER_ANGLE_MAX - config.WANDER_ANGLE_MIN ) * math.random()
	-- get time
	M.wander[o].t = config.WANDER_TIME_MIN + ( config.WANDER_TIME_MAX - config.WANDER_TIME_MIN ) * math.random()
	M.wander[o].d = ( M.wander[o].angle1 + M.wander[o].angle2 ) * M.wander[o].sign / M.wander[o].t
	M.wander[o].a = 0
	M.wander[o].da = math.pi / M.wander[o].t
	M.wander[o].timer = timer.New( {
		name = 				"wanderTimer",
		callbackModule = 	M,
		basePeriod = 		M.wander[o].t,
		randomness = 		0,
		isRepeating = 		false,
		isReturnSelf = 		false,		
	} )
end

--[[
========================
world.AnimateWander
========================
]]
function M.AnimateWander( dt )
	local dx = M.wander.x.d * dt * math.sin( M.wander.x.a ) * math.pi / 2
	local dy = M.wander.y.d * dt * math.cos( M.wander.y.a ) * math.pi / 2
	if M.holdBreath.isActive then
		dx = dx / 2
		dy = dy / 2
		M.holdBreath.xBuffer = M.holdBreath.xBuffer + dx
		M.holdBreath.yBuffer = M.holdBreath.yBuffer + dy
	elseif M.holdBreath.releaseTime then
		if os.clock() - M.holdBreath.releaseTime < config.HOLD_BREATH_RELEASE_TIME then
			dx = dx + M.holdBreath.dx * dt
			dy = dy + M.holdBreath.dy * dt
			M.holdBreath.xBuffer = M.holdBreath.xBuffer - M.holdBreath.dx * dt
			M.holdBreath.yBuffer = M.holdBreath.yBuffer - M.holdBreath.dy * dt
		end
	end
	camera.rx = camera.rx + dx
	camera.ry = camera.ry + dy
	render.UpdateMatrix( "yxz", camera )
	camera.UpdateMovementMatrix()
	weapon.UpdateWeaponParenting()
	M.wander.x.a = M.wander.x.a + M.wander.x.da * dt
	M.wander.y.a = M.wander.y.a + M.wander.y.da * dt
end

--[[
========================
world.StartRespiration
========================
]]
function M.StartRespiration()
	-- play sound effect
	local n = math.random(3)
	local sndBreath = love.audio.newSource( sndDataBreath[n] )
	sndBreath:setVolume(0.5)
	sndBreath:play()
	M.respiration.a = math.pi / 2
	M.respiration.amplitude = 0.02
end

--[[
========================
world.AnimateRespiration
========================
]]
function M.AnimateRespiration( dt )
	M.respiration.a = M.respiration.a + M.respiration.da * dt
	if M.respiration.a >= 3 * math.pi then M.respiration.amplitude = 0.01 end
	camera.rx = camera.rx + M.respiration.amplitude * math.sin( M.respiration.a ) * dt
	render.UpdateMatrix( "yxz", camera )
	camera.UpdateMovementMatrix()
	weapon.UpdateWeaponParenting()
end

--[[
========================
world.OnTimerFinish
========================
]]
function M.OnTimerFinish( event )
	if event.timer == M.recoil.timer then M.recoil.timer = nil end
	if event.timer == M.wander.x.timer then M.StartWander( "x" ) end
	if event.timer == M.wander.y.timer then M.StartWander( "y" ) end
	if event.timer == M.holdBreath.timer then
		M.holdBreath.timer = nil
		M.ReleaseBreath()
		M.StartRespiration()
		M.holdBreath.timerRespiratory = timer.New( {
			name = 				"holdBreathTimerRespiratory",
			callbackModule = 	M,
			basePeriod = 		config.RESPIRATORY_TIME,
			randomness = 		0,
			isRepeating = 		false,
			isReturnSelf = 		false,		
		} )
	end
	if event.timer == M.holdBreath.timerRespiratory then M.holdBreath.timerRespiratory = nil end
end

--[[
========================
world.ReleaseBreath
========================
]]
function M.ReleaseBreath()
	M.holdBreath.isActive = false
	M.holdBreath.releaseTime = os.clock()
	M.holdBreath.dx = M.holdBreath.xBuffer / config.HOLD_BREATH_RELEASE_TIME
	M.holdBreath.dy = M.holdBreath.yBuffer / config.HOLD_BREATH_RELEASE_TIME
end

return M
