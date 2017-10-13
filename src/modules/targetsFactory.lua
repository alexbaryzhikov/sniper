--[[
===========================================================================

TargetsFactory

Produces quality cardboard targets for shooting practice.

===========================================================================
]]

local M = {}

--[[
========================
targetsFactory.CreateTargets
========================
]]
function M.CreateTargets()
	-- static targets
	local z = { 25, 50, 100, 200, 500, 1000, 2000 }
	local x = { -6, -6,  -4,   0,  5,   16,  40 }
	for i = 1, #z do
		local offsZ, offsX = z[i], x[i]
		-- head
		local t = target.New( {
			x = offsX,
			y = 1.7,
			z = offsZ,
			rx = 0,
			ry = math.pi,
			rz = 0,
			sizeX = 0.2,
			sizeY = 0.3,
			color = { r = 246, g = 235, b = 197 },
		} )
		table.insert( world.targets, t )
		-- torso
		local t = target.New( {
			x = offsX,
			y = 0.85,
			z = offsZ,
			rx = 0,
			ry = math.pi,
			rz = 0,
			sizeX = 0.4,
			sizeY = 0.85,
			color = { r = 246, g = 235, b = 197 },
		} )
		table.insert( world.targets, t )
		-- arms
		local t = target.New( {
			x = offsX + 0.28,
			y = 0.77,
			z = offsZ,
			rx = 0,
			ry = math.pi,
			rz = math.rad( 3 ),
			sizeX = 0.12,
			sizeY = 0.92,
			color = { r = 246, g = 235, b = 197 },
		} )
		table.insert( world.targets, t )
		local t = target.New( {
			x = offsX - 0.28,
			y = 0.77,
			z = offsZ,
			rx = 0,
			ry = math.pi,
			rz = math.rad( - 3 ),
			sizeX = 0.12,
			sizeY = 0.92,
			color = { r = 246, g = 235, b = 197 },
		} )
		table.insert( world.targets, t )
		-- legs
		local t = target.New( {
			x = offsX + 0.11,
			y = 0,
			z = offsZ,
			rx = 0,
			ry = math.pi,
			rz = 0,
			sizeX = 0.18,
			sizeY = 0.85,
			color = { r = 246, g = 235, b = 197 },
		} )
		table.insert( world.targets, t )
		local t = target.New( {
			x = offsX - 0.11,
			y = 0,
			z = offsZ,
			rx = 0,
			ry = math.pi,
			rz = 0,
			sizeX = 0.18,
			sizeY = 0.85,
			color = { r = 246, g = 235, b = 197 },
		} )
		table.insert( world.targets, t )
	end
	-- moving targets
	local z = {  15, 	  0, 	- 10 }
	local x = { 100, 	200, 	 500 }
	local s = {   3, 	  2, 	   2 }
	for i = 1, #z do
		-- create parent Moving Target object
		local mt = movingTarget.New( {
			x = x[i],
			y = 0,
			z = z[i],
			rx = 0,
			ry = math.pi / 2,
			rz = 0,
			speed = s[i],
			waypoints = {
				{ x = x[i], y = 0, z = -20 },
				{ x = x[i], y = 0, z = 20 },
			},
		})
		table.insert( world.movingTargets, mt )
		-- create child elements
		-- head
		local t = target.New( {
			x = 0,
			y = 1.7,
			z = 0,
			rx = 0,
			ry = 0,
			rz = 0,
			sizeX = 0.2,
			sizeY = 0.3,
			color = { r = 246, g = 235, b = 197 },
			parent = mt,
		} )
		table.insert( mt.targets, t )
		table.insert( world.targets, t )
		-- torso
		local t = target.New( {
			x = 0,
			y = 0.85,
			z = 0,
			rx = 0,
			ry = 0,
			rz = 0,
			sizeX = 0.4,
			sizeY = 0.85,
			color = { r = 246, g = 235, b = 197 },
			parent = mt,
		} )
		table.insert( mt.targets, t )
		table.insert( world.targets, t )
		-- arms
		local t = target.New( {
			x = - 0.28,
			y = 0.77,
			z = 0,
			rx = 0,
			ry = 0,
			rz = math.rad( 3 ),
			sizeX = 0.12,
			sizeY = 0.92,
			color = { r = 246, g = 235, b = 197 },
			parent = mt,
		} )
		table.insert( mt.targets, t )
		table.insert( world.targets, t )
		local t = target.New( {
			x = 0.28,
			y = 0.77,
			z = 0,
			rx = 0,
			ry = 0,
			rz = math.rad( - 3 ),
			sizeX = 0.12,
			sizeY = 0.92,
			color = { r = 246, g = 235, b = 197 },
			parent = mt,
		} )
		table.insert( mt.targets, t )
		table.insert( world.targets, t )
		-- legs
		local t = target.New( {
			x = - 0.11,
			y = 0,
			z = 0,
			rx = 0,
			ry = 0,
			rz = 0,
			sizeX = 0.18,
			sizeY = 0.85,
			color = { r = 246, g = 235, b = 197 },
			parent = mt,
		} )
		table.insert( mt.targets, t )
		table.insert( world.targets, t )
		local t = target.New( {
			x = 0.11,
			y = 0,
			z = 0,
			rx = 0,
			ry = 0,
			rz = 0,
			sizeX = 0.18,
			sizeY = 0.85,
			color = { r = 246, g = 235, b = 197 },
			parent = mt,
		} )
		table.insert( mt.targets, t )
		table.insert( world.targets, t )
		mt:UpdateChildMatrices()
	end
	world.TargetsZSort()
end

return M