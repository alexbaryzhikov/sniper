--[[
===========================================================================

Camera

===========================================================================
]]

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local M = {
	x = 0,
	y = config.POSTURE_STAND_HEIGHT,
	z = 0,
	rx = 0,
	ry = 0,
	rz = 0,
	moveType = "constr",
	rxMin = math.rad( - 80 ),
	rxMax = math.rad(   80 ),
	fov = math.rad( 70 ),
	fovMin = math.rad( 70 ),
	fovMax = math.rad( 70 ),
	width = w,
	height = h,
	nearClip = 0.5,
}

M.view = M

--[[
========================
camera.Reset
========================
]]
function M.Reset()
	camera.x = 0
	camera.y = config.POSTURE_STAND_HEIGHT
	camera.z = 0
	camera.rx = 0
	camera.ry = 0
	camera.rz = 0
	camera.fov = math.pi / 2
	render.UpdateMatrix( "yxz", M )
	M.UpdateMovementMatrix()
	weapon.UpdateWeaponParenting()
	world.TargetsZSort()
end

--[[
========================
camera.UpdateMovementMatrix

The order of transform is yxz.

Types:
free		- Fixed Y, free X and Z
constr		- Fixed Y, X and Z have Y-constraint
========================
]]
function M.UpdateMovementMatrix()
	local sin, cos = math.sin, math.cos
	local rx, ry, rz = camera.rx, camera.ry, camera.rz
	if M.moveType == "free" then
		M.moveMatrix = {
			side = {
				x =   cos( ry ) * cos( rz ),
				y = - sin( rz ),
				z =   sin( ry ) * cos( rz ),
			},
			top = {
				x = 0,
				y = 1,
				z = 0,
			},
			front = {
				x = - sin( ry ) * cos( rx ),
				y =   sin( rx ),
				z =   cos( ry ) * cos( rx ),
			},
		}
	elseif M.moveType == "constr" then
		M.moveMatrix = {
			side = {
				x = cos( ry ),
				y = 0,
				z = sin( ry ),
			},
			top = {
				x = 0,
				y = 1,
				z = 0,
			},
			front = {
				x = - sin( ry ),
				y =   0,
				z =   cos( ry ),
			},
		}
	end
end

return M
