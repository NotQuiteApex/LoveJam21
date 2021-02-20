local lg = love.graphics

tile = class:new()
tiles = {}

local tilecache = {}

function tile:init(x, y, style, solid)
	self.x = x
	self.y = y
	self.style = style
	if not tilecache[style] then
		tilecache[style] = polygon.new("soda/"..style)
	end

	if solid then
	self.type = "ground"

	-- collision
	bumpwrld:add(self, x, y, 80, 80)
	else
	self.type = "decor"
	end

end

function tile:update(dt)

end

function tile:draw()
	lg.push()
	lg.translate(self.x, self.y)
	polygon.draw(tilecache[self.style])
	lg.pop()
end