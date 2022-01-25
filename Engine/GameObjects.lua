local GOLib = {};

local Physics = require ("Engine/Physics");

function GOLib.MakeGameObject (x,y,w,h, self)
	if self == nil then self = {}; end
	self.collider = Physics.MakeCollider(x,y,w,h,nil);

	self.visible = true;
	self.enabled = true;

	self.motionX = 0;
	self.motionY = 0;



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
			spriteBatch:set(renderer.sbIndex, renderer.quad, collider.x + renderer.offsetx, collider.y + renderer.offsety, renderer.rotation, renderer.w, renderer.h, qw*0.5, qh*0.5);
		else
			local collider = self.collider;
			local tw, th = spriteBatch:getTexture():getDimensions();
			spriteBatch:set(renderer.sbIndex, collider.x + renderer.offsetx, collider.y + renderer.offsety, renderer.rotation, renderer.w, renderer.h, tw*0.5, th*0.5);
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
		if self.collider:Collide (obj.collider, dim) then
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
	self.chunkDividers = nil;
	self.chunks = nil;

	function self:generateChunks ()
		if self.chunkDividers ~= nil then

		end
	end
	

	function self:start (scene)

	end

	function self:add (v)
		table.insert(self.objs, v);
	end

	function self:remove (i)
		self.objs[i].onRemove();
		table.remove (self.objs, i);
		self:RefreshSpriteBatch();
	end

	function self:clear ()
		for i,v in ipairs(self.objs) do 
			v:onRemove()
		end
		self.objs = {}
	end

	function self:collide (coll,dim)
		local collided = false;
		for i,v in ipairs(self.objs) do
			if coll:collide(v,dim) then
				collided = true;
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



	function self:init ()
		if self.start ~= nil then self:start(); end
		local groups = self.groups;
		for i,v in self.groupOrder do
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
	end

	function self:draw (dt)
		for i,v in ipairs (self.groupOrder) do
			self.groups[v]:draw();
		end
	end

	return self
end

return GOLib;