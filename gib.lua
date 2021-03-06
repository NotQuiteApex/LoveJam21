gib = class:new()
gibs = {}

local gib_spr = {}
for i=1,5 do gib_spr[i] = polygon.new("soda/giblets"..i..".soda") end

function gib:init(x, y, r, xv, yv, rv, hurt)
	self.x = x
	self.y = y

	self.r = r

	self.xv = xv
	self.yv = yv

	self.rv = rv -- rotational velocity

	self.style = math.random(#gib_spr)

	self.type = "gib"

	if hurt then
		self.isEnemy = true
		bumpwrld:add(self, self.x-10, self.y-10, 20, 20)
	end
end

function gib:update(dt)
	self.x = self.x + self.xv * dt
	self.y = self.y + self.yv * dt

	self.yv = self.yv + 50 * 60 * dt

	self.r = self.r + self.rv * dt

	if self.y > 800 then
		self.deleteself = true
	end

	if self.isEnemy then
		local function filter() return "cross" end
		bumpwrld:move(self, self.x-10, self.y-10, filter)
	end
end

function gib:draw()
	lg.push()
	lg.translate(self.x, self.y)
	lg.scale(2, 2)
	lg.rotate(self.r)
	polygon.draw(gib_spr[self.style])
	lg.pop()
end

function gib:damage() end

function gib:delete()
	if self.isEnemy then
		bumpwrld:remove(self)
	end
end
