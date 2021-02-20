local lg = love.graphics
local lk = love.keyboard

player = class:new()

local sprite = polygon.new("soda/THEGUY.soda")

function player:init(x, y)
	self.x, self.y = x, y
	self.xv, self.yv = 0, 0

	self.canjump = false

	bumpwrld:add(self, x, y, 60, 60)
end

function player:update(dt)

	-- ##################
	-- Input handling
	-- ##################
	-- Check once for input
	local kl, kr
	kl = lk.isDown("left")   -- move left
	kr = lk.isDown("right")  -- move right
	kx = lk.isDown("x")      -- jump
	kz = lk.isDown("z")      -- whip
	-- Turn booleans into integers
	local il, ir
	il = kl and 1 or 0
	ir = kr and 1 or 0
	dx = ir-il

	if lk.isDown("a") then self.xv = self.xv - 200*dt end
	if lk.isDown("d") then self.xv = self.xv + 200*dt end

	-- ##################
	-- Movement handling
	-- ##################
	-- Horizontal movement:
	-- This code was based off the psuedocode from the Sonic Physics Guide,
	-- I use it for all platformers because it works and provides a nice
	-- place to start with most platformers.
	local acc = 0.046875 * dt * 480
	local dec = 0.5      * dt * 720
	local frc = 0.35     * dt * 720
	local top = 6        *3/4

	if self.yv ~= 0 then -- bunnyhop support ;)
		top = top * 2
	end

	if kl then -- if holding left
		if self.xv > 0 then -- if going right
			self.xv = self.xv - dec
			if self.xv <= 0 then self.xv = -0.5 end
		elseif self.xv > -top then -- if going left
			self.xv = self.xv - acc
			if self.xv <= -top then self.xv = -top end
		end
	end

	if kr then -- if holding right
		if self.xv < 0 then -- if moving left
			self.xv = self.xv + dec
			if self.xv >= 0 then self.xv = 0.5 end
		elseif self.xv < top then -- if moving right
			self.xv = self.xv + acc
			if self.xv >= top then self.xv = top end
		end
	end

	if not
		( ( (kl or kr) and math.abs(self.xv) < top ) or self.yv ~= 0 )
		or (ks and self.yv == 0)
		then
		self.xv = self.xv - math.min(math.abs(self.xv), frc) * lume.sign(self.xv)
	end

	self.x = self.x + self.xv * 60 * dt

	-- ##################
	-- Gravity handling:
	-- ##################
	-- variable height jump
	if not lk.isDown("x") and self.yv < 0 then
		self.yv = self.yv / 1.075
	end

	-- gravity!
	self.yv = self.yv + 30 * dt
	self.y = self.y + self.yv * 30 * dt

	-- ##################
	-- Collision handling
	-- ##################
	-- collision filter, for determining how things should react on contact
	local function filter(i, o)
		return "slide"
	end

	-- run collision detection with the filter
	local ax, ay, cols, len = bumpwrld:move(self, self.x, self.y, filter)

	-- any extra processing of collisions
	local v, o
	for i = 1, len do
		v = cols[i] -- Phaux-ipairs
		o = v.other
		if o.type == "ground" then
			if v.normalX ~= 0 then
				self.xv = 0
			end
			if v.normalY ~= 0 then
				self.yv = 0
				if v.normalY == -1 then
					self.canjump = true
				end
			end
		end
	end

	-- finalize collision
	self.x, self.y = ax, ay
end

function player:draw()
	lg.push()
	lg.translate(self.x-6, self.y-14)
	lg.rectangle("line", 6, 14, 60, 60)
	polygon.draw(sprite)
	lg.pop()
end

function player:keypressed(k)
	if k == "x" then
		if self.canjump and self.yv == 0 then
			self.canjump = false
			self.yv = -17.5
		end
	end
end
