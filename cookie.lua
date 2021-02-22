cookie = class:new()
cookies = {}

local model = polygon.new("soda/cookie.soda")

local movetimermax = 1/30
local primedtimermax = 3

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
			self.px = self.x + math.random()*10
			self.py = self.y + math.random()*10
			self.movetimer = 0
		end
	elseif self.state == "primed" then
		self.primedtimer = self.primedtimer + dt
		if self.primedtimer >= primedtimermax then
			self.deleteself = true
		end

		self.x = self.x + self.xv * dt
		self.y = self.y + self.yv * dt

		self.yv = self.yv + 30*60 * dt

		self.px = self.x
		self.py = self.y
	end

	-- collision
	local function filter(i, o)
		if o.type == "player" or o.isEnemy then
			return "cross"
		end
	
		if self.state == "normal" then
			return "slide"
		else
			self.xv = 0
			self.yv = 0
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
	lg.scale(1.5,1.5)
	polygon.draw(model)
	lg.pop()
end

function cookie:damage(o)
	local dx = 0
	if o.player_facing then dx = o.player_facing
	else dx = lume.sign(self.x - o.x) end

	if self.state == "normal" then
		self.state = "primed"
		self.xv = dx * 600
		self.yv = -200
	else
		self.xv = dx * 600
		self.yv = -200
		self.y = self.y-2
	end

	sfx_enemy_pop:stop()
	sfx_enemy_pop:setPitch(0.9 + math.random(4)/10)
	sfx_enemy_pop:play()
end

function cookie:delete()
	bumpwrld:remove(self)
	local spawndrop = lume.weightedchoice({
		[true] = 1,
		[false] = 4*2
	})
	if spawndrop then
		pickups[#pickups+1] = pickup:new(self.x, self.y+10)
	end
	-- spawn gibs
	for i=1,20 do
		gibs[#gibs+1] = gib:new(self.x+30, self.y,
			math.pi*math.random(), math.random(-60*6, 60*6),
			-math.random(500, 1000), math.pi/2*math.random(-60, 60))
	end
	-- spawn explosion
	explosions[#explosions+1] = explosion:new(self.x, self.y, 360, 750)
end
