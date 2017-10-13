--[[
===========================================================================

Target

===========================================================================
]]

local M = {}

--[[
========================
target.New
========================
]]
function M.New( params )
	local o = { x = params.x, y = params.y, z = params.z, rx = params.rx, ry = params.ry, rz = params.rz }
	-- parameters
	o.vertices = {
		[1] = { x =   params.sizeX / 2, y =            0, z = 0 },
		[2] = { x =   params.sizeX / 2, y = params.sizeY, z = 0 },
		[3] = { x = - params.sizeX / 2, y = params.sizeY, z = 0 },
		[4] = { x = - params.sizeX / 2, y =            0, z = 0 },
	}
	o.edges = {
		{ 1, 2 },
		{ 1, 4 },
		{ 2, 3 },
		{ 3, 4 },
	}
	o.color = params.color
	o.parent = params.parent
	-- variables
	o.isDead = false
	setmetatable(o, { __index = M })
	render.UpdateMatrix( "yxz", o )
	return o
end

--[[
========================
target:Kill
========================
]]
function M:Kill()
	self.isDead = true
	self.color = { r = 64, g = 16, b = 16 }
	if self.parent then self.parent:Kill() end
end

return M
