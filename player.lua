local la = love.audio
local lg = love.graphics
local lk = love.keyboard

player = class:new()

whip_timer = 0
whip_max = 9
whip_freeze = 0
whip_freeze_max = 18
whip_hit_buffer = 2
whip_calc = 0
whip_angle = 0
player_health_total = 12
player_travel = 0

frisbee_equipped = true
frisbee_x = 0
frisbee_y = 0
frisbee_facing = 1
frisbee_active = false
frisbee_air = 0
frisbee_air_kick = 14
frisbee_angle = 0
frisbee_theta = 1

cannon_timer = 0
local cannon_timer_max = 5

steamypb_timer = 0
local steamypb_timer_max = 3

player_walk_timer = 0
player_animation_flip = false
player_walk_timer_max = 10

local earlyjumptimermax = 0.1
local coyotetimermax = 0.15
local iframesmax = 0.5

local sfx_hurt = {}
local sfx_whip = {}
for i=1,4 do sfx_hurt[i] = la.newSource("sfx/player_hurt"..i..".wav", "static") end
for i=1,4 do sfx_whip[i] = la.newSource("sfx/player_whip"..i..".wav", "static") end
sfx_jump = la.newSource("sfx/player_jump.wav", "static")
sfx_jump:setVolume(0.25)

function player:init(x, y)
	self.x, self.y = x, y
	self.xv, self.yv = 0, 0

	self.health = 12
	self.score = 0

	self.canjump = false
	self.earlyjump = false
	self.earlyjumptimer = 0
	self.coyotetimer = 0

	self.iframes = 0
	self.iframesactive = false
	self.iframeseffect = false
	self.hitdirection = 1

	self.subweapon = "none" -- frisbee, cannon, steamypb
	self.subequipped = true

	self.type = "player"

	self.state = "normal" -- normal, hurt, grappled

	self.appliedhurtimpulse = false

	self.player_facing = -1

	bumpwrld:add(self, x, y, 60, 60)
end

