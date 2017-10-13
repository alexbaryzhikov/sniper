--[[
===========================================================================

Timekeeper

===========================================================================
]]

local M = {}
local timers = {}

--[[
========================
timekeeper.AddTimer
========================
]]
function M.AddTimer( t )
	table.insert( timers, t )
end

--[[
========================
timekeeper.RemoveTimer
========================
]]
function M.RemoveTimer( t )
	utils.RemoveFromList( timers, t )
end

--[[
========================
timekeeper.update
========================
]]
function M.update( dt )
	for i, v in ipairs( timers ) do
		if v then v:update( dt ) end
	end
end

--[[
========================
timekeeper.OnTimerTick
========================
]]
function M.OnTimerTick( event )
	if event.timer.callbackModule.OnTimerTick then
		if event.timer.isReturnSelf then
			event.timer.callbackModule:OnTimerTick( { timer = event.timer } )
		else
			event.timer.callbackModule.OnTimerTick( { timer = event.timer } )
		end
	end
end

--[[
========================
timekeeper.OnTimerFinish
========================
]]
function M.OnTimerFinish( event )
	utils.RemoveFromList( timers, event.timer )
	if event.timer.callbackModule.OnTimerFinish then
		if event.timer.isReturnSelf then
			event.timer.callbackModule:OnTimerFinish( { timer = event.timer } )
		else
			event.timer.callbackModule.OnTimerFinish( { timer = event.timer } )
		end
	end
end

return M