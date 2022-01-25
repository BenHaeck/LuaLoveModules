

local Physics = {dragMult = 10}

--local Physics.SDims = {x = "w", y = "h"}

function Physics.Collide1D (p1,s1,p2,s2) 
	local dist = math.abs(p1 - p2);
	local combsize = (s1 + s2) * 0.5;
	return dist < combsize;
end


function Physics.Drag (vel, drag, dt)
	return vel * ((1 - drag)^(dt * Physics.dragMult));
end

function Physics.MoveTowards (vel, tarPhysicst, chanPhysicsInSpeed, dt)
	return Physics.Drag (vel - tarPhysicst, chanPhysicsInSpeed, dt) + tarPhysicst;
end

function Physics.MakeCollider (x,y,w,h, self)
	if self == nil then
		self = {};
	end

	self.x = x;
	self.y = y;
	self.w = w;
	self.h = h;

	function self:Collide (coll, dim)
		local success = Physics.Collide1D (self.x, self.w, coll.x, coll.w) and Physics.Collide1D (self.y, self.h, coll.y, coll.h);
		if not success then return false; end
		if dim == "x" then
			local dir = 1
			if self.x < coll.x then dir = -1; end
			self.x = coll.x + ((self.w + coll.w) * 0.5 * dir)
		elseif dim == "y" then
			local dir = 1;
			if self.y < coll.y then dir = -1; end
			self.y = coll.y + ((self.h + coll.h) * 0.5 * dir)
		end
		
		return true;
	end

	return self;
end

return Physics