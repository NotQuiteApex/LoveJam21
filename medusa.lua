local lt = love.timer

medusa = class:new()
medusas = {}

local medusa_spr = polygon.new("soda/blob.soda")

function medusa:init(x, y)
	self.x = x
	self.y = y

	self.sx = x
	self.sy = y

	self.offset = math.pi*math.random()

	self.range = math.random(80, 200)
	self.multiplier = 5+math.random()

	self.isEnemy = true

	self.loader = loader.step

	self.type = "medusa"

	bumpwrld:add(self, self.x, self.y, 75, 75)
end

function medusa:update(dt)
	self.x = self.x - 350 * dt
	self.y = self.sy + self.range * math.sin(lt.getTime()*self.multiplier+self.offset)

	-- "collision"
	local function filter()
		return "cross"
	end
	local ax, ay, cols, len = bumpwrld:move(self, self.x, self.y, filter)
end

function medusa:draw()
	lg.push()
	lg.translate(self.x, self.y)
	polygon.draw(medusa_spr)
	lg.pop()
end

function medusa:damage()
	sfx_enemy_pop:stop()
	sfx_enemy_pop:setPitch(0.9 + math.random(4)/10)
	sfx_enemy_pop:play()
	self.deleteself = true
end

function medusa:delete()
	bumpwrld:remove(self)
	local spawndrop = lume.weightedchoice({
		[true] = 1,
		[false] = 5*2
	})
	if spawndrop then
		pickups[#pickups+1] = pickup:new(self.x, self.y+10)
	end
	-- spawn gibs
	for i=1,3 do
		gibs[#gibs+1] = gib:new(self.x+30, self.y,
			math.pi*math.random(), math.random(-60*6, 60*6),
			-math.random(500, 1000), math.pi/2*math.random(-60, 60))
	end
	ent_player.score = ent_player.score + 10
end
