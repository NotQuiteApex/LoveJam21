io.stdout:setvbuf("no") -- sublime text console

polygon = require "engine.polygon"
input = require "engine.input"
lume = require "engine.lume"
class = require "engine.class"
bump = require "engine.bump"
loader = require "loader"
ui = require "ui"
deathwall = require "deathwall"

require "steamypb"
require "cannonball"
require "ghost"
require "medusa"
require "strawberry"
require "explosion"
require "gib"
require "goomba"
require "cookie"
require "tile"
require "player"
require "pickup"

default_width = 1280
default_height = 800

MODE_LOGO = 1
MODE_MENU = 2
MODE_GAME = 3
GAME_MODE = MODE_LOGO

SKIP_INTRO = false

lg = love.graphics
local lk = love.keyboard
local lm = love.mouse
local lw = love.window
la = love.audio

-- deleting these breaks polygon.lua
c_white = {1,1,1,1}
c_black = {0,0,0,1}
c_midnight = {6/255, 13/255, 69/255, 1}

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

background_x = 0

game_opacity = 255
intro_timer = 0

sleep = 0
game_over = false

updateables = {"tiles", "goombas", "cookies", "strawberrys", "medusas", "ghosts",
	"cannonballs", "steamypbs", "pickups", "explosions", "gibs"}

logo_opacity = 255
logo_timer = 0
logo_count = 0
logo_fade_in = true

ui_box = polygon.new("soda/ui_box.soda")
ui_subweapons = {
	frisbee = polygon.new("soda/ui_frisbee.soda"),
	cannon = polygon.new("soda/ui_cannon.soda"),
	steamypb = polygon.new("soda/ui_steamypb.soda"),
}

sfx_explode = la.newSource("sfx/explosion.wav", "static")
sfx_explode:setVolume(0.5)

function setDefaultWindow(fs)
	lw.setMode(screen_width, screen_height, {resizable=true, minwidth=default_width, minheight=default_height, fullscreen=fs, usehighdpi=true, usedpiscale=true})
	game_paused = true
	enter_key = _OFF
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
	mdl_whip = polygon.new("soda/THEGUYARM.soda")
	mdl_frisbee = polygon.new("soda/frisbee.soda")
	
	mdl_swiper = polygon.new("soda/swiper.soda")
	mdl_strawberry = polygon.new("soda/strawberry.soda")
	mdl_goomba = polygon.new("soda/goomba.soda")
	mdl_ghost = polygon.new("soda/ghost.soda")
	mdl_cookie = polygon.new("soda/cookie.soda")
	
	mdl_percy = polygon.new("soda/percy.soda")
	mdl_apex = polygon.new("soda/apex.soda")
	mdl_illteteka = polygon.new("soda/illteteka.soda")
	mdl_logo = polygon.new("soda/logo.soda")
	mdl_titlescreen = polygon.new("soda/titlescreen.soda")
	
	mdl_guy = polygon.new("soda/Wallstreet_Journal1.soda")
	mdl_guy2 = polygon.new("soda/Wallstreet_Journal2.soda")
	mdl_guy3 = polygon.new("soda/Wallstreet_Journal3.soda")
	
	mdl_skull = polygon.new("soda/skull.soda")
	mdl_bone = polygon.new("soda/bone.soda")
	mdl_skull2 = polygon.new("soda/skull2.soda")
	mdl_bone2 = polygon.new("soda/bone2.soda")
	mdl_edgesoul = polygon.new("soda/edgeofsoul.soda")
	
	mdl_background = polygon.new("soda/background.soda")

	ui_heart = polygon.new("soda/ui_heart.soda")
	ui_heartright = polygon.new("soda/ui_heartright.soda")
	ui_heartleft = polygon.new("soda/ui_heartleft.soda")
	ui_heartcase = polygon.new("soda/ui_heartcase.soda")
	
	sfx_enemy_pop = la.newSource("sfx/enemy_pop.wav", "static")
	sfx_die = la.newSource("sfx/death.wav", "static")
	sfx_die:setVolume(0.7)
	snd_intro = la.newSource("sfx/intro.wav", "static")
	snd_intro:setVolume(0.4)
	
	sfx_get_frisbee = la.newSource("sfx/get_frisbee.wav", "static")
	sfx_throw_frisbee = la.newSource("sfx/throw_frisbee.wav", "static")
	sfx_collect = la.newSource("sfx/collect.wav", "static")
	
	sfx_health_pickup = la.newSource("sfx/get_heart.wav", "static")
	sfx_health_pickup:setVolume(0.7)
	
	music_loop = la.newSource("music/neatgame.ogg", "stream")
	music_loop:setVolume(0.4)
	music_loop:setLooping(true)
	music_intro = la.newSource("music/dracula_titlescreen.ogg", "stream")
	music_intro:setVolume(0.4)
	music_intro:setLooping(true)
	music_end = la.newSource("music/highscore.ogg", "stream")
	music_end:setVolume(0.4)
	music_end:setLooping(true)
	
	ui.init()
	deathwall.init()
	
	if GAME_MODE == MODE_LOGO or GAME_MODE == MODE_MENU then
		music_intro:play()
	end
	
	if GAME_MODE == MODE_GAME then
		logo_opacity = 0
	end
	
	camera_x = 0
	camera_y = 0

	loader.init()
	
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
	
	if GAME_MODE == MODE_LOGO then
		drawLogo()
	elseif GAME_MODE == MODE_MENU then
		drawMenu()
	elseif GAME_MODE == MODE_GAME then
		drawGame()
	end
	
	ui.draw(0)
	
	if game_over then
		ui.drawGameOver(2)
	end
	
	lg.setScissor()
	lg.pop() --screen scaling
	
	if center_fullscreen_window then
		lg.pop() --screen offset
	end

end

function drawGame()
	--lg.setColor(0, 0.25, 0.25)
	--lg.rectangle("fill", 0, 0, default_width, default_height)
	
	lg.push()
	lg.translate(background_x, 0)
	local i, j = 0, 1
	while i <= 17 do
	
		
		while j <= 10 do
		
			lg.push()
			lg.translate( (i-1)*80, (j-1)*80)
			polygon.draw(mdl_background)
			lg.pop()
			j = j + 1
		
		end
		
		j = 1
		i = i + 1
	end
	lg.pop()
	
	lg.push()
	lg.translate(0, 80)
	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	
	local rnd = (default_width/(window_scale*default_width))
	if rnd == 1 then rnd = 0.5 end
	lg.translate(lume.round(-camera_x + half_width, rnd),0) --lume.round(-camera_y + half_height, rnd)

	for _,U in ipairs(updateables) do
		for i, v in ipairs(_G[U]) do
			v:draw()
		end
	end

	deathwall.draw()

	if not game_over then
		ent_player:draw()
	else
		ui.drawGameOver(1)
	end
	

	lg.pop()

	lg.setColor(0.5, 1/32, 75/255)
	lg.rectangle("fill", 0, 0, 1280, 80)
	
	-- TODO: simplify text stuff
	ui.drawHealth()
	lg.push()
	lg.translate(10,-5)
	lg.scale(1/font_scale)
	local text_scale = font_scale/1
	--lg.setColor(0.5,0,0.5)
	--lg.print("health: " .. ent_player.health,math.floor(32*text_scale),math.floor(32*text_scale), 0, font_scale)
	local scoretxt = "score: " .. string.format("%06d", ent_player.score)
	local dpi_scale = love.graphics.getDPIScale()

	local ts, fs = text_scale, font_scale
	if dpi_scale ~= 1 then
		ts, fs = 1, 2
	end

	lg.setColor(0,0,0)
	lg.print(scoretxt, math.floor(900*ts),math.floor(36*ts), 0, fs)
	lg.print(scoretxt, math.floor(904*ts),math.floor(32*ts), 0, fs)
	lg.setColor(1,1,1)
	lg.print(scoretxt, math.floor(900*ts),math.floor(32*ts), 0, fs)
	lg.pop()

	lg.push()
	lg.translate(-64, 0)
	lg.translate(default_width/2, 20)
	lg.scale(0.5, 0.5)
	polygon.draw(ui_box)
	if ent_player.subweapon ~= "none" then
		polygon.draw(ui_subweapons[ent_player.subweapon])
	end
	lg.pop()
	
	if not game_over then
	lg.setColor(0,0,0,game_opacity/255)
	lg.rectangle("fill", 0, 0, default_width, default_height)
	end
end

function drawLogo()

	lg.setColor(c_black)
	lg.rectangle("fill", 0, 0, default_width, default_height)
	
	if logo_count == 0 then
		lg.setColor({1,1,1,1})
		lg.push()
		lg.scale(1/font_scale)
		local text_scale = font_scale/1
		local name_scale = 2
		lg.printf("NotQuiteApex",0,520*text_scale, (default_width*font_scale)/name_scale, "center", 0 , name_scale, name_scale)
		lg.pop()
		
		lg.push()
		lg.translate(525,252)
		lg.scale(3)
		polygon.draw(mdl_apex)
		lg.pop()
	elseif logo_count == 1 then

		lg.push()
		lg.translate(348,292)
		lg.scale(0.3)
		polygon.draw(mdl_illteteka)
		lg.pop()
		
	elseif logo_count == 2 then

		lg.push()
		lg.translate(525,272)
		lg.scale(3)
		polygon.draw(mdl_percy)
		lg.pop()
		
	end
	
	lg.setColor(0,0,0,logo_opacity/255)
	lg.rectangle("fill", 0, 0, default_width, default_height)

end

function drawMenu()

	polygon.draw(mdl_titlescreen)
	lg.push()
	lg.translate(394,31)
	polygon.draw(mdl_logo)
	lg.pop()

end

function love.update(dt)

	-- Get mouse pos, relative to screen scale
	mouse_x, mouse_y = (love.mouse.getX() - window_x_offset) / window_scale, (love.mouse.getY() - window_y_offset) / window_scale
	
	-- update keys
	input.update(dt)
	
	-- Toggle fullscreen with alt + enter or F4
	if input.altCombo(enter_key) or f4_key == _PRESS then
		local isfs = love.window.getFullscreen()
		
		if isfs then
			updateWindowScale(default_width, default_height)
		end
		
		setDefaultWindow(not isfs)
	end

	ui.update(dt)
	
	if sleep == 0 then
		if not game_paused then

			if GAME_MODE == MODE_LOGO then
				updateLogo(dt)
			elseif GAME_MODE == MODE_MENU then
				updateMenu(dt)
			elseif GAME_MODE == MODE_GAME then
				updateGame(dt)
			end
		
		end
	else
		sleep = math.max(sleep - 60 * dt, 0)
	end
	
	-- QUIT
	if escape_key == _PRESS then
		love.event.quit()
	end

end

function updateGame(dt)

	if final_fade_out == false then
		game_opacity = math.max(game_opacity - 4 * 60 * dt, 0)
	end
	
	if SKIP_INTRO == false or intro_timer < 8 * 60 then
		camera_x = ent_player.x
		if game_opacity == 0 then
			intro_timer = math.min(intro_timer + 60 * dt, 8 * 60)
			if snd_intro:isPlaying() == false then
				music_loop:stop()
				snd_intro:stop()
				snd_intro:play()
			end
			
			deathwall.guy_frame_timer = math.min(deathwall.guy_frame_timer + dt * 60, 6)
			
			if deathwall.guy_frame_timer == 6 then
			
				if deathwall.guy_frame == 1 then
					deathwall.guy_frame = 2
				else
					deathwall.guy_frame = 1
				end
				
				deathwall.guy_frame_timer = 0
			
			end
			
			--deathwall.guy_frame = 3
			
		end
		
		if intro_timer == 8 * 60 or SKIP_INTRO then
			snd_intro:stop()
			music_loop:play()
			SKIP_INTRO = true
			intro_timer = 8 * 60
		end
	
	else

		for _,U in ipairs(updateables) do
			for i, v in lume.ripairs(_G[U]) do
				v:update(dt)
				if v.deleteself then
					v:delete()
					table.remove(_G[U], i)
				end
			end
		end

		deathwall.update(dt)

		if not game_over then
		ent_player:update(dt)
		end
	
	end

end

function updateLogo(dt)
	
	if logo_fade_in then
	
		logo_opacity = math.max(logo_opacity - 6 * 60 * dt, 0)
		if logo_opacity == 0 then
			logo_timer = math.min(logo_timer + 60 * dt, 50)
			if logo_timer == 50 then
				logo_fade_in = false
				logo_timer = 0
			end
		end
	
	else
	
		logo_opacity = math.min(logo_opacity + 6 * 60 * dt, 255)
		if logo_opacity == 255 then
			logo_timer = math.min(logo_timer + 60 * dt, 30)
			if logo_timer == 30 then
				logo_fade_in = true
				logo_count = logo_count + 1
				logo_timer = 0
			end
		end
	
	end
	
	if logo_count == 3 then
		GAME_MODE = MODE_MENU
	end

end

function updateMenu(dt)

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

function setMask(r, g, b, a)
    shader_mask:send("_r", r)
    shader_mask:send("_g", g)
    shader_mask:send("_b", b)
    shader_mask:send("_a", a)
end

function love.focus(f)
	if f == false then
		game_paused = true
	end
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