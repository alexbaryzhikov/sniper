--[[
===========================================================================

Moving Target

===========================================================================
]]

local M = {}

--[[
========================
movingTarget.New
========================
]]
function M.New( params )
	local o = { x = params.x, y = params.y, z = params.z, rx = params.rx, ry = params.ry, rz = params.rz }
	-- parameters
	o.speed = params.speed
	o.waypoints = params.waypoints
	-- variables
	o.isMovingTarget = true
	o.targets = {}
	o.isDead = false
	o.isUpdating = false
	o.waypoint = o.waypoints[1]
	setmetatable(o, { __index = M })
	o.moveVector = M.GetMoveVector( o )
	render.UpdateMatrix( "yxz", o )
	return o
end

--[[
========================
movingTarget:Update
========================
]]
function M:Update( dt )
	if self.isUpdating or self.isDead then return end
	self.isUpdating = true
	self.x = self.x + self.speed * self.moveVector.x * dt
	self.y = self.y + self.speed * self.moveVector.y * dt
	self.z = self.z + self.speed * self.moveVector.z * dt
	render.UpdateMatrix( "yxz", self )
	self:UpdateChildMatrices()
	-- waypoint reached check
	if math.abs( self.x - self.waypoint.x ) < 0.1 and
	   math.abs( self.y - self.waypoint.y ) < 0.1 and
	   math.abs( self.z - self.waypoint.z ) < 0.1 then
		self.x = self.waypoint.x
		self.y = self.waypoint.y
		self.z = self.waypoint.z
		for i = 1, #self.waypoints do
			if self.waypoint == self.waypoints[i] then
				if i == #self.waypoints then
					self.waypoint = self.waypoints[1]
				else
					self.waypoint = self.waypoints[i + 1]
					break
				end
			end
		end
		self.moveVector = M.GetMoveVector( self )
	end
	self.isUpdating = false
end

--[[
========================
movingTarget:Kill
========================
]]
function M:Kill()
	self.isDead = true
end

--[[
========================
movingTarget:UpdateChildMatrices
========================
]]
function M:UpdateChildMatrices()
	for i, v in ipairs( self.targets ) do
		render.UpdateMatrix( "yxz", v )
		v.matrix = render.TransformMatrix( self.matrix, v.matrix )
	end
end

--[[
========================
movingTarget.GetMoveVector
========================
]]
function M.GetMoveVector( o )
	local dx, dy, dz = o.waypoint.x - o.x, o.waypoint.y - o.y, o.waypoint.z - o.z
	local d = math.sqrt( dx^2 + dy^2 + dz^2 )
	local v = nil
	if d ~= 0 then
		v = {
			x = dx / d,
			y = dy / d,
			z = dz / d,
		}
	else
		v = {
			x = 0,
			y = 0,
			z = 0,
		}
	end
	return v
end

return M
