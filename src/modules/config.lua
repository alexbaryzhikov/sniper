--[[
===========================================================================

Config

===========================================================================
]]

local M = {
	BULLET_INITIAL_SPEED = 880,
	AIR_RESISTANCE_COEF = - 0.00055,
	GRAVITY = - 9.8,
	SENSITIVITY = 5.0,
	ZOOM_SENSITIVITY = 5,
	MOVE_SPEED = 20,
	POSTURE_STAND_HEIGHT = 1.8,
	POSTURE_CROUCH_HEIGHT = 1.0,
	POSTURE_LAY_HEIGHT = 0.3,
	SPREAD_ANGLE = math.rad( 0.025 ),
	RECOIL_ANGLE = math.rad( 0.5 ),
	RECOIL_DURATION = 0.3,
	WANDER_ANGLE_MIN = math.rad( 0.05 ),
	WANDER_ANGLE_MAX = math.rad( 0.15 ),
	WANDER_TIME_MIN = 2.5,
	WANDER_TIME_MAX = 5,
	HOLD_BREATH_TIME = 4,
	RESPIRATORY_TIME = 3,
	HOLD_BREATH_RELEASE_TIME = 0.2,
}

return M