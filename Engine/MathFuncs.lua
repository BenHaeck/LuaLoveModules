
local MF = {SmoothAmount = 0.32}

function MF.SmoothEdge (x,y)
	local mult = 1 - math.abs(x * y * MF.SmoothAmount);
	return x * mult, y * mult;
end

function MF.Normalize (x,y)
	if x == 0 or y == 0 then return 0,0; end
	local mult = 1/math.sqrt ((x * x) + (y * y));
	return x * mult, y * mult;
end

return MF;