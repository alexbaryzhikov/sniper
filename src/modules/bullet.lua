--[[
===========================================================================

Bullet

===========================================================================
]]

local M = {}

--[[
========================
bullet.New
========================
]]
function M.New( params )
	local o = {}
	-- parameters
	o.x = params.matrix.offset.x
	o.y = params.matrix.offset.y
	o.z = params.matrix.offset.z
	o.v = config.BULLET_INITIAL_SPEED
	o.vx = o.v * params.matrix.front.x
	o.vy = o.v * params.matrix.front.y
	o.vz = o.v * params.matrix.front.z
	-- variables
	o.color = { r = 255, g = 0, b = 0 }
	o.points = {}
	local p = { x = o.x, y = o.y, z = o.z, c = { r = o.color.r, g = o.color.g, b = o.color.b } }
	table.insert( o.points, p )
	o.dt = 0
	o.trajectoryTimer = timer.New( {
		name = 				"trajectoryTimer",
		callbackModule = 	o,
		basePeriod = 		0.05,
		randomness = 		0,
		isRepeating = 		true,
		isReturnSelf = 		true,		
	} )
	o.isDead = false
	setmetatable(o, { __index = M })
	return o
end

--[[
========================
bullet:Update

Immediately returns if the bullet is dead
========================
]]
function M:Update( dt )
	if self.isDead then return end
	-- air resistance
	local arx = self.vx * self.v * config.AIR_RESISTANCE_COEF
	local ary = self.vy * self.v * config.AIR_RESISTANCE_COEF
	local arz = self.vz * self.v * config.AIR_RESISTANCE_COEF
	-- speed change
	self.vx = self.vx + arx * dt
	self.vy = self.vy + ( ary + config.GRAVITY ) * dt 
	self.vz = self.vz + arz * dt
	-- position change
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
	self.z = self.z + self.vz * dt
	-- velocity
	self.v = math.sqrt( self.vx^2 + self.vy^2 + self.vz^2 )
	-- color change
	local initSpeed = config.BULLET_INITIAL_SPEED
	local velocityRatio = math.min( math.max( self.v - initSpeed / 2, 0 ), initSpeed / 2 ) / ( initSpeed / 2 )
	self.color.r = velocityRatio * 255
	self.color.b = 255 - self.color.r
	-- ground collision
	if self.y <= 0 then
		self:DetectTargetCollision()
		self:Kill()
	else
		self.dt = self.dt + dt
	end
end

--[[
========================
bullet:OnTimerTick
========================
]]
function M:OnTimerTick( event )
	-- add trajectory point
	if event.timer == self.trajectoryTimer then
		self:DetectTargetCollision()
		if not self.isDead then
			local p = { x = self.x, y = self.y, z = self.z, c = { r = self.color.r, g = self.color.g, b = self.color.b } }
			table.insert( self.points, p )
		end
	end
end

--[[
========================
bullet:DetectTargetCollision
========================
]]
function M:DetectTargetCollision()
	local p = { x = self.x, y = self.y, z = self.z }
	local k = self.points[#self.points]
	for i, v in ipairs( world.targets ) do
		local kt = render.ReverseTransformPoint( v.matrix, k )
		local pt = render.ReverseTransformPoint( v.matrix, p )
		if kt.z > 0 and pt.z <= 0 then
			local d = kt.z / ( kt.z - pt.z )
			local poi = {
				x = kt.x + ( pt.x - kt.x ) * d,
				y = kt.y + ( pt.y - kt.y ) * d,
			}
			-- check if bullet hit the target
			if poi.x > v.vertices[4].x and poi.x < v.vertices[1].x and
			   poi.y > v.vertices[1].y and poi.y < v.vertices[2].y then
				self:Kill()
				v:Kill()
				self.x = k.x + ( p.x - k.x ) * d
				self.y = k.y + ( p.y - k.y ) * d
				self.z = k.z + ( p.z - k.z ) * d
			end
		end
	end
end

--[[
========================
bullet:Kill
========================
]]
function M:Kill()
	self.isDead = true
	timekeeper.RemoveTimer( self.trajectoryTimer )
	self.trajectoryTimer = nil
end

return M
