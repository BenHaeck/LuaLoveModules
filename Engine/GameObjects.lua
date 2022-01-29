local GOLib = {};

local Physics = require ("Engine/Physics");
local Logger = require ("Engine/Logger");
local Rendering = require ("Engine/Rendering");
local LevelLoader = require ("Engine/LevelLoader");

function GOLib.MakeGameObject (x,y,w,h, name, self)
	if self == nil then self = {}; end
	self.collider = Physics.MakeCollider(x,y,w,h,nil);

	self.name = name;

	self.visible = true;
	self.enabled = true;

	self.motionX = 0;
	self.motionY = 0;

	self.collidedx = false;
	self.collidedy = false;


	function self:start (scene, x, y)end

	function self:update(scene, container, dt)
		if self.enabled then
			if self.onUpdate ~= nil then
				self:onUpdate(scene, container, dt);
			end
		end
	end

	function self:message (message, x, y)
		return false;
	end

	--self.sbIndex = nil;
	self.renderer = {sbIndex = nil, quad = nil, offsetx = 0, offsety = 0,rotation = 0, w = 1, h = 1}

	function self:updateSprite (spriteBatch)
		if spriteBatch == nil then return; end
		local renderer = self.renderer;
		if renderer.sbIndex == nil then
			renderer.sbIndex = spriteBatch:add (0,0) 
		end
		if renderer.quad ~= nil then 
			local collider = self.collider;
			local qx,qy,qw,qh = self.renderer.quad:getViewport();
			local drx,dry,drw,drh = Rendering.camera:WorldToScreen(
				collider.x + renderer.offsetx, collider.y + renderer.offsety,
				renderer.w, renderer.h
			)
			spriteBatch:set(renderer.sbIndex, renderer.quad, drx, dry, renderer.rotation, drw, drh, qw*0.5, qh*0.5);
		else
			local collider = self.collider;
			local tw, th = spriteBatch:getTexture():getDimensions();
			local drx,dry,drw,drh = Rendering.camera:WorldToScreen(
				collider.x + renderer.offsetx, collider.y + renderer.offsety,
				renderer.w, renderer.h
			)
			spriteBatch:set(renderer.sbIndex, drx, dry, renderer.rotation, drw, drh, tw*0.5, th*0.5);
		end
	end



	function self:draw (spriteBatch)

		if spriteBatch ~= nil then self:updateSprite(spriteBatch); end
		if self.onDraw ~= nil and self.visible then
			self:onDraw();
		end
	end

	function self:onCollision (obj)

	end

	function self:onRemove ()end

	function self:collide (obj, dim)
		if self.collider:collide (obj.collider, dim) then
			self:onCollision (obj);
			obj:onCollision (self);
			return true;
		end
		return false;
	end

	return self;
end






