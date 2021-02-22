local deathwall = {}

deathwall.x = -400
deathwall.w = 400
deathwall.h = 720

deathwall.delay = 0
deathwall.start = 60 * 3

deathwall.data = {}

deathwall.color = {252/255, 58/255, 0/255, 1}

deathwall.speed = 1
deathwall.temp_speed = 0

DEATHWALL_SPEED_INCREASE = 0.6
DEATHWALL_MAX_SPEED = 9
DEATHWALL_TEMP_SPEEDUP = 33
DEATHWALL_TEMP_DECEL = 1.4

deathwall.guy_frame = 3
deathwall.guy_frame_timer = 0

function deathwall.init()

	local i = 1
	while i < 200 do
	
		local e = math.random(4)
		local x = 0 --math.random(default_width)
		local weight_x = math.random(10)
		
		if weight_x < 5 then
			x = 3*default_width/4 + math.random(default_width/4)
		elseif weight_x < 9 then
			x = default_width/2 + math.random(default_width/2)
		else
			x = math.random(default_width)
		end
		
		x = x - math.random(50)
		
		local y = math.random(deathwall.h)
		local a = math.random(360)
		deathwall.add(e, x, y, math.rad(a))
		i = i + 1
	
	end

end

function deathwall.add(kind, x, y, angle)

	local tbl = {}
	tbl.kind = kind
	tbl.x = x
	tbl.y = y
	tbl.angle = angle
	table.insert(deathwall.data, tbl)

end

function deathwall.update(dt)

	if not game_over then
	
	if deathwall.delay ~= deathwall.start then
		deathwall.delay = math.min(deathwall.delay + 60 * dt, deathwall.start)
	else
		deathwall.x = deathwall.x + (deathwall.speed + deathwall.temp_speed) * dt * 60
	end
	
	deathwall.temp_speed = math.max(deathwall.temp_speed - DEATHWALL_TEMP_DECEL * 60 * dt, 0)
	
	end
	
	deathwall.guy_frame_timer = math.min(deathwall.guy_frame_timer + dt * 60, 10)
	if deathwall.guy_frame_timer == 10 then
		if deathwall.guy_frame == 2 then
			deathwall.guy_frame = 1
		else
			deathwall.guy_frame = 2
		end
		deathwall.guy_frame_timer = 0
	end
	
	--print( (deathwall.speed + deathwall.temp_speed))

end

function deathwall.draw()

	lg.setColor(deathwall.color)
	local death_edge = math.min(deathwall.x, camera_x - default_width/2)
	local de_bonus = 0
	
	if deathwall.x > (camera_x - default_width/2) then
		de_bonus = deathwall.x - (camera_x - default_width/2)
	end
	
	lg.rectangle("fill",death_edge,0,deathwall.w + de_bonus,deathwall.h)
	
	lg.push()
	lg.translate(death_edge + deathwall.w + de_bonus,0)
	polygon.draw(mdl_edgesoul)
	lg.pop()
	
	local i = 1
	while i <= #deathwall.data do
	
		lg.push()
		lg.translate(deathwall.data[i].x - default_width + death_edge + deathwall.w + de_bonus, deathwall.data[i].y)
		lg.translate(40,40)
		lg.rotate(deathwall.data[i].angle)
		lg.translate(-40,-40)
		
		if deathwall.data[i].kind == 1 then
			polygon.draw(mdl_skull)
		elseif deathwall.data[i].kind == 2 then
			polygon.draw(mdl_bone)
		elseif deathwall.data[i].kind == 3 then
			polygon.draw(mdl_bone2)
		elseif deathwall.data[i].kind == 4 then
			polygon.draw(mdl_skull2)
		end
		
		lg.pop()
	
		i = i + 1
	end
	
	lg.push()
	lg.translate(death_edge + deathwall.w + de_bonus - 30, 20)
	lg.scale(3,3)
	if deathwall.guy_frame == 1 then
		polygon.draw(mdl_guy)
	elseif deathwall.guy_frame == 2 then
		polygon.draw(mdl_guy2)
	elseif deathwall.guy_frame == 3 then
		polygon.draw(mdl_guy3)
	end
	lg.pop()

end

return deathwall