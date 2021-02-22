pickup = class:new()
pickups = {}

function pickup:init(x, y)
	self.x = x
	self.y = y

	self.type = "pickup"

	self.loader = loader.step

	local droptype = lume.weightedchoice({
		["health"] = 1,
		["weapon"] = 4,
	})

	if droptype == "health" then -- health pickup
		self.droptype = "health"
	else -- sub weapon pickup
		self.droptype = "weapon"
		self.weptype = lume.weightedchoice({
			["frisbee"] = 1,
			["cannon"] = 0,
			["steamypb"] = 0,
		})
	end

	bumpwrld:add(self, x, y, 35, 35)
end

function pickup:update(dt)
	self.y = self.y + 3 * 60 * dt

	local function filter(i, o)
		if o.type == "ground" then return "touch" end
		return "cross"
	end
	local ax, ay, cols, len = bumpwrld:move(self, self.x, self.y, filter)
	self.x = ax
	self.y = ay
end

function pickup:draw()
	lg.push()
	lg.translate(self.x, self.y)
	if self.droptype == "health" then
		lg.scale(3,2)
		polygon.draw(ui_heart)
		polygon.draw(ui_heartcase)
	elseif self.droptype == "weapon" then
		lg.scale(3,-2)
		polygon.draw(ui_heartcase)
	end
	lg.pop()
end

function pickup:delete()
	bumpwrld:remove(self)
	ent_player.score = ent_player.score + 20
end