function GOLib.MakeObjectGroup (image,self)

	if self == nil then self = {}; end
	self.objs = {};
	self.enabled = true;
	self.visible = true;

	if image ~= nil then
		self.sb = love.graphics.newSpriteBatch (image,20);
	end

	function self:RefreshSpriteBatch ()
		if self.sb == nil then return; end
		self.sb:clear()

		for i,v in ipairs(self.objs) do
			v.renderer.sbIndex = nil;
			v:updateSprite(sb);
		end

	end

	self._color = {r = 1, g = 1, b = 1, a = 1};
	function self:setColor (r,g,b,a)
		self._color.r = r;
		self._color.g = g;
		self._color.b = b;
		self._color.a = a;
	end
	
	self.static = false;
	self.chunks = nil;

	
	
	function self:start (scene)
		if self.static then self:formatChunks() end 
	end
	
	function self:add (v)
		table.insert(self.objs, v);
	end
	
	function self:remove (i)
		self.objs[i].onRemove();
		table.remove (self.objs, i);
		self:RefreshSpriteBatch();
	end

	function self:getObjectWithName (name)
		for i,v in pairs (self.objs) do
			if v.name ~= nil then
				if v.name == name then return v; end
			end
		end
	end
	
	function self:clear ()
		for i,v in ipairs(self.objs) do 
			v:onRemove()
		end
		self.objs = {}
	end
	
	function self:formatChunks (showChunkInfo)
		if showChunkInfo == nil then showChunkInfo = false; end
		if self.chunks ~= nil then
			for ci,cv in ipairs(self.chunks) do
				cv.objs = {};
				if cv.area ~= nil then
					for oi, ov in ipairs(self.objs) do
						if ov.collider:collide (cv.area) then
							table.insert(cv.objs,ov);
							if showChunkInfo then Logger.log(
								"object at {" .. tostring(ov.collider.x).. ", "..
								tostring(ov.collider.y) .. "} added to " .. ci
							); end
						end
					end
				else
					Logger.log ("area " .. ci .. " is nil");

				end
			end
		else
			Logger.log("Chunks are null");
		end
	end

	function self:collide (coll,dim)
		local collided = false;
		if (not self.static) --[[or self.chunks == nil--]] then
			for i,v in ipairs(self.objs) do
				if coll:collide(v,dim) then
					collided = true;
				end
			end 
		else
			for oi,ov in ipairs(self.chunks) do
				--Logger.log (tostring (oi) .. tostring(#ov.objs))
				--local numberOfHits = 0;
				if coll.collider:collide(ov.area) then
					--numberOfHits = numberOfHits + 1;
					for ii, iv in ipairs(ov.objs) do
						if coll:collide (iv,dim) then collided = true; end
					end
				end
				--Logger.log ("hits " .. numberOfHits .. "")
			end
		end
		return collided;
	end

	function self:update (scene,dt)
		if not self.enabled then return; end
		if self.preUpdate ~= nil then self:preUpdate(scene,dt); end
		for i,v in ipairs(self.objs) do
			v:update (scene, self, dt);
		end
		if self.postUpdate ~= nil then self:postUpdate(scene,dt); end
	end



	function self:draw ()
		local color = self._color;
		love.graphics.setColor(color.r, color.g, color.b, color.a);
		if self.preDraw ~= nil then self:preDraw(); end
		if not self.visible then return; end
		for i,v in ipairs (self.objs) do
			v:draw (self.sb);
		end
		if self.sb ~= nil then love.graphics.draw(self.sb,0,0); end
		if self.postDraw ~= nil then self:postDraw(); end
	end
	return self
end


function GOLib.MakeScene (self)
	if self == nil then self = {}; end
	
	self.groups = {};

	self.groupOrder = {}

	self.objectPositionChanger = nil
	function self:LoadLevel (path)
		LevelLoader.LoadLevel(path, self, self.objectPositionChanger);
		self:init ();
	end

	function self:init ()
		if self.start ~= nil then self:start(); end
		local groups = self.groups;
		for i,v in ipairs(self.groupOrder) do
			groups[v]:start(self);
		end
	end

	function self:clear()
		for i,v in ipairs(self.groups) do
			v:clear();
		end
	end



	function self:update (dt)
		if self.preUpdate ~= nil then self:preUpdate(dt); end
		for i,v in ipairs (self.groupOrder) do
			self.groups[v]:update(self,dt);
		end
		if self.postUpdate ~= nil then self:postUpdate(dt); end

		for i1,v1 in ipairs (self.groupOrder) do
			local gr1 = self.groups[v1]
			--Logger.log ("ss");
			if gr1.static then
				for i2, v2 in ipairs (self.groupOrder) do
					local gr2 = self.groups[v2];
					if (not gr2.static) then 
						for oi, ov in ipairs (gr2.objs) do
							local ovcoll = ov.collider;
							ovcoll.x = ovcoll.x + (ov.motionX * dt);
							ov.collidedx = gr1:collide (ov, "x");

							ovcoll.y = ovcoll.y + (ov.motionY * dt);
							ov.collidedy = gr1:collide (ov, "y");
						end
					end
				end
			end
		end
	end

	function self:draw (dt)
		for i,v in ipairs (self.groupOrder) do
			self.groups[v]:draw();
		end
	end

	return self
end

return GOLib;
