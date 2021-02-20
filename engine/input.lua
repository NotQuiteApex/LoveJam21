local input = {}

_OFF = 0
_ON = 1
_PRESS = 2
_RELEASE = 3

mouse_switch = _OFF

function input.combo(a, b)
	return (a == _ON and b == _PRESS) or (a == _PRESS and b == _ON) or (a == _PRESS and b == _PRESS)
end

function input.ctrlCombo(a)
	return input.combo(lctrl_key, a) or input.combo(rctrl_key, a)
end

function input.altCombo(a)
	return input.combo(lalt_key, a) or input.combo(ralt_key, a)
end

function input.pullSwitch(a, b)

	local output = b

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

	return output

end

function input.update(dt)

	mouse_switch = input.pullSwitch(love.mouse.isDown(1), mouse_switch)
	
	r_key = input.pullSwitch(love.keyboard.isDown("r"), r_key)
	lalt_key = input.pullSwitch(love.keyboard.isDown("lalt"), lalt_key)
	ralt_key = input.pullSwitch(love.keyboard.isDown("ralt"), ralt_key)
	enter_key = input.pullSwitch(love.keyboard.isDown("return"), enter_key)
	escape_key = input.pullSwitch(love.keyboard.isDown("escape"), escape_key)
	f4_key = input.pullSwitch(love.keyboard.isDown("f4"), f4_key)
	
	up_key = input.pullSwitch(love.keyboard.isDown("up"), up_key)
	down_key = input.pullSwitch(love.keyboard.isDown("down"), down_key)
	left_key = input.pullSwitch(love.keyboard.isDown("left"), left_key)
	right_key = input.pullSwitch(love.keyboard.isDown("right"), right_key)
	
end

return input
