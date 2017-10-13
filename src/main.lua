--[[
===========================================================================

Sniper prototype

The idea is to simulate shooting M4 rifle equippded with 4x optics.
The scope has 2x-4x magnification and 200m zeroing.
Muzzle speed of M4 carbine is 880 m/s.
The simulation consists of
	- bullet ballistics ( initial speed, air resistance, gravity )
	- spread
	- "shaky hands" with variable amplitude
	- weapon fire feedback
	- breath holding ability
	- weapon barrel has proper offset relative to scope

===========================================================================
]]

function love.load()
	love.mouse.setRelativeMode( true )
	love.graphics.setBackgroundColor( 133, 149, 150 )
	-- load sounds
	sndDataShot = love.sound.newSoundData( "sounds/M4_shot.ogg" )
	sndDataBreath = {
		love.sound.newSoundData( "sounds/breath01.ogg" ),
		love.sound.newSoundData( "sounds/breath02.ogg" ),
		love.sound.newSoundData( "sounds/breath03.ogg" ),
	}
	-- load modules
	config =			require( "modules/config" )
	utils =				require( "modules/utils" )
	timer =				require( "modules/timer" )
	timekeeper =		require( "modules/timekeeper" )
	camera =			require( "modules/camera" )
	weapon =			require( "modules/weapon" )
	scope =				require( "modules/scope" )
	render =			require( "modules/render" )
	bullet =			require( "modules/bullet" )
	target =			require( "modules/target" )
	movingTarget =		require( "modules/movingTarget" )
	cube = 				require( "modules/cube" )
	gadgets =			require( "modules/gadgets" )
	targetsFactory =	require( "modules/targetsFactory" )
	world =				require( "modules/world" )
	world.Init()
end

function love.update( dt )
	if gameIsPaused then
		return
	end
	timekeeper.update( dt )
	world.update( dt )
end

function love.draw()
	world.draw()
end

--[[
========================
Player Input
========================
]]

function love.keypressed( key, scancode, isrepeat )
	if key == "escape" then love.event.quit() end
	world.keypressed( key, scancode, isrepeat )
end

function love.keyreleased( key, scancode )
	world.keyreleased( key, scancode )
end

function love.mousepressed( x, y, button, istouch )
	world.mousepressed( x, y, button, istouch )
end

function love.mousereleased( x, y, button, istouch )
	world.mousereleased( x, y, button, istouch )
end

function love.mousemoved( x, y, dx, dy )
	world.mousemoved( x, y, dx, dy )
end

function love.wheelmoved( x, y )
	world.wheelmoved( x, y )
end

--[[
========================
Pause and Quit
========================
]]

function love.focus( f )
	gameIsPaused = not f
end

function love.quit()
end
