cookie = class:new()
cookies = {}

local model = polygon.new("soda/cookie.soda")

local movetimermax = 1/30

function cookie:init(x, y)
	self.x = x
	self.y = y

	self.px = x
	self.py = y

	self.isEnemy = true
	self.type = "cookie"
	self.movetimer = 0

	self.state = "normal" -- normal, primed

	self.primedtimer = 0

	self.deleteself = false

	bumpwrld:add(self, self.x, self.y, 50, 50)
end

function cookie:update(dt)
	self.movetimer = self.movetimer + dt
	if self.movetimer > movetimermax then
		self.px = self.x + math.random()*5
		self.py = self.y + math.random()*5
		self.movetimer = 0
	end

	-- collision
	local function filter(i, o)
		if o.type == "player" then
			return "cross"
		end
		return "slide"
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
	end
end

function cookie:delete()
	bumpwrld:remove(self)
	-- spawn gibs?
end
