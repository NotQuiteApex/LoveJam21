gib = class:new()
gibs = {}

local gib_spr = {}
for i=1,5 do gib_spr[i] = polygon.new("soda/giblets"..i..".soda") end

function gib:init(x, y, r, xv, yv, rv)
	self.x = x
	self.y = y

	self.r = r

	self.xv = xv
	self.yv = yv

	self.rv = rv -- rotational velocity

	self.style = math.random(#gib_spr)

	self.type = "gib"
end

function gib:update(dt)
	self.x = self.x + self.xv * dt
	self.y = self.y + self.yv * dt

	self.yv = self.yv + 50 * 60 * dt

	self.r = self.r + self.rv * dt

	if self.y > 1300 then
		self.deleteself = true
		print("delyeet")
	end
end

function gib:draw()
	lg.push()
	lg.translate(self.x, self.y)
	lg.rotate(self.r)
	polygon.draw(gib_spr[self.style])
	lg.pop()
end

function gib:delete()

end
