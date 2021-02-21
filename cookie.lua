cookie = class:new()
cookies = {}

local model = polygon.new("soda/cookie.soda")

local movetimermax = 1/30

function cookie:init(x, y)
	self.x = x
	self.y = y

	self.xv = 0
	self.yv = 0

	self.px = x
	self.py = y
	self.loader = loader.step

	self.isEnemy = true
	self.type = "cookie"
	self.movetimer = 0

	self.state = "normal" -- normal, primed

	self.primedtimer = 0

	self.deleteself = false

	bumpwrld:add(self, self.x, self.y, 50, 50)
end

function cookie:update(dt)

	if self.state == "normal" then
		self.movetimer = self.movetimer + dt
		if self.movetimer > movetimermax then
			self.px = self.x + math.random()*5
			self.py = self.y + math.random()*5
			self.movetimer = 0
		end
	elseif self.state == "primed" then
		self.x = self.x + self.xv * dt
		self.y = self.y + self.yv * dt
	end

	-- collision
	local function filter(i, o)
		if self.state == "normal" then
			if o.type == "player" then
				return "cross"
			end
			return "slide"
		else
			return "touch"
		end
	end

	-- run collision detection with the filter
	local ax, ay, cols, len = bumpwrld:move(self, self.px, self.py, filter)

	self.px, self.py = ax, ay
end

function cookie:draw()
	lg.push()
	lg.translate(self.px, self.py)
	polygon.draw(model)
	lg.pop()
end

function cookie:damage()
	if self.state == "normal" then
		self.state = "primed"
	else
		self.state = "explode"
	end
end

function cookie:delete()
	bumpwrld:remove(self)
	-- spawn gibs?
end
