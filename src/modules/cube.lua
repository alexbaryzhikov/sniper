--[[
===========================================================================

Cube

===========================================================================
]]

local M = {}

--[[
========================
cube.New
========================
]]
function M.New( params )
	local o = { x = params.x, y = params.y, z = params.z, rx = params.rx, ry = params.ry, rz = params.rz }
	local size = params.size
	o.vertices = {
		[1] = { x =   size, y =   size, z =   size },
		[2] = { x = - size, y =   size, z =   size },
		[3] = { x =   size, y = - size, z =   size },
		[4] = { x =   size, y =   size, z = - size },
		[5] = { x = - size, y = - size, z =   size },
		[6] = { x = - size, y =   size, z = - size },
		[7] = { x =   size, y = - size, z = - size },
		[8] = { x = - size, y = - size, z = - size },
	}
	o.edges = {
		{ 1, 2 },
		{ 1, 3 },
		{ 1, 4 },
		{ 2, 5 },
		{ 2, 6 },
		{ 3, 5 },
		{ 3, 7 },
		{ 4, 6 },
		{ 4, 7 },
		{ 5, 8 },
		{ 6, 8 },
		{ 7, 8 },
	}
	setmetatable(o, { __index = M })
	render.UpdateMatrix( "xyz", o )
	return o
end

return M