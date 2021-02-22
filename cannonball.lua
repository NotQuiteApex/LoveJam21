cannonball = class:new()
cannonballs = {}

local ball_spr = polygon.new("soda/cannonball.soda")

function cannonball:init(x, y, dir)
	self.x = x
	self.y = y
	self.yv = -500

	self.dir = dir

	bumpwrld:add(self, self.x, self.y, 60, 60)
end

function cannonball:update(dt)
	self.x = self.x+ self.dir*200*dt
	self.y = self.y + self.yv*dt
	self.yv = self.yv + 10*60*dt

	local function filter(i, o)
		if o.type == "ground" then
			return "slide"
		end
		return "cross"
	end
	local ax, ay, cols, len = bumpwrld:move(self, self.x, self.y, filter)
	local o
	for i, v in ipairs(cols) do
		o = v.other
		if o.type == "ground" then
			if v.normalX ~= 0 then
				self.deleteself = true
				break
			end
			if v.normalY ~= 0 then
				if v.normalY == -1 then self.yv = -500 end
				if v.normalY == 1 then self.yv = 0 end
			end

		elseif o.isEnemy then
			o:damage(ent_player)
		end
	end

	self.x = ax
	self.y = ay
end

function cannonball:draw()
	lg.push()
	lg.translate(self.x, self.y)
	polygon.draw(ball_spr)
	lg.pop()
end

function cannonball:damage()

end

function cannonball:delete()
	bumpwrld:remove(self)

	if not game_over then
	sfx_enemy_pop:stop()
	sfx_enemy_pop:setPitch(0.4 + math.random(4)/10)
	sfx_enemy_pop:play()
	end
end
