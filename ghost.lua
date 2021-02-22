local lt = love.timer

ghost = class:new()
ghosts = {}

local ghost_spr = polygon.new("soda/ghost.soda")
local throwwaitmax = 2
local throwtimermax = 0.1

function ghost:init(x, y)
	self.x = x
	self.y = y

	self.isEnemy = true

	self.loader = loader.step

	self.type = "ghost"

	self.throwstate = false
	self.throwtimer = 0
	self.throwcount = 0

	bumpwrld:add(self, self.x, self.y, 70, 160)
end

function ghost:update(dt)
	if not self.throwstate then
		self.throwtimer = self.throwtimer + dt
		if self.throwtimer > throwwaitmax then
			self.throwstate = true
			self.throwtimer = 0
		end
	else
		self.throwtimer = self.throwtimer + dt
		if self.throwtimer > throwtimermax then
			self.throwtimer = 0
			gibs[#gibs+1] = gib:new(self.x-35, self.y+15*math.sin(lt.getTime()*2.5), 
				math.pi*math.random(), -math.random(120, 60*6),-math.random(500, 1000),
				math.pi/2*math.random(-60, 60), true)
			self.throwcount = self.throwcount + 1
		end

		if self.throwcount > 4 then
			self.throwcount = 0
			self.throwtimer = 0
			self.throwstate = false
		end
	end
end

function ghost:draw()
	lg.push()
	lg.translate(self.x-35, self.y+15*math.sin(lt.getTime()*2.5))
	polygon.draw(ghost_spr)
	lg.pop()
end

function ghost:damage()
	self.deleteself = true
	sfx_enemy_pop:stop()
	sfx_enemy_pop:setPitch(0.9 + math.random(4)/10)
	sfx_enemy_pop:play()
end

function ghost:delete()
	bumpwrld:remove(self)
	if not self.deletenoscore then
		local spawndrop = lume.weightedchoice({
			[true] = 1,
			[false] = 3
		})
		if spawndrop then
			pickups[#pickups+1] = pickup:new(self.x, self.y+10)
		end
		-- spawn gibs
		for i=1,4 do
			gibs[#gibs+1] = gib:new(self.x+30, self.y,
				math.pi*math.random(), math.random(-60*6, 60*6),
				-math.random(500, 1000), math.pi/2*math.random(-60, 60))
		end

		ent_player.score = ent_player.score + 20
	end
end
