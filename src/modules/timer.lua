--[[
===========================================================================

Timer

===========================================================================
]]

local M = {}

--[[
========================
timer.New
========================
]]
function M.New( params )
	local o = {}
	if not params.callbackModule then print( "ERROR! No callback module specified: " .. params.name ) end
	-- parameters
	o.name = params.name
	o.callbackModule = params.callbackModule
	o.basePeriod = params.basePeriod
	o.randomness = math.max( math.min( params.randomness, 1 ), 0 )  -- must have a range of [0, 1]
	o.isRepeating = params.isRepeating
	o.isReturnSelf = params.isReturnSelf
	-- variables
	o.time = 0
	o.currentPeriod = o.basePeriod * ( 1 + o.randomness * ( math.random() * 2 - 1 ) )
	o.isPaused = false
	setmetatable( o, { __index = M } )
	timekeeper.AddTimer( o )
	return o
end

--[[
========================
timer:Pause
========================
]]
function M:Pause()
	self.isPaused = true
end

--[[
========================
timer:Unpause
========================
]]
function M:Unpause()
	self.isPaused = false
end

--[[
========================
timer:Reset
========================
]]
function M:Reset()
	self.time = 0
	self.currentPeriod = self.basePeriod * ( 1 + self.randomness * ( math.random() * 2 - 1 ) )
end

--[[
========================
timer:Update
========================
]]
function M:update( dt )
	if self.time >= self.currentPeriod then
		if self.isRepeating then
			self:OnTimerTick()
		else
			self:OnTimerFinish()
		end
	end
	if not self.isPaused then
		self.time = self.time + dt
	end
end

--[[
========================
timer:OnTimerTick
========================
]]
function M:OnTimerTick()
	self.time = 0
	self.currentPeriod = self.basePeriod * ( 1 + self.randomness * ( math.random() * 2 - 1 ) )
	timekeeper.OnTimerTick( { timer = self } )
end

--[[
========================
timer:OnTimerFinish
========================
]]
function M:OnTimerFinish()
	timekeeper.OnTimerFinish( { timer = self } )
end

return M