local ui = {}

-- Pause menu vars

game_paused = false

ui.pause_timer = 0
ui.pause_scroll_dir = 1
ui.pause_menu = {}
pause_menu_cursor = 1

PAUSE_RESUME = 1
PAUSE_A = 2
PAUSE_B = 3
PAUSE_QUIT = 2

GO_RESTART = 1
GO_QUIT = 2
go_menu_cursor = 1
ui.go_menu = {}

detect_win_x = 0
detect_win_y = 0

pause_menu_tip_cursor = 1
ui.pause_menu_tip = {"RP_A is paused."}

main_fade_out = false
music_intro_vol = 0.4

NOT_DEAD = 0
DEATH_FLASH = 2
DEATH_FALL = 3
DEATH_CELEBRATE = 4
stages_of_death = NOT_DEAD

game_over_timer = 0
go_player_frame = true
player_angle = 0

--End pause menu vars

function ui.init()

	-- Load menus
	ui.loadPauseMenu()
	ui.loadGOMenu()
	detect_win_x, detect_win_y = love.window.getPosition()
	
end

function ui.loadPauseMenu()
	ui.addMenu("resume game", ui.pause_menu, PAUSE_RESUME)
	ui.addMenu("quit", ui.pause_menu, PAUSE_QUIT)
end

function ui.loadGOMenu()
	ui.addMenu("begin", ui.go_menu, GO_RESTART)
	ui.addMenu("quit", ui.go_menu, GO_QUIT)
end

function ui.unpause()
	input.throw_away_timer = 2
	input.throw_away = true
end

function ui.draw(rnd)

	if game_paused then
		
		lg.push()
		lg.setColor(c_black[1], c_black[2], c_black[3], (255*0.75)/255)
		lg.rectangle("fill", -10, -10, default_width+10, default_height+10)
		
		local text_scale = font_scale/1
		
		--draw menu title
		lg.setColor({1,1,1,1})
		lg.push()
		lg.scale(1/font_scale)
		local this_tip = ui.pause_menu_tip[pause_menu_tip_cursor]
		this_tip = string.gsub(this_tip, "RP_A", "Werewolf: The Achocolypse")
		lg.print(this_tip, 36*text_scale, 48*text_scale, 0, 2, 2)
		lg.pop()
		
		ui.drawMenu(pause_menu_cursor, ui.pause_menu, text_scale, 1, 2)
		
		lg.pop()
		
	end
	
	if GAME_MODE == MODE_MENU then
		lg.push()
		lg.translate(360,100)
		local text_scale = font_scale/1
		ui.drawMenu(go_menu_cursor, ui.go_menu, text_scale, 1, 2)
		lg.pop()
		
		lg.setColor({1,1,1,1})
		lg.push()
		lg.scale(1/font_scale)
		local this_tip = "a game by NotQuiteApex, Ill Teteka, and Percy_Creates"
		lg.print(this_tip, 525*text_scale, 700*text_scale, 0, 1, 1)
		lg.print("WASD to move, N to jump, M to whip, Comma to use items", 521*text_scale, 650*text_scale, 0, 1, 1)
		lg.pop()
	end
	
	lg.setColor(0,0,0,logo_opacity/255)
	lg.rectangle("fill", 0, 0, default_width, default_height)

end

function ui.drawMenu(cursor, menu, text_scale, opacity, scale_menu)

	-- draw menu options
	local i = 1
	while i <= #menu do
		lg.setColor({1,1,1,opacity})
		lg.push()
		lg.scale(1/font_scale)
		
		local append_before = ""
		local append_after = ""
		if cursor == i then append_before, append_after = "> ", " <" end
		
		lg.printf(append_before .. menu[i].text .. append_after, 0, ((128+(48 * (i-1)))*text_scale) * scale_menu, (default_width*text_scale)/scale_menu, "center", 0, scale_menu, scale_menu)
		lg.pop()
		i = i + 1
	end -- end while

end

function ui.drawHealth()

	-- Draw health
	lg.push()
	lg.translate(10, 29)
	lg.scale(2,2)

	local i = 1
	local xx, yy = 0, 0
	while i <= math.ceil(player_health_total/2) do
		xx = xx + 1
		
		lg.push()
		lg.translate(xx * 14, yy * 16)
		polygon.draw(ui_heartcase)
		lg.pop()
		
		i = i + 1
	end
	
	local i = 1
	local u = 0
	local xx, yy = 1, 0
	while i <= player_health_total do
		u = u + 1
		if u == 3 then
		
			xx = xx + 1
		
			u = 1
		end
		
		local heart_draw = ui_heartright
		if u == 1 then
			heart_draw = ui_heartleft
		end
		
		if i > ent_player.health then
		
			lg.push()
			lg.translate(xx * 14, yy * 16)
			setMask(0, 0, 0, 1)
			lg.setShader(shader_mask)
			polygon.draw(heart_draw)
			lg.setShader()
			lg.pop()
		
		else
			
			lg.push()
			lg.translate(xx * 14, yy * 16)
			polygon.draw(heart_draw)
			lg.pop()
		
		end
		
		i = i + 1
	end
	
	lg.pop()

end

function ui.update(dt)

	-- Detect if window moved and pause game
	local new_pos_x, new_pos_y = love.window.getPosition()
	if new_pos_x ~= detect_win_x or new_pos_y ~= detect_win_y then
		game_paused = true
		detect_win_x, detect_win_y = new_pos_x, new_pos_y
	end
	
	if GAME_MODE == MODE_LOGO or GAME_MODE == MODE_MENU or SKIP_INTRO == false or game_over then
		game_paused = false
	end
	
	-- Pause with enter or esc
	if GAME_MODE == MODE_GAME then
		if (enter_key == _RELEASE and game_paused == false) or escape_key == _RELEASE then
			game_paused = not game_paused
			if game_paused == false then
				ui.unpause()
			end
			
			-- These are also pause menu selection keys so they need to be cleared
			enter_key = _OFF
			escape_key = _OFF
		end
	end
	
	-- Update pause menu
	if game_paused then
	
		pause_menu_cursor = ui.updateCursor(pause_menu_cursor, #ui.pause_menu, dt)
		
		-- Action for pause menu
		if z_key == _RELEASE or enter_key == _RELEASE or space_key == _RELEASE then
			
			local get_option = ui.pause_menu[pause_menu_cursor].index
			
			if get_option == PAUSE_RESUME then
				game_paused = false
				ui.unpause()
			elseif get_option == PAUSE_QUIT then
				love.event.quit()
			end

			z_key = _OFF
			enter_key = _OFF
			space_key = _OFF
			
		end -- end action button on menu
	
	else -- end game paused
	
		-- Randomize menu tip
		pause_menu_tip_cursor = math.random(#ui.pause_menu_tip)
	
	end
	
	ui.titlescreenUpdate(dt)
	ui.gameOverUpdate(dt)

end

function ui.gameOverInit()
	stages_of_death = DEATH_FLASH
	music_loop:stop()
end

function ui.drawDead()

	local player_model = mdl_player
	if player_animation_flip then
		player_model = mdl_player_walk
	end

	local x_draw = ent_player.x-6
	if ent_player.player_facing == -1 then
	lg.push()
	x_draw = -ent_player.x-58
	lg.scale(-1,1)
	end
	
	lg.push()
	lg.translate(x_draw, ent_player.y-16)
	
	lg.translate(32, 40)
	lg.rotate(math.rad(player_angle))
	
	lg.translate(-32, -40)
	
	polygon.draw(player_model)
	lg.pop()
	
	if ent_player.player_facing == -1 then
	lg.pop()
	end

end

function ui.drawGameOver()

	if stages_of_death == DEATH_FLASH then
	
		lg.setColor(c_black)
		lg.rectangle("fill", camera_x - default_width/2, 0, default_width, default_height)
		lg.setShader(shader_mask)
		setMask(1, 1, 1, 1)
		ui.drawDead()
		lg.setShader()
		
	
	elseif stages_of_death == DEATH_FALL then
	
		lg.push()
		ui.drawDead()
		lg.pop()
	
	end

end

function ui.gameOverUpdate(dt)

	if stages_of_death == DEATH_FLASH then
	
		go_player_frame = player_animation_flip
		game_over_timer = game_over_timer + 1
		if game_over_timer == 2 then
			sleep = 10
		elseif game_over_timer > 3 and sleep == 0 then
			game_over_timer = 0
			stages_of_death = DEATH_FALL
		end
	
	elseif stages_of_death == DEATH_FALL then
		ent_player.y = ent_player.y + 4 * dt * 60
		player_angle = player_angle + 4 * dt * 60
		
		local wait_len = 60 * 3
		
		game_over_timer = math.min(game_over_timer + dt * 60, wait_len)
		
		if ent_player.y > default_height + 80 and game_over_timer >= wait_len then
			stages_of_death = DEATH_CELEBRATE
			music_end:stop()
			music_end:play()
		end
		
	end

end

function ui.titlescreenUpdate(dt)

	if GAME_MODE == MODE_MENU then
	
		if main_fade_out then
			
			logo_opacity = math.min(logo_opacity + 4 * dt * 60, 255)
			music_intro_vol = 0.4 * (1 - (logo_opacity/255))
			music_intro:setVolume(music_intro_vol)
			
			if logo_opacity == 255 then
				GAME_MODE = MODE_GAME
				music_intro:stop()
				music_intro:setVolume(0.4)
				logo_opacity = 0
				main_fade_out = false
			end
		
		else
			
			logo_opacity = math.max(logo_opacity - 4 * 60 * dt, 0)
			
			go_menu_cursor = ui.updateCursor(go_menu_cursor, #ui.go_menu, dt)
			
			-- Action for pause menu
			if z_key == _RELEASE or enter_key == _RELEASE or space_key == _RELEASE then
				
				local get_option = ui.go_menu[go_menu_cursor].index
				
				if get_option == GO_RESTART then
					main_fade_out = true
				elseif get_option == GO_QUIT then
					love.event.quit()
				end

				z_key = _OFF
				enter_key = _OFF
				space_key = _OFF
				
			end -- end action button on menu

		end -- end ghost spawn
	
	end

end

function ui.addMenu(text, menu, index)
	local tbl = {}
	tbl.text = text
	tbl.index = index
	table.insert(menu, tbl)
end

function ui.updateCursor(cursor, menu_len, dt)

	local pause_max = 20
	local pause_small = pause_max - 10
	local cursor_mult = 0

	-- Input for pause menu
	if up_key == _PRESS then
		cursor = cursor - 1
		ui.pause_scroll_dir = -1
	end
	
	if down_key == _PRESS then
		cursor = cursor + 1
		ui.pause_scroll_dir = 1
	end
	
	if cursor_dir ~= 0 then
		ui.pause_timer = math.min(ui.pause_timer + 60 * dt, pause_max)
	end
	
	if up_key == _RELEASE and down_key == _ON then
		ui.pause_scroll_dir = 1
	end
	
	if down_key == _RELEASE and up_key == _ON then
		ui.pause_scroll_dir = -1
	end
	
	if (up_key == _RELEASE or up_key == _OFF) and (down_key == _RELEASE or down_key == _OFF) then
		ui.pause_timer = 0
		cursor_mult = 0
	end
	
	if ui.pause_timer == pause_max then
		cursor_mult = 1
		ui.pause_timer = ui.pause_timer - pause_small
	end
	
	cursor = cursor + (ui.pause_scroll_dir * cursor_mult)
	
	-- Keep pause cursor in bounds
	if cursor < 1 then
		cursor = cursor + menu_len
	end
	
	if cursor > menu_len then
		cursor = cursor - menu_len
	end

	return cursor

end

return ui