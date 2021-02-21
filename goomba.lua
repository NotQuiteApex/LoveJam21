goomba = class:new()
goombas = {}

local model = polygon.new("soda/goomba.soda")

function goomba:init(x, y)
	self.x = x
	self.y = y

	self.yv = 0
	self.xv = -1

	self.isEnemy = true
	self.type = "goomba"

	self.deleteself = false

	bumpwrld:add(self, self.x, self.y, 60, 60)
end

function goomba:update(dt)
	-- moving side to side
	self.x = self.x + 120 * dt * self.xv

	-- gravity
	self.yv = self.yv + 30 * dt
	self.y = self.y + self.yv * 30 * dt

	-- collision
	local function filter(i, o)
		if o.type == "ground" or o.type == "goomba" then
			return "slide"
		end
		return "cross"
	end

	-- run collision detection with the filter
	local ax, ay, cols, len = bumpwrld:move(self, self.x, self.y, filter)

	-- any extra processing of collisions
	local v, o
	for i = 1, len do
		v = cols[i] -- Phaux-ipairs
		o = v.other
		if o.type == "ground" or o.type == "goomba" then
			if v.normalX ~= 0 then
				self.xv = self.xv * (-1)
			end
			if v.normalY ~= 0 then
				self.yv = 0
			end
		end
	end

	self.x, self.y = ax, ay
end

function goomba:draw()
	lg.push()
	lg.translate(self.x, self.y)
	if self.xv == 1 then
		lg.translate(70, 0)
		lg.scale(-1, 1)
	end
	polygon.draw(model)
	lg.pop()
end

function goomba:damage()
	sfx_enemy_pop:stop()
	sfx_enemy_pop:setPitch(0.9 + math.random(4)/10)
	sfx_enemy_pop:play()
	self.deleteself = true
end

function goomba:delete()
	bumpwrld:remove(self)
	local spawndrop = lume.weightedchoice({
		[true] = 1,
		[false] = 0
	})
	if spawndrop then
		pickups[#pickups+1] = pickup:new(self.x, self.y+10)
	end
	-- spawn gibs?
end