function player:update(dt)

	local ox = self.x

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
	
	-- if whip_timer == 0 then
	-- 	if self.xv < 0 then
	-- 		self.player_facing = -1
	-- 	elseif self.xv > 0 then
	-- 		self.player_facing = 1
	-- 	end
	-- end

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
			if whip_timer == 0 then self.player_facing = -1 end
			if self.xv > 0 then -- if going right
				self.xv = self.xv - dec
				if self.xv <= 0 then self.xv = -0.5 end
			elseif self.xv > -top then -- if going left
				self.xv = self.xv - acc
				if self.xv <= -top then self.xv = -top end
			end
		end

		if kr then -- if holding right
			if whip_timer == 0 then self.player_facing = 1 end
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
	
	if a_key == _ON or d_key == _ON then
	
		player_walk_timer = math.min(player_walk_timer + 60 * dt, player_walk_timer_max)
		
		if player_walk_timer == player_walk_timer_max then
			player_walk_timer = 0
			player_animation_flip = not player_animation_flip
		end
	
	end

	-- gravity!
	self.yv = self.yv + 30 * dt
	self.y = self.y + self.yv * 30 * dt

	-- ##################
	-- Collision handling
	-- ##################
	-- collision filter, for determining how things should react on contact
	local function filter(i, o)
		if o.type == "ground" then
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
			self:damage(v, o)
		elseif o.type == "pickup" then
			if o.droptype == "health" then
				o.deleteself = true
				self.health = math.min(self.health + 1, player_health_total)
				sfx_health_pickup:stop()
				sfx_health_pickup:play()
				sfx_health_pickup:setPitch(0.9+math.random(3)/10)
			elseif o.droptype == "weapon" then
				self.subweapon = o.weptype
				self.subequipped = true
				
				if o.weptype == "frisbee" then
					sfx_get_frisbee:stop()
					sfx_get_frisbee:setPitch(1 + math.random()*0.1 - 0.05)
					sfx_get_frisbee:play()
				else
					sfx_collect:stop()
					sfx_collect:setPitch(1 + math.random()*0.1 - 0.05)
					sfx_collect:play()
				end
				
				o.deleteself = true
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
		for k = 1, #sfx_whip do sfx_whip[k]:stop() end
		local sfx = math.random(#sfx_whip)
		sfx_whip[sfx]:setPitch(1 + math.random()*0.1 - 0.05)
		sfx_whip[sfx]:play()
	end

	-- collision items and filter
	local len, items = 0
	local function filter(i)
		return i.isEnemy == true
	end
	
	if whip_timer ~= 0 then
		if whip_timer < whip_max / 2 then
			whip_timer = math.min(whip_timer + dt * 30, whip_max)

			-- grab backwhip collisions here
			if self.player_facing == -1 then
				items, len = bumpwrld:queryRect(self.x +38-4, self.y - 42, 58, 58)
			else
				items, len = bumpwrld:queryRect(self.x - 38, self.y - 42, 58, 58)
			end
		else
			whip_timer = math.min(whip_timer + dt * 60, whip_max)

			-- grab frontwhip collisions here
			if self.player_facing == -1 then
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
		if whip_freeze < whip_freeze_max/2 then
			if self.player_facing == -1 then
				items, len = bumpwrld:queryRect(self.x -200+42, self.y + 16, 200, 16)
			else
				items, len = bumpwrld:queryRect(self.x + 12, self.y + 16, 200, 16)
			end
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
			if v.damage and v.type ~= "player" then
				v:damage(self)
			end
		end
	end
	
	-- use subweapon
	if self.subequipped then
		if comma_key == _PRESS then
			if self.subweapon == "frisbee" then
			
				sfx_throw_frisbee:stop()
				sfx_throw_frisbee:setPitch(1 + math.random()*0.1 - 0.05)
				sfx_throw_frisbee:play()
			
				self.subequipped = false
				
				local push_frisbee_x = 70
				
				if self.player_facing == -1 then
					push_frisbee_x = -70 + 10
				end
				
				frisbee_x = self.x - 10 + push_frisbee_x
				frisbee_y = self.y + 10
				frisbee_facing = self.player_facing
				frisbee_active = true
				frisbee_air = 1
				frisbee_angle = 0
			elseif self.subweapon == "cannon" then
			
				sfx_throw_frisbee:stop()
				sfx_throw_frisbee:setPitch(1 + math.random()*0.1 - 0.05)
				sfx_throw_frisbee:play()
			
				cannonballs[#cannonballs+1] = cannonball:new(self.x+30, self.y-40, self.player_facing)
				self.subequipped = false
			elseif self.subweapon == "steamypb" then
				
				sfx_throw_frisbee:stop()
				sfx_throw_frisbee:setPitch(1 + math.random()*0.1 - 0.05)
				sfx_throw_frisbee:play()
			
				steamypbs[#steamypbs+1] = steamypb:new(self.x+30, self.y-40, self.player_facing)
				self.subequipped = false
			end
		end
	end

	if not self.subequipped then
		if self.subweapon == "frisbee" then
			if frisbee_air <= frisbee_air_kick then
				frisbee_air = math.min(frisbee_air + dt * 60, frisbee_air_kick)
			end
			
			if frisbee_theta == 1 then
				frisbee_angle = math.min(frisbee_angle + 60 * 3 * dt, 39)
				if frisbee_angle == 39 then
					frisbee_theta = -1
				end
			elseif frisbee_theta == -1 then
				frisbee_angle = math.max(frisbee_angle - 60 * dt, 0)
			end
				
			local fris_spd = 11
				
			if frisbee_angle == 0 then
				frisbee_y = frisbee_y + 0.1 * 60 * dt
				
				if frisbee_x - 20 > self.x + default_width/2 then
					frisbee_facing = -1
				elseif frisbee_x + 100 < self.x - default_width/2 then
					frisbee_facing = 1
				end
				
				fris_spd = 13
				
			end
			
			local actual_spd = (frisbee_air/frisbee_air_kick) * fris_spd
			frisbee_x = frisbee_x + polygon.lengthdir_x(fris_spd * frisbee_facing, math.rad(frisbee_angle)) * dt * 60
			frisbee_y = frisbee_y + polygon.lengthdir_y(fris_spd, math.rad(frisbee_angle)) * 60 * dt + (frisbee_angle==0 and 60*dt or 0)
			
			local dist = lume.distance(self.x, self.y, frisbee_x, frisbee_y)
			if (frisbee_angle == 0 and dist < 60) or frisbee_y > 800 then
				frisbee_active = false
				frisbee_air = 0
				frisbee_angle = 0
				frisbee_theta = 1
				self.subequipped = true
				
				sfx_get_frisbee:stop()
				sfx_get_frisbee:setPitch(1 + math.random()*0.1 - 0.05)
				sfx_get_frisbee:play()
			end
		
			local function filter(i) return i.isEnemy == true end
			local items, len = bumpwrld:queryRect(frisbee_x, frisbee_y, 80, 26, filter)
			for i, v in ipairs(items) do
				if v.damage and v.type ~= "player" then
					v:damage(self)
				end
			end
		elseif self.subweapon == "cannon" then
			cannon_timer = cannon_timer + dt
			if cannon_timer > cannon_timer_max then
				self.subequipped = true
				cannon_timer = 0
			end
		elseif self.subweapon == "steamypb" then
			steamypb_timer = steamypb_timer + dt
			if steamypb_timer > steamypb_timer_max then
				self.subequipped = true
				steamypb_timer = 0
			end
		end
	end
	
	if self.y > default_height then
		player:forceKill()
	end
	
	if self.x + 40 < deathwall.x + 400 then
		player:forceKill()
	end
	
	-- This moves the endless level
	local x_change = self.x - ox
	loader.spawn_after = loader.spawn_after - x_change
	background_x = -camera_x
	player_travel = player_travel + x_change
	while background_x >= 81 do
		background_x = background_x - 80
	end
	
	while background_x <= -81 do
		background_x = background_x + 80
	end
	
	if loader.spawn_after <= 0 then
		loader.loadTemplate()
	end
	
end

function player:draw()

	local player_model = mdl_player
	if player_animation_flip then
		player_model = mdl_player_walk
	end

	local x_draw = self.x-6
	if self.player_facing == -1 then
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
		polygon.draw(player_model)
	end
	lg.pop()
	
	if self.player_facing == -1 then
	lg.pop()
	end
	
	if frisbee_active then
	lg.push()
	
		lg.translate(frisbee_x, frisbee_y)
		polygon.draw(mdl_frisbee)
	
	lg.pop()
	end
end

function player:jump()
	if self.state ~= "normal" then
		return
	end

	sfx_jump:stop()
	sfx_jump:setPitch(1.4 + math.random(10)/10)
	sfx_jump:play()
	self.canjump = false
	self.yv = -20
	self.coyotetimer = 0
end

function player:forceKill()

	self.health = 0
	ent_player.health = 0
	for k = 1, #sfx_hurt do sfx_hurt[k]:stop() end
	local sfx = math.random(#sfx_hurt)
	sfx_hurt[sfx]:setPitch(1 + math.random()*0.1 - 0.05)
	sfx_hurt[sfx]:play()
	
	if self.health == 0 then
		ui.gameOverInit()
		game_over = true
	end

end

function player:damage(v, o)
	if self.state ~= "hurt" and not self.iframesactive then
		self.xv = 0
		self.yv = 0
		self.state = "hurt"
		self.health = math.max(self.health - 1, 0)
		
		if v.normalX == 0 and o and o.xv then
			self.hitdirection = lume.sign(o.xv)
		elseif v.normalX == 0 then
			self.hitdirection = -self.player_facing
		elseif v.normalX then
			self.hitdirection = v.normalX
		else
			self.hitdirection = lume.sign(self.x - v.x)
		end
		for k = 1, #sfx_hurt do sfx_hurt[k]:stop() end
		local sfx = math.random(#sfx_hurt)
		sfx_hurt[sfx]:setPitch(1 + math.random()*0.1 - 0.05)
		sfx_hurt[sfx]:play()
		
		if self.health == 0 then
			ui.gameOverInit()
			game_over = true
		end
	end
end
