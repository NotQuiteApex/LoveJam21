local lt = love.timer

strawberry = class:new()
strawberrys = {}

local strawb_spr = polygon.new("soda/strawberry.soda")

function strawberry:init(x, y)
	self.x = x
	self.y = y

	self.isEnemy = true

	self.loader = loader.step

	self.type = "strawberry"

	self.timeroffset = math.random()*math.pi

	bumpwrld:add(self, self.x, self.y, 40, 40)
end

function strawberry:update(dt)

end

function strawberry:draw()
	lg.push()
	lg.translate(self.x, self.y+30*math.sin(lt.getTime()*2+self.timeroffset))
	lg.scale(1.5, 1.5)
	polygon.draw(strawb_spr)
	lg.pop()
end

function strawberry:damage()
	sfx_enemy_pop:stop()
	sfx_enemy_pop:setPitch(0.9 + math.random(4)/10)
	sfx_enemy_pop:play()
	self.deleteself = true

	for i=1,4 do
		gibs[#gibs+1] = gib:new(self.x+30, self.y,
			math.pi*math.random(), math.random(-60*6, 60*6),
			-math.random(500, 1000), math.pi/2*math.random(-60, 60))
	end
end

function strawberry:delete()
	bumpwrld:remove(self)

	if not self.deletenoscore then
		local spawndrop = lume.weightedchoice({
			[true] = 1,
			[false] = 4*1.5
		})
		if spawndrop then
			pickups[#pickups+1] = pickup:new(self.x, self.y+10)
		end

		ent_player.score = ent_player.score + 5
	end
end
