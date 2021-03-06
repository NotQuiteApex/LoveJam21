local lk = love.keyboard

local input = {}

-- used when pausing the game
input.throw_away = false
input.throw_away_timer = 0

_OFF = 0
_ON = 1
_PRESS = 2
_RELEASE = 3

mouse_switch = _OFF

r_key = _OFF
n_key = _OFF
m_key = _OFF
lalt_key = _OFF
ralt_key = _OFF
enter_key = _OFF
escape_key = _OFF
f4_key = _OFF
w_key = _OFF
a_key = _OFF
s_key = _OFF
d_key = _OFF
comma_key = _OFF

up_key = _OFF
down_key = _OFF
left_key = _OFF
right_key = _OFF

function input.combo(a, b)
	return (a == _ON and b == _PRESS) or (a == _PRESS and b == _ON) or (a == _PRESS and b == _PRESS)
end

function input.ctrlCombo(a)
	return input.combo(lctrl_key, a) or input.combo(rctrl_key, a)
end

function input.altCombo(a)
	return input.combo(lalt_key, a) or input.combo(ralt_key, a)
end

function input.pullSwitch(a, b, ignore)

	local output = b

	if input.throw_away and not ignore then
		output = _OFF
	else
	
		-- Main input code
		if a then

			if b == _OFF or b == _RELEASE then
				output = _PRESS
			elseif b == _PRESS then
				output = _ON
			end

		else

			if b == _ON or b == _PRESS then
				output = _RELEASE
			elseif b == _RELEASE then
				output = _OFF
			end

		end
		-- End main input code
	
	end

	return output

end

function input.update(dt)

	input.throw_away_timer = math.max(input.throw_away_timer - 60 * dt, 0)
	if input.throw_away_timer == 0 then
		input.throw_away = false
	end

	mouse_switch = input.pullSwitch(love.mouse.isDown(1), mouse_switch)
	
	comma_key = input.pullSwitch(lk.isDown(","), comma_key)
	w_key = input.pullSwitch(lk.isDown("w"), w_key)
	a_key = input.pullSwitch(lk.isDown("a"), a_key)
	s_key = input.pullSwitch(lk.isDown("s"), s_key)
	d_key = input.pullSwitch(lk.isDown("d"), d_key)
	r_key = input.pullSwitch(lk.isDown("r"), r_key)
	n_key = input.pullSwitch(lk.isDown("n"), n_key)
	m_key = input.pullSwitch(lk.isDown("m"), m_key)
	lalt_key = input.pullSwitch(lk.isDown("lalt"), lalt_key)
	ralt_key = input.pullSwitch(lk.isDown("ralt"), ralt_key)
	enter_key = input.pullSwitch(lk.isDown("return"), enter_key)
	escape_key = input.pullSwitch(lk.isDown("escape"), escape_key)
	f4_key = input.pullSwitch(lk.isDown("f4"), f4_key)
	
	up_key = input.pullSwitch(lk.isDown("up"), up_key)
	down_key = input.pullSwitch(lk.isDown("down"), down_key)
	left_key = input.pullSwitch(lk.isDown("left"), left_key)
	right_key = input.pullSwitch(lk.isDown("right"), right_key)
	
end

return input
