local la = love.audio

explosion = class:new()
explosions = {}

function explosion:init(x, y, maxradius, radiusvel)
	self.x = x
	self.y = y
	self.radius = 1
	self.maxradius = maxradius
	self.radiusvel = radiusvel

	sfx_explode:clone():play()
end

function explosion:update(dt)

	local function filter(i)
		return i.isEnemy or i.type == "player"
	end
	local items, len = bumpwrld:queryRect(self.x-self.radius/2, self.y-self.radius/2, self.radius, self.radius, filter)
	for i,v in ipairs(items) do
		v:damage(self)
	end

	self.radius = self.radius + self.radiusvel * dt
	if self.radius >= self.maxradius then
		self.deleteself = true
	end

end

function explosion:draw()
	lg.setColor(1, math.random()*0.75, 0, 1)
	lg.rectangle("fill", self.x-self.radius/2, self.y-self.radius/2, self.radius, self.radius)
	lg.setColor(1,1,1)
end

function explosion:delete()

end
