steamypb = class:new()
steamypbs = {}

local pb_spr = polygon.new("soda/ui_steamypb.soda")
local maxradius = 450
local radiusvel = 1000

function steamypb:init(x, y, dir)
	self.x = x
	self.y = y
	self.yv = -300

	self.radius = 1

	self.dir = dir

	self.state = "throw" -- throw, explode

	bumpwrld:add(self, self.x, self.y, 30, 30)
end

function steamypb:update(dt)
	if self.state == "throw" then
		self.x = self.x+ self.dir*600*dt
		self.y = self.y + self.yv*dt
		self.yv = self.yv + 20*60*dt
	else
		self.radius = self.radius + radiusvel * dt
		bumpwrld:update(self, self.x-self.radius/2, self.y-self.radius/2, self.radius, self.radius/2)
	
		if self.radius > maxradius then
			self.deleteself = true
		end
	end

	local function filter(i, o)
		if self.state == "throw" and o.type ~= "player" then
			return "touch"
		else
			return "cross"
		end
	end
	local ax, ay, cols, len
	if self.state == "throw" then
		ax, ay, cols, len = bumpwrld:move(self, self.x, self.y, filter)
	else
		ax, ay, cols, len = bumpwrld:move(self, self.x-self.radius/2, self.y-self.radius/2, filter)
	end
	local o
	for i, v in ipairs(cols) do
		o = v.other
		if self.state == "throw" then
			if o.type == "ground" or o.isEnemy then
				self.state = "explode"
				sfx_explode:clone():play()
				ay = ay + 30
				break
			end
		else
			if o.isEnemy then
				o:damage()
			end
		end
	end

	self.x = ax+self.radius/2
	self.y = ay+self.radius/2
end

function steamypb:draw()
	if self.state == "throw" then
		lg.push()
		lg.translate(self.x-15, self.y-15)
		lg.scale(0.3, 0.3)
		polygon.draw(pb_spr)
		lg.pop()
	else
		lg.setColor(1, math.random()*0.75, 0, 1)
		lg.rectangle("fill", self.x-self.radius/2, self.y-self.radius/2, self.radius, self.radius/2)
		lg.setColor(1,1,1)
	end
end

function steamypb:damage()

end

function steamypb:delete()
	bumpwrld:remove(self)
end
