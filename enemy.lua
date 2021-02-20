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
	if not enemy_cache[model] then
		enemy_cache[model] = polygon.new("soda/"..model)
	end
end

function enemy:update(dt)

	local i = 1
	while i <= #enemy_data do
		
		if enemy_data[i].kind == ENEMY_GOOMBA then

			enemy_data[i].x = enemy_data[i].x - 0.25 * 60 * dt
		
		end
		
		i = i + 1
	end

end

function enemy:draw()

	local i = 1
	while i <= #enemy_data do
		
		lg.push()
		lg.translate(enemy_data[i].x, enemy_data[i].y)
		polygon.draw(enemy_cache[enemy_data[i].model])
		lg.pop()
		
		i = i + 1
	end

end