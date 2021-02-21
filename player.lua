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
tongue_angle = 0

tung_por_x = 0
tung_por_y = 0
player_h_key = 0
player_v_key = 0

tung_timer = 0
tung_timer_max = 30

player_walk_timer = 0
player_animation_flip = false
player_walk_timer_max = 10

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
	
	if a_key == _ON or d_key == _ON then
	
		player_walk_timer = math.min(player_walk_timer + 60 * dt, player_walk_timer_max)
		
		if player_walk_timer == player_walk_timer_max then
			player_walk_timer = 0
			player_animation_flip = not player_animation_flip
		end
	
	end
	
	-- Tongue shit
	
	player:getTongueAngle()
	
	if comma_key == _PRESS and tung_timer == 0 then
		tung_timer = 1
	end
	
	if tung_timer ~= 0 and tung_timer < tung_timer_max then
		tung_timer = math.min(tung_timer + 60 * dt, tung_timer_max)
		local this_tung_angle = math.rad(tongue_angle)
		print(tongue_angle)
		tung_por_x = self.x + polygon.lengthdir_x(100, tongue_angle)
		tung_por_y = self.y + polygon.lengthdir_y(100, tongue_angle)
	end
	
	if tung_timer == tung_timer_max then
		tung_timer = 0
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
	
	--local mx, my = (love.mouse.getX() - window_x_offset + camera_x - default_width/2) / window_scale, (love.mouse.getY() - window_y_offset) / window_scale
	--tung_por_x = mx
	--tung_por_y = my
end

function player:getTongueAngle()
	
	if w_key == _PRESS then
		player_v_key = -1
	end
	
	if w_key == _ON and s_key == _RELEASE then
		player_v_key = -1
	end
	
	if s_key == _PRESS then
		player_v_key = 1
	end
	
	if s_key == _ON and w_key == _RELEASE then
		player_v_key = 1
	end
	
	if w_key == _OFF and s_key == _OFF then
		player_v_key = 0
	end
	
	if a_key == _PRESS then
		player_h_key = -1
	end
	
	if a_key == _ON and d_key == _RELEASE then
		player_h_key = -1
	end
	
	if d_key == _PRESS then
		player_h_key = 1
	end
	
	if d_key == _ON and a_key == _RELEASE then
		player_h_key = 1
	end
	
	if a_key == _OFF and d_key == _OFF then
		player_h_key = 0
	end

	local p_dir = 0
	local dir_changed = false

	-- Move up
	if player_v_key == -1 then
		p_dir = 90
		dir_changed = true
	end

	-- Move down
	if player_v_key == 1 then
		p_dir = 270
		dir_changed = true
	end

	-- Moving left
	if player_h_key == -1 then

		if player_v_key ~= 0 then

			if p_dir == 90 then
				p_dir = 135 -- Move up and left
			elseif p_dir == 270 then
				p_dir = 225 -- Move down and left
			end

		else
			p_dir = 180 -- Move left
			dir_changed = true
		end

	end

	-- Moving right
	if player_h_key == 1 then

		if player_v_key ~= 0 then

			if p_dir == 90 then
				p_dir = 45 -- Move up and right
			elseif p_dir == 270 then
				p_dir = 315 -- Move down and right
			end

		else
			p_dir = 0
			dir_changed = true
		end

	end

	if dir_changed then
		tongue_angle = p_dir
	end
end

function player:draw()

	local player_model = mdl_player
	if player_animation_flip then
		player_model = mdl_player_walk
	end
	
	lg.setColor(1,0,0,1)
	lg.circle("fill", tung_por_x, tung_por_y, 10)

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
		polygon.draw(player_model)
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
	
	-- draw tongue
	
	if tung_timer ~= 0 then
	player:drawTongue(self.x, self.y)
	end
	
end

function player:drawTongue(x, y)

	local tung_ang = lume.angle(x + 32, y + 80, tung_por_x, tung_por_y)
	
	local start_x, start_y = x + 42, y + 8
	if player_facing == -1 then
		start_x = start_x - 64 + 18
	end
	
	lg.push()
	lg.translate(start_x, start_y)
	polygon.draw(mdl_tung2)
	lg.pop()
	
	local i = 1
	local tung_count = 40
	while i < tung_count do
		
		lg.push()
		lg.translate(7, 8)
		
		local end_x, end_y = tung_por_x, tung_por_y - 60
		local my_x, my_y
		my_x = notLerp(start_x, end_x, tung_count)
		my_x = i * my_x
		my_y = notLerp(start_y, end_y, tung_count)
		my_y = i * my_y
		
		lg.translate(my_x + start_x, my_y + start_y)
		
		local new_ang = notLerp(lume.round(math.deg(tung_ang), 45)+360, math.deg(tung_ang), tung_count) --math.deg(tung_ang)/tung_count
		--print(math.deg(tung_ang/4))
		new_ang = i * new_ang
		
		lg.rotate(math.rad(new_ang))
		lg.translate(-7, -8)
		polygon.draw(mdl_tung2)
		lg.pop()
		
		i = i + 1
		
	end
	
	lg.push()
	lg.translate(7, 8)
	lg.translate(tung_por_x, tung_por_y - 60)
	
	lg.rotate(tung_ang)
	lg.translate(-7, -8)
	polygon.draw(mdl_tung)
	lg.pop()

end

--[[
	I don't know what to call this because its not linear interpolation
	This function takes a current position 'a'
	and the ending position 'b'
	and the animation length 'c'
	and then returns how much the variable should change each step
	Ex: start at -100 end at 300 in 4 steps, returns 100
]]
function notLerp(a, b, c)
	local ss = 1
	if b < a then ss = -1 end
	return ((math.abs(a - b))*ss)/c
end


function player:jump()
	self.canjump = false
	self.yv = -20
	self.coyotetimer = 0
end
