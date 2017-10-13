--[[
===========================================================================

Finds zeroing angle by binary search

angMax = math.pi / 45 is for distances up to 2800 m
Writes results to zeroing_angles.txt

===========================================================================
]]

-- input
zeroingDistances = { 300, 2200 }
distanceThreshold = 0.01

-- output file
outputFile = io.output( "zeroing_angles.txt" )

-- constants
INITIAL_VELOCITY = 880
AIR_RESISTANCE_COEF = - 0.00055
GRAVITY = - 9.8
DT = distanceThreshold * 0.001

for i = zeroingDistances[1], zeroingDistances[2], 100 do
	angMin = 0
	angMax = math.pi / 45
	-- main cycle
	repeat
		ang = ( angMin + angMax ) / 2
		x = 0
		v = INITIAL_VELOCITY
		vx = v * math.cos( ang )
		vy = v * math.sin( ang )
		x = 0
		y = 0
		-- simulation cycle
		repeat
			-- air resistance
			local arx = vx * v * AIR_RESISTANCE_COEF
			local ary = vy * v * AIR_RESISTANCE_COEF
			-- speed change
			vx = vx + arx * DT
			vy = vy + ( ary + GRAVITY ) * DT 
			-- position change
			x = x + vx * DT
			y = y + vy * DT
			-- velocity
			v = math.sqrt( vx^2 + vy^2 )
		until y <= 0 or x >= i
		if 		x > i + distanceThreshold then angMax = ang
		elseif 	x < i - distanceThreshold then angMin = ang
		elseif math.abs( x - i ) < distanceThreshold then
			if math.abs( y ) < distanceThreshold then break
			else angMax = ang end
		end
	until false
	-- to screen
	print( "----------- " .. i .. " -----------" )
	print( "x           = " .. x )
	print( "y           = " .. y )
	print( "ang ( deg ) = " .. math.deg( ang ) )
	print( "ang ( rad ) = " .. ang )
	-- to file
	outputFile:write( "----------- " .. i .. " -----------\n" )
	outputFile:write( "x           = " .. x .. "\n" )
	outputFile:write( "y           = " .. y .. "\n" )
	outputFile:write( "ang ( deg ) = " .. math.deg( ang ) .. "\n" )
	outputFile:write( "ang ( rad ) = " .. ang .. "\n" )
end

outputFile:close()
