local lg = love.graphics

tile = class:new()
tiles = {}

local tilecache = {}

function tile:init(x, y, style)
	self.x = x
	self.y = y
	self.style = style
	if not tilecache[style] then
		tilecache[style] = polygon.new("soda/"..style)
	end

	self.type = "ground"

	-- collision
	bumpwrld:add(self, x, y, 80, 80)
end

function tile:update(dt)

end

function tile:draw()
	lg.push()
	lg.translate(self.x, self.y)
	polygon.draw(tilecache[self.style])
	lg.pop()
end