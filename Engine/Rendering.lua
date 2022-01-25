
local graphics = love.graphics;
local Rendering = {}

function Rendering.DrawRectCenter (style,x,y,w,h)
	graphics.rectangle (style, x-(w*0.5), y-(h*0.5), w, h)

end

function Rendering.CreateRenderTR (x,y,r,w,h)
	self = {};
	self.x = x
	self.y = y;
	self.r = r;
	self.w = w;
	self.h = h;
	self.src = nil

	function self:setSrc (x,y,w,h)
		if self.src == nil then self.src = {}; end

		self.src.x = x;
		self.src.y = y;
		self.src.w = w;
		self.src.h = h;

	end

	function self:drawRect(x,y)
		if x == nil then x = 0; end
		if y == nil then y = 0; end
		Rendering.DrawRectCenter("fill", x+self.x, y+self.y, self.w, self.h);
	end


	return self;
end



return Rendering;