enemy = class:new()

ENEMY_SWIPER = 1
ENEMY_STRAWBERRY = 2
ENEMY_GHOST = 3
ENEMY_COOKIE = 4
ENEMY_GOOMBA = 5

enemy_data = {}
enemy_cache = {}

function enemy:init(x, y, model, kind)
	self.x = x
	self.y = y
	self.kind = kind
	self.model = model
	self.loader = loader.step
	self.deleteself = false
	if not enemy_cache[model] then
		enemy_cache[model] = polygon.new("soda/"..model)
	end
end

function enemy:update(dt)
	if self.kind == ENEMY_GOOMBA then
		self.x = self.x - 120 * dt
	end
end

function enemy:draw()
	lg.push()
	lg.translate(self.x, self.y)
	polygon.draw(enemy_cache[self.model])
	lg.pop()
end

function enemy:delete()
	--bumpwrld:remove(self)
	-- spawn gibs?
end
