--[[
===========================================================================

Weapon

===========================================================================
]]

local offset = - 0.05

local M = {
	x = 0,
	y = offset,
	z = 0,
	rx = 0,
	ry = 0,
	rz = 0,
}

--[[
========================
weaon.UpdateWeaponParenting
========================
]]
function M.UpdateWeaponParenting()
	M.rx = M.GetZeroingAngle()
	render.UpdateMatrix( "yxz", M )
	M.matrix = render.TransformMatrix( camera.matrix, M.matrix )
end

--[[
========================
weaon.GetZeroingAngle
========================
]]
function M.GetZeroingAngle()
	for i, v in ipairs( scope.current.zeroingData ) do
		if scope.current.zeroing == v[1] then return v[2] end
	end
end

return M