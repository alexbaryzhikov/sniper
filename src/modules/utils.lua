--[[
===========================================================================

Utils

===========================================================================
]]

local M = {}

--[[
========================
utils.GetDistance
========================
]]
function M.GetDistance( a, b )
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return math.sqrt( dx^2 + dy^2 + dz^2 )
end

--[[
========================
utils.GetHorizontalDistance
========================
]]
function M.GetHorizontalDistance( a, b )
	local dx = a.x - b.x
	local dz = a.z - b.z
	return math.sqrt( dx^2 + dz^2 )
end

--[[
========================
utils.RemoveFromList
========================
]]
function M.RemoveFromList( list, ent )
	if ( list and ent ) then
		for i,v in ipairs( list ) do
			if v == ent then
				table.remove( list, i )
				break
			end
		end
	end
end

--[[
========================
utils.Round
========================
]]
function M.Round( v, d )
	if not d then d = 0 end
	if d >= 0 then
		if v >= 0 then
			return math.floor( v * 10^d + 0.5 ) / 10^d
		else
			return math.ceil( v * 10^d - 0.5 ) / 10^d
		end
	else
		if v >= 0 then
			return math.floor( v / 10^( - d ) + 0.5 ) * 10^( - d )
		else
			return math.ceil( v / 10^( - d ) - 0.5 ) * 10^( - d )
		end
	end
end

return M