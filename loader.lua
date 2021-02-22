local loader = {}

loader.temp_map = {}
loader.step = 1
loader.kill_next = -2
loader.spawn_after = 100
loader.x = 0
loader.spawn_remainder = 0
loader.spawn_after_static = 0

function loader.init()

	loader.temp_map = {
		"#        I F           I             ",
		"#  WW    I             I             ",
		"#  WW    I             I       WW    ",
		"#        I             I       WW    ",
		"# P      I             I             ",
		"####     I             I      mm     ",
		"# T      I             I             ",
		"#        I   ##     oo I  ^^^^^      ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}
	
	loader.load()
	deathwall.x = -400

end

function loader.loadTemplate()
	
	local x = math.random(3)
	
	loader.step = loader.step + 1
	
	if x == 1 then
		loader.template1()
	elseif x == 2 then
		loader.template2()
	elseif x == 3 then
		loader.template3()
	elseif x == 4 then
		loader.template3()
	elseif x == 5 then
		loader.template3()
	elseif x == 6 then
		loader.template3()
	elseif x == 7 then
		loader.template3()
	end
	
	loader.load()
	
end

function loader.template1()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end


function loader.template2()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"        g                            ",
		"                                     ",
		"       ########                      ",
		"    o                                ",
		"######                               ",
		"                 $$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.template3()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.template4()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.template5()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.template6()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.template7()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.template8()

	loader.temp_map = {
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"                                     ",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

end

function loader.load()

	local map = loader.temp_map
	local m
	for y=1,#map do
		for x=1,#map[1] do
		
			local map_spawn_x, map_spawn_y
			map_spawn_x = loader.x + (x-1)*80
			map_spawn_y = (y-1)*80
		
			m = map[y]:sub(x,x)
			if m == "#" then -- brick wall
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "brick.soda", true)
			elseif m == "P" then -- player
				ent_player = player:new(map_spawn_x, map_spawn_y + 20)
			elseif m == "$" then -- floor
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "brick2.soda", true)
			elseif m == "^" then -- spikes
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "brick3.soda", true)
			elseif m == "W" then -- (W)indow
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "window.soda", false)
			elseif m == "T" then -- (T)ree
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "itsatree.soda", false)
			elseif m == "I" then -- P(I)llar
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "pillar.soda", false)
			elseif m == "G" then -- pillar (G)uy
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "pillarguy.soda", false)
			elseif m == "F" then -- (F)lag
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "flag.soda", false)
			elseif m == "u" then -- p(u)rple brick
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "purpbrick.soda", false)
			elseif m == "C" then -- moon (C)
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, "purpbrick.soda", false)
			elseif m == "s" then -- (s)wiper
				--enemy_data[#enemy_data+1] = enemy:new(map_spawn_x, map_spawn_y, "swiper.soda", ENEMY_SWIPER)
			elseif m == "b" then -- straw(b)erry
				strawberrys[#strawberrys+1] = strawberry:new(map_spawn_x, map_spawn_y)
			elseif m == "g" then -- (g)host
				ghosts[#ghosts+1] = ghost:new(map_spawn_x, map_spawn_y)
			elseif m == "c" then -- (c)ookie
				cookies[#cookies+1] = cookie:new(map_spawn_x, map_spawn_y)
			elseif m == "o" then -- g(o)omba
				goombas[#goombas+1] = goomba:new(map_spawn_x, map_spawn_y)
			elseif m == "m" then -- g(o)omba
				medusas[#medusas+1] = medusa:new(map_spawn_x, map_spawn_y)
			elseif m == "n" then -- pea(n)ut butter
				local choose = math.random(4)
				local pb_name = "pb.soda"
				if choose == 2 then
					pb_name = "pb2.soda"
				elseif choose == 3 then
					pb_name = "pb3.soda"
				elseif choose == 4 then
					pb_name = "pb4.soda"
				end
				tiles[#tiles+1] = tile:new(map_spawn_x, map_spawn_y, pb_name, true)
			end
		end
	end
	
	loader.spawn_after = (math.floor(#map[1]) * 80) / 2
	local old_rem = loader.spawn_remainder
	loader.spawn_remainder = loader.spawn_after

	loader.spawn_after = loader.spawn_after + old_rem
	
	loader.x = loader.x + (#map[1] * 80)
	
	for _,U in ipairs(updateables) do
		for i, v in ipairs(_G[U]) do
			if v.loader == loader.kill_next then
				v.deleteself = true
				v.deletenoscore = true
			end
		end
	end
	
	deathwall.x = math.max(loader.spawn_after_static - 1000, deathwall.x)
	deathwall.speed = math.min(deathwall.speed + DEATHWALL_SPEED_INCREASE, DEATHWALL_MAX_SPEED)
	deathwall.temp_speed = DEATHWALL_TEMP_SPEEDUP
	
	loader.spawn_after_static = loader.spawn_after_static + loader.spawn_after
	
	loader.kill_next = loader.kill_next + 1
	
end

return loader