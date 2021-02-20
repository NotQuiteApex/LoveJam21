polygon = require "engine.polygon"
input = require "engine.input"
lume = require "engine.lume"

lg = love.graphics
lk = love.keyboard

c_black = {0,0,0,1}
c_white = {1,1,1,1}

default_width = 720
default_height = 405

WINDOW_BG = c_black
WINDOW_ASPECT_FIT = true

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

player_x = 0
player_y = 0

camera_x = 0
camera_y = 0

font_scale = 1

function setDefaultWindow(fs)
	love.window.setMode(screen_width, screen_height, {resizable=true, minwidth=default_width, minheight=default_height, fullscreen=fs})
end

function love.load()
	
	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	
	local _, _, flags = love.window.getMode()
	local res_w, res_h = love.window.getDesktopDimensions( flags.display )
	font_scale = math.ceil(math.min((res_w/default_width), (res_h/default_height)))
	
	math.randomseed(os.time())
	setDefaultWindow(false)
	love.window.setTitle("engeene")
	window_scale = math.floor(screen_width/default_width)
	
	-- Loading models
	font = love.graphics.newFont("font.ttf", 18*font_scale)
	love.graphics.setFont(font)
	
	player_x = half_width - 24
	player_y = half_height + 48
	
	test_level = polygon.new("soda/test-level.soda")
	test_level.x = half_width - 256
	test_level.y = half_height - 216
	
	ent_player = polygon.new("soda/one.soda")
	ent_player.bbox_visible = false
	
	camera_x = player_x + 24
	camera_y = player_y + 24

end

function love.draw()

	local mx, my = (love.mouse.getX() - window_x_offset) / window_scale, (love.mouse.getY() - window_y_offset) / window_scale

	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	local center_fullscreen_window = window_x_offset ~= 0 or window_y_offset ~= 0
	
	-- Push the game window over, creates black bars if the window isn't the same aspect ratio as what the game's expecting
	if center_fullscreen_window then
	lg.setColor(WINDOW_BG)
	lg.rectangle("fill", 0, 0, screen_width, screen_height)
	
	lg.push()
	lg.translate(window_x_offset, window_y_offset)
	end
	
	lg.push()
	lg.scale(window_scale)
	love.graphics.setScissor(window_x_offset, window_y_offset, default_width * window_scale, default_height * window_scale)
	
	drawGame()
	
	love.graphics.setScissor()
	lg.pop() --screen scaling
	
	if center_fullscreen_window then
	lg.pop() --screen offset
	end

end

function drawGame()

	lg.setColor({1,0,0,1})
	lg.rectangle("fill", 0, 0, default_width, default_height)
	
	lg.push()
	local half_width, half_height = default_width / 2, math.floor(default_height / 2)
	
	local rnd = (default_width/(window_scale*default_width))
	if rnd == 1 then rnd = 0.5 end
	lg.translate(lume.round(-camera_x + half_width, rnd),lume.round(-camera_y + half_height, rnd))
	
	polygon.draw(test_level)
	
	local px, py = 0, 0
	
	px = lume.round(player_x, rnd)
	py = lume.round(player_y, rnd)
	
	if player_h_release == 1 then
	lg.scale(-1,1)
	lg.translate((-px-(ent_player.width*ent_player.xscale)),py)
	else
	lg.translate(px, py)
	end
	
	polygon.draw(ent_player)
	lg.pop()
	
	lg.setColor({1,1,1,1})
	lg.push()
	lg.scale(1/font_scale)
	local text_scale = font_scale/1
	lg.print("buf buf",math.floor(default_width*text_scale) - font:getWidth("buf buf") - 96,math.floor(32*text_scale))
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
	
	-- QUIT
	if escape_key == _PRESS then
		love.event.quit()
	end

end

function updateWindowScale(w, h)

	screen_width = w
	screen_height = h
	
	window_scale = math.min((w/default_width), (h/default_height))
	if not WINDOW_ASPECT_FIT then
		window_scale = math.floor(window_scale)
	end

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