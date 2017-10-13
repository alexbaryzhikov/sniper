--[[
===========================================================================

Scope

===========================================================================
]]

local M = {}

local scopeOverlay = love.graphics.newCanvas()

-- default marksman scope
M["DMS"] = {
	fov = 		2 * math.atan( math.tan( math.rad( 20 ) ) / 2 ),
	fovMin = 	2 * math.atan( math.tan( math.rad( 20 ) ) / 4 ),
	fovMax = 	2 * math.atan( math.tan( math.rad( 20 ) ) / 2 ),
	imgReticle = love.graphics.newImage( "textures/dms_reticle.tga" ),
	imgReticle2 = love.graphics.newImage( "textures/dms_reticle2.tga" ),
	reticleScale = camera.width / 2560, 
	reticle = function()
		local img = nil
		if M["DMS"].fov == M["DMS"].fovMin then img = M["DMS"].imgReticle2
		else img = M["DMS"].imgReticle end
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw(
			img,
			camera.width / 2, camera.height / 2, 0,
			M["DMS"].reticleScale, M["DMS"].reticleScale,
			640, 640
		)
	end,
	nearClip = 0.5,
	zeroing = 200,
	zeroingData = {
		{  100, 0.00068176923906029 },
		{  200, 0.0013976269400736  },
		{  300, 0.0021475731030399  },
		{  400, 0.0029656961899122  },
		{  500, 0.0038519962006906  },
		{  600, 0.004806473135375   },
		{  700, 0.0058291269939654  },
		{  800, 0.0069455241229267  },
		{  900, 0.0081556645222587  },
		{ 1000, 0.0094595481919615  },
		{ 1100, 0.010874219363012   },
		{ 1200, 0.012408200150897   },
	},
}

-- long range precision scope
M["LRPS"] = {
	fov = 		2 * math.atan( math.tan( math.rad( 20 ) ) /  6 ),
	fovMin = 	2 * math.atan( math.tan( math.rad( 20 ) ) / 25 ),
	fovMax = 	2 * math.atan( math.tan( math.rad( 20 ) ) /  6 ),
	imgReticle = love.graphics.newImage( "textures/lrps_reticle.tga" ),
	imgReticle2 = love.graphics.newImage( "textures/lrps_reticle2.tga" ),
	reticleScale = camera.width / 2560, 
	reticle = function()
		local img = nil
		if M["LRPS"].fov == M["LRPS"].fovMin then img = M["LRPS"].imgReticle2
		else img = M["LRPS"].imgReticle end
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw(
			img,
			camera.width / 2, camera.height / 2, 0,
			M["LRPS"].reticleScale, M["LRPS"].reticleScale,
			640, 640
		)
	end,
	nearClip = 0.5,
	zeroing = 500,
	zeroingData = {
		{  300, 0.0021475731030399 },
		{  400, 0.0029656961899122 },
		{  500, 0.0038519962006906 },
		{  600, 0.004806473135375  },
		{  700, 0.0058291269939654 },
		{  800, 0.0069455241229267 },
		{  900, 0.0081556645222587 },
		{ 1000, 0.0094595481919615 },
		{ 1100, 0.010874219363012  },
		{ 1200, 0.012408200150897  },
		{ 1300, 0.014078534786595  },
		{ 1400, 0.015876701154616  },
		{ 1500, 0.017836787716915  },
		{ 1600, 0.019963055531234  },
		{ 1700, 0.022272548828551  },
		{ 1800, 0.024782311839841  },
		{ 1900, 0.027517910911571  },
		{ 2000, 0.030492129216971  },
		{ 2100, 0.033726272044763  },
		{ 2200, 0.037258688914645  },
	},
}

M.types = { "DMS", "LRPS" }
M.type = 1
M.current = M[M.types[M.type]]

--[[
========================
scope.DrawScopeFrame
========================
]]
function M.DrawScopeFrame()
	-- set up canvas
	local DrawStencil = function()
		love.graphics.circle( "fill", camera.width / 2, camera.height / 2, camera.width / 4, 128 )
	end
	love.graphics.setCanvas( scopeOverlay )
	love.graphics.clear()
	love.graphics.stencil( DrawStencil, "replace", 1 )
	love.graphics.setStencilTest("equal", 0)
	-- draw
	love.graphics.setColor( 0, 0, 0, 220 )
	love.graphics.rectangle( "fill", 0, 0, camera.width, camera.height )
	love.graphics.setColor( 16, 16, 16 )
	love.graphics.circle( "fill", camera.width / 2, camera.height / 2, camera.width * 0.4 , 128 )
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.circle( "fill", camera.width / 2, camera.height / 2, camera.width * 0.35 , 128 )
	-- finish
	love.graphics.setStencilTest()
	love.graphics.setCanvas()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw( scopeOverlay )
end

return M