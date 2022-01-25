local Log = "";

local Logger = {}

function Logger.GetLog ()
	return Log
end

function Logger.log (text)
	Log = Log .. text .. "\n";
end

function Logger.OutputLog (path)
	local res, err = io.open(path..".otp","w");
	if res ~= nil then
		res:write(Log);
		res:close();
	else
		error(err)
	end
end

return Logger;



