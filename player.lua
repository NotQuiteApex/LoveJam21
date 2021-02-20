local lg = love.graphics
local lk = love.keyboard

player = class:new()

whip_timer = 0
whip_max = 9
whip_freeze = 0
whip_freeze_max = 18
whip_hit_buffer = 2
player_facing = 1
whip_calc = 0
whip_angle = 0

health = 11

local earlyjumptimermax = 0.1
local coyotetimermax = 0.15

function player:init(x, y)
	self.x, self.y = x, y
	self.xv, self.yv = 0, 0

	self.canjump = false
	self.earlyjump = false
	self.earlyjumptimer = 0
	self.coyotetimer = 0

	bumpwrld:add(self, x, y, 60, 60)
end

function player:update(dt)
	-- Buffer jump input
	if self.earlyjump then
		self.earlyjumptimer = self.earlyjumptimer + dt
		if self.earlyjumptimer > earlyjumptimermax then
			self.earlyjump = false
			self.earlyjumptimer = 0
		end
	end

	-- Coyote time
	if self.canjump then
		self.coyotetimer = self.coyotetimer + dt
	end
	
	camera_x = self.x-- + default_width/2

	-- ##################
	-- Input handling
	-- ##################
	-- Check once for input
	local kl, kr
	kl = lk.isDown("left", "a")   -- move left
	kr = lk.isDown("right", "d")  -- move right
	--kx = lk.isDown("n")      -- jump
	--kz = lk.isDown("m")      -- whip
	-- Turn booleans into integers
	local il, ir, dx
	il = kl and 1 or 0
	ir = kr and 1 or 0
	dx = ir-il

	--if lk.isDown("a") then self.xv = self.xv - 20*dt end
	--if lk.isDown("d") then self.xv = self.xv + 20*dt end
	
	if whip_timer == 0 then
		if self.xv < 0 then
			player_facing = -1
		elseif self.xv > 0 then
			player_facing = 1
		end
	end

	-- ##################
	-- Movement handling
	-- ##################
	-- Horizontal movement:
	-- This code was based off the psuedocode from the Sonic Physics Guide,
	-- I use it for all platformers because it works and provides a nice
	-- place to start with most platformers.
	local acc = 120 * dt
	local dec = 120 * dt
	local frc = 100 * dt
	local top = 1000 * dt

	if self.yv ~= 0 then -- bunnyhop support ;)
		top = top * 1.5
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
	
	if n_key == _PRESS then
		if self.canjump and (self.yv == 0 or self.coyotetimer < coyotetimermax) then
			self:jump()
		else
			self.earlyjump = true
		end
	end
	
	if n_key == _OFF and self.yv < 0 then
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
					if self.earlyjump then
						self.earlyjump = false
						self.earlyjumptimer = 0
						self:jump()
					end
					self.coyotetimer = 0
				end
			end
		end
	end
	
	-- whip attack
	if m_key == _PRESS and whip_timer == 0 then
		whip_timer = 1
	end
	
	if whip_timer ~= 0 then
		whip_timer = math.min(whip_timer + dt * 60, whip_max)
	end
	
	if whip_timer == whip_max and whip_freeze == 0 then
		--whip_timer = 0
		whip_freeze = 1
	end
	
	if whip_freeze ~= 0 then
		whip_freeze = math.min(whip_freeze + 60 * dt, whip_freeze_max)
	end
	
	if whip_freeze == whip_freeze_max then
		whip_timer = 0
		whip_freeze = 0
	end
	
	whip_calc = whip_timer/whip_max
	whip_angle = -30 + (whip_calc * 210)

	-- finalize collision
	self.x, self.y = ax, ay
end

function player:draw()

	local x_draw = self.x-6
	if player_facing == -1 then
	lg.push()
	x_draw = -self.x-58
	lg.scale(-1,1)
	end
	
	lg.push()
	lg.translate(x_draw, self.y-16)
	
	if whip_timer ~= 0 then
	
		lg.push()
		lg.translate(30, 41)
		lg.rotate(math.rad(whip_angle))
		if whip_freeze ~= 0 then
			lg.scale(1.5, 1)
		end
		lg.translate(-70, -41)
		polygon.draw(mdl_whip)
		lg.pop()
	
	end
	
	polygon.draw(mdl_player)
	lg.pop()
	
	if player_facing == -1 then
	lg.pop()
	end
	
	--[[
	arm hit box
	
	if player_facing == -1 then
		lg.setColor(1,1,1,1)
		lg.circle("fill", self.x-6 + 32 + polygon.lengthdir_x(80, math.rad(whip_angle)), self.y-16 + 40 + polygon.lengthdir_y(80, math.rad(whip_angle)), 10)
	else
		lg.setColor(1,1,1,1)
		lg.circle("fill", self.x-6 + 32 + polygon.lengthdir_x(-80, math.rad(-whip_angle)), self.y-16 + 40 + polygon.lengthdir_y(-80, math.rad(-whip_angle)), 10)
	end
	
	]]
end

function player:jump()
	self.canjump = false
	self.yv = -20
	self.coyotetimer = 0
end
