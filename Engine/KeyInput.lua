local ki = love.keyboard;
local GetKey = ki.isDown;

local KeyInput = {
	GetKey = GetKey,
}



function KeyInput.GetInputDir (lesser, greater)
	local dir = 0;
	if GetKey (lesser) then dir = -1; end
	if GetKey (greater) then dir = dir + 1; end
	return dir;
end

return KeyInput;