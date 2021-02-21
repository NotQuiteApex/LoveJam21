io.stdout:setvbuf("no") -- sublime text console

polygon = require "engine.polygon"
input = require "engine.input"
lume = require "engine.lume"
class = require "engine.class"
bump = require "engine.bump"

require "goomba"
require "cookie"
require "enemy"
require "tile"
require "player"

lg = love.graphics
local lk = love.keyboard
local lm = love.mouse
local lw = love.window
la = love.audio

-- deleting these breaks polygon.lua
c_white = {1,1,1,1}
c_black = {0,0,0,1}

global_music_volume = 1

window_scale = 1
window_x_offset = 0
window_y_offset = 0

screen_width = default_width
screen_height = default_height

mouse_x = 0
mouse_y = 0

-- input
lalt_key = _OFF
ralt_key = _OFF
enter_key = _OFF

r_key = _OFF

up_key = _OFF
down_key = _OFF
left_key = _OFF
right_key = _OFF

escape_key = _OFF
f4_key = _OFF

font_scale = 2

ui_heart = polygon.new("soda/ui_heart.soda")
ui_heartcase = polygon.new("soda/ui_heartcase.soda")

local updateables = {"tiles", "goombas", "cookies"}

function setDefaultWindow(fs)
	lw.setMode(screen_width, screen_height, {resizable=true, minwidth=default_width, minheight=default_height, fullscreen=fs})
end

function love.load()
	
	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	
	local _, _, flags = lw.getMode()
	local res_w, res_h = lw.getDesktopDimensions( flags.display )
	font_scale = math.ceil(math.min((res_w/default_width), (res_h/default_height)))
	
	shader_mask = lg.newShader("shaders/mask.frag")
	
	math.randomseed(os.time())
	window_scale = math.floor(screen_width/default_width)
	
	-- Loading models
	font = lg.newFont("font.ttf", 18*font_scale)
	lg.setFont(font)

	bumpwrld = bump.newWorld(80)
	
	mdl_player = polygon.new("soda/THEGUY.soda")
	mdl_player_walk = polygon.new("soda/THEGUYWALKS.soda")
	mdl_player.bbox_visible = true
	mdl_player_walk.bbox_visible = true
	mdl_whip = polygon.new("soda/THEGUYARM.soda")
	
	mdl_swiper = polygon.new("soda/swiper.soda")
	mdl_strawberry = polygon.new("soda/strawberry.soda")
	mdl_goomba = polygon.new("soda/goomba.soda")
	mdl_ghost = polygon.new("soda/ghost.soda")
	mdl_cookie = polygon.new("soda/cookie.soda")
	
	mdl_tung = polygon.new("soda/tung.soda")
	
	sfx_enemy_pop = la.newSource("sfx/enemy_pop.wav", "static")
	
	music_loop = la.newSource("music/neatgame.ogg", "stream")
	music_loop:setLooping(true)
	music_loop:play()
	music_loop:setVolume(0.4)
	
	camera_x = 0--player_x + 24
	camera_y = 0--player_y + 24

	map = {
		"#        I F           I             I F          I             I F            #",
		"#  WW    I ^^^^^^^     I             I            I       G     I          WW  #",
		"#  WW    I   nnn       I       WW    I            I             I          WW  #",
		"#        I             I       WW    I   c bb c   I      c c    I              #",
		"# P      I             I             I ^^^^^^^^   I  ^^^^^^^^   I              #",
		"####     I      g      I             I^^          I             I              #",
		"# T      I             I    ^^     ^^^^      s    I     T   s   I        T     #",
		"#        I   ^^     oo I  ^^^^^      I           oI             I   oo         #",
		"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",
	}

	local m
	for y=1,9 do
		for x=1,80 do
			m = map[y]:sub(x,x)
			if m == "#" then -- brick wall
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "brick.soda", true)
			elseif m == "P" then -- player
				ent_player = player:new((x-1)*80, (y-1)*80)
			elseif m == "$" then -- floor
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "brick2.soda", true)
			elseif m == "^" then -- spikes
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "brick3.soda", true)
			elseif m == "W" then -- (W)indow
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "window.soda", false)
			elseif m == "T" then -- (T)ree
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "itsatree.soda", false)
			elseif m == "I" then -- P(I)llar
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "pillar.soda", false)
			elseif m == "G" then -- pillar (G)uy
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "pillarguy.soda", false)
			elseif m == "F" then -- (F)lag
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, "flag.soda", false)
			elseif m == "s" then -- (s)wiper
				enemy_data[#enemy_data+1] = enemy:new((x-1)*80, (y-1)*80, "swiper.soda", ENEMY_SWIPER)
			elseif m == "b" then -- straw(b)erry
				enemy_data[#enemy_data+1] = enemy:new((x-1)*80, (y-1)*80, "strawberry.soda", ENEMY_STRAWBERRY)
			elseif m == "g" then -- (g)host
				enemy_data[#enemy_data+1] = enemy:new((x-1)*80, (y-1)*80, "ghost.soda", ENEMY_GHOST)
			elseif m == "c" then -- (c)ookie
				cookies[#cookies+1] = cookie:new((x-1)*80, (y-1)*80)
			elseif m == "o" then -- g(o)omba
				goombas[#goombas+1] = goomba:new((x-1)*80, (y-1)*80)
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
				tiles[#tiles+1] = tile:new((x-1)*80, (y-1)*80, pb_name, true)
			end
		end
	end
	
	--print_r(tiles)
end

function love.draw()

	local mx, my = (love.mouse.getX() - window_x_offset) / window_scale, (love.mouse.getY() - window_y_offset) / window_scale

	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	local center_fullscreen_window = window_x_offset ~= 0 or window_y_offset ~= 0
	
	-- Push the game window over, creates black bars if the window isn't the same aspect ratio as what the game's expecting
	if center_fullscreen_window then
		lg.push()
		lg.translate(window_x_offset, window_y_offset)
	end
	
	lg.push()
	lg.scale(window_scale)
	lg.setScissor(window_x_offset, window_y_offset, default_width * window_scale, default_height * window_scale)
	
	drawGame()
	
	lg.setScissor()
	lg.pop() --screen scaling
	
	if center_fullscreen_window then
		lg.pop() --screen offset
	end

end

function drawGame()
	lg.setColor(0, 0.25, 0.25)
	lg.rectangle("fill", 0, 0, default_width, default_height)
	lg.push()
	lg.translate(0, 80)
	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	
	local rnd = (default_width/(window_scale*default_width))
	if rnd == 1 then rnd = 0.5 end
	lg.translate(lume.round(-camera_x + half_width, rnd),0) --lume.round(-camera_y + half_height, rnd)

	for i, v in ipairs(enemy_data) do
		v:draw()
	end

	for _,U in ipairs(updateables) do
		for i, v in ipairs(_G[U]) do
			v:draw()
		end
	end

	ent_player:draw()


	lg.pop()

	lg.setColor(0.5, 1/32, 75/255)
	lg.rectangle("fill", 0, 0, 1280, 80)
	
	-- TODO: simplify text stuff
	lg.setColor({1,1,1,1})
	for i=1,6 do
		lg.push()
		lg.translate(40*i, 20)
		lg.scale(3, 3)
		polygon.draw(ui_heart)
		polygon.draw(ui_heartcase)
		lg.pop()
	end
	lg.push()
	lg.scale(1/font_scale)
	local text_scale = font_scale/1
	local scoretxt = "score: " .. string.format("%06d", ent_player.score)
	lg.setColor(0,0,0)
	lg.print(scoretxt, math.floor(900*text_scale),math.floor(36*text_scale), 0, font_scale)
	lg.print(scoretxt, math.floor(904*text_scale),math.floor(32*text_scale), 0, font_scale)
	lg.setColor(1,1,1)
	lg.print(scoretxt, math.floor(900*text_scale),math.floor(32*text_scale), 0, font_scale)
	lg.pop()

end

function love.update(dt)

	-- Get mouse pos, relative to screen scale
	mouse_x, mouse_y = (love.mouse.getX() - window_x_offset) / window_scale, (love.mouse.getY() - window_y_offset) / window_scale
	
	-- update keys
	input.update()
	
	-- Toggle fullscreen with alt + enter or F4
	if input.altCombo(enter_key) or f4_key == _PRESS then
		local isfs = love.window.getFullscreen()
		
		if isfs then
			updateWindowScale(default_width, default_height)
		end
		
		setDefaultWindow(not isfs)
	end

	for i, v in ipairs(enemy_data) do
		v:update(dt)
	end

	for _,U in ipairs(updateables) do
		for i, v in lume.ripairs(_G[U]) do
			v:update(dt)
			if v.deleteself then
				v:delete()
				table.remove(_G[U], i)
			end
		end
	end

	ent_player:update(dt)
	
	-- QUIT
	if escape_key == _PRESS then
		love.event.quit()
	end

end

function updateWindowScale(w, h)

	screen_width = w
	screen_height = h
	
	window_scale = math.min((w/default_width), (h/default_height))

	window_x_offset = (screen_width  - (default_width*window_scale))/2
	window_y_offset = (screen_height - (default_height*window_scale))/2

end

function love.resize(w, h)
	updateWindowScale(w, h)
end

function hsl(h, s, l, a)
	local tbl = {}
	if s<=0 then return l/255,l/255,l/255,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end
	table.insert(tbl, (r+m))
	table.insert(tbl, (g+m))
	table.insert(tbl, (b+m))
	table.insert(tbl, a)
	return tbl
end

function setMask(r, g, b, a)
    shader_mask:send("_r", r)
    shader_mask:send("_g", g)
    shader_mask:send("_b", b)
    shader_mask:send("_a", a)
end

function print_r ( t )
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						print(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..pos..'] => "'..val..'"')
					else
						print(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,"  ")
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
end