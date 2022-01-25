local Logger = require ("Engine/Logger")
local LevelLoader = {}

local function ReadFile (flpath)
	local file, err = io.open(flpath,"r");
	
	if file ~= nil then 
		local retval;
		retval = file:read("*all");
		file:close();
		return retval, true;
	else
		return err, false;
	end
end

function LevelLoader.LoadLevel (path, scene, trf)
	Logger.log ("loading Level: "..path);
	local res, success = ReadFile(path);
	
	if success then
		Logger.log ("Level Loaded Successfully");

		local x,y = 0, 0;

		for i = 1, #res do
			local ch = string.sub(res, i, i);
			if ch ~= " " and ch ~= "\n" then
				if scene.levelBuilder ~= nil then
					local objCreator = scene.levelBuilder[ch];
					if objCreator ~= nil then
						if trf == nil then
							objCreator(scene,x,y); 
						else
							objCreator(scene, trf(x,y));
						end
					end
				end
			end
			if ch == "\n" then
				y = y + 1;
				x = 0;
			else
				x = x + 1;
			end
		end
	else
		Logger.log ("Level loading failed: \n"..res.."\n");
	end
end

return LevelLoader