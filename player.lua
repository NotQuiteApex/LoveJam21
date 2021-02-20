local la = love.audio
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


local earlyjumptimermax = 0.1
local coyotetimermax = 0.15
local iframesmax = 0.5

local sfx_hurt = {}
for i=1,3 do sfx_hurt[i] = la.newSource("sfx/player_hurt"..i..".wav", "static") end

function player:init(x, y)
	self.x, self.y = x, y
	self.xv, self.yv = 0, 0

	self.health = 11

	self.canjump = false
	self.earlyjump = false
	self.earlyjumptimer = 0
	self.coyotetimer = 0

	self.iframes = 0
	self.iframesactive = false
	self.iframeseffect = false

	self.type = "player"

	self.state = "normal" -- normal, hurt, grappled

	self.appliedhurtimpulse = false

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

	if self.iframesactive then
		self.iframeseffect = not self.iframeseffect
		self.iframes = self.iframes + dt
		if self.iframes > iframesmax then
			self.iframesactive = false
			self.iframeseffect = false
			self.iframes = 0
		end
	end

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
	local top = 10

	if self.yv ~= 0 then -- bunnyhop support ;)
		top = top * 1.25
		dec = dec / 2
	end

	if self.state == "normal" then
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
		if o.isEnemy then
			return "cross"
		end
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
		elseif o.isEnemy then
			if self.state ~= "hurt" and not self.iframesactive then
				if v.normalX ~= 0 then self.xv = 0 end
				if v.normalY ~= 0 then self.yv = 0 end
				self.state = "hurt"
				self.health = self.health - 1
				if v.normalX == 0 and o.xv then
					self.hitdirection = o.xv
				elseif v.normalX == 0 then
					self.hitdirection = -player_facing
				else
					self.hitdirection = v.normalX
				end
				local sfx = math.random(#sfx_hurt)
				sfx_hurt[sfx]:setPitch(1 + math.random()*0.1 - 0.05)
				sfx_hurt[sfx]:play()
			end
		end
	end

	if self.state == "hurt" and not self.appliedhurtimpulse then
		self.xv = self.hitdirection * 7
		self.yv = -20
		self.appliedhurtimpulse = true
	elseif self.state == "hurt" and self.yv == 0 then
		self.state = "normal"
		self.appliedhurtimpulse = false
		self.iframesactive = true
	end

	-- finalize collision
	self.x, self.y = ax, ay

	
	-- whip attack
	if m_key == _PRESS and whip_timer == 0 then
		whip_timer = 1
	end

	-- collision items and filter
	local len, items = 0
	local function filter(i)
		return not (i.type == "ground" or i.type == "player")
	end
	
	if whip_timer ~= 0 then
		if whip_timer < whip_max / 2 then
			whip_timer = math.min(whip_timer + dt * 30, whip_max)

			-- grab backwhip collisions here
			if player_facing == -1 then
				items, len = bumpwrld:queryRect(self.x +38-4, self.y - 42, 58, 58)
			else
				items, len = bumpwrld:queryRect(self.x - 38, self.y - 42, 58, 58)
			end
		else
			whip_timer = math.min(whip_timer + dt * 60, whip_max)

			-- grab frontwhip collisions here
			if player_facing == -1 then
				items, len = bumpwrld:queryRect(self.x +28-48-4, self.y - 42, 58, 58)
			else
				items, len = bumpwrld:queryRect(self.x - 28+48, self.y - 42, 58, 58)
			end
		end
	end
	
	if whip_timer == whip_max and whip_freeze == 0 then
		--whip_timer = 0
		whip_freeze = 1
	end
	
	if whip_freeze ~= 0 then
		whip_freeze = math.min(whip_freeze + 60 * dt, whip_freeze_max)

		-- grab whip arm collisions here
		if player_facing == -1 then
			items, len = bumpwrld:queryRect(self.x -200+42, self.y + 16, 200, 16)
		else
			items, len = bumpwrld:queryRect(self.x + 12, self.y + 16, 200, 16)
		end
	end
	
	if whip_freeze == whip_freeze_max then
		whip_timer = 0
		whip_freeze = 0
	end
	
	whip_calc = whip_timer/whip_max
	whip_angle = -30 + (whip_calc * 210)

	-- handle whip collisions here
	if len > 0 then
		local v
		for i = 1, len do
			v = items[i]
			if v.damage then
				v:damage()
			end
		end
	end
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
			lg.scale(2, 1)
		end
		lg.translate(-70, -41)
		polygon.draw(mdl_whip)
		lg.pop()
	
	end
	
	if not self.iframesactive or self.iframeseffect then
		polygon.draw(mdl_player)
	end
	lg.pop()
	
	if player_facing == -1 then
	lg.pop()
	end
	
	
	--arm hit box
	if whip_timer ~= 0 then
		lg.setColor(1,1,1,1)
		if whip_freeze ~= 0 then
			if player_facing == -1 then
				lg.rectangle("line", self.x -200+42, self.y + 16, 200, 16)
			else
				lg.rectangle("line", self.x + 12, self.y + 16, 200, 16)
			end
		else
			if whip_timer < whip_max /2 then
				if player_facing == -1 then
					lg.rectangle("line", self.x +38-4, self.y - 42, 58, 58)
				else
					lg.rectangle("line", self.x - 38, self.y - 42, 58, 58)
				end
			else
				if player_facing == -1 then
					lg.rectangle("line", self.x +28-48-4, self.y - 42, 58, 58)
				else
					lg.rectangle("line", self.x - 28+48, self.y - 42, 58, 58)
				end
			end
		end
	end
	
end

function player:jump()
	self.canjump = false
	self.yv = -20
	self.coyotetimer = 0
end
