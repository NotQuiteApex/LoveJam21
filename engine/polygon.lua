import = require "engine.import"

local polygon = {}

function polygon.new(fname)
	
	return import.open(fname)

end

function polygon.toggleLayer(tbl, layer, visible)

	if tbl[layer] ~= nil then
		tbl[layer].visible = visible
	else
		print("Error: vector does not contain a shape at layer " .. layer)
	end

end

function polygon.draw(tbl)

	local i = 1
	
	while i <= #tbl do
		
		if tbl[i].visible then
			
			lg.push()
			lg.translate(tbl.x, tbl.y)
		
			local clone = tbl[i]
			
			lg.setColor(clone.color)
			
			-- Draw the shape
			if clone.kind == "polygon" then
			
				local j = 1
				while j <= #clone.raw do
				
					-- Draw triangle if the vertex[i] contains references to two other vertices (va and vb)
					if clone.raw[j].vb ~= nil then
						
						local xs, ys = tbl.xscale, tbl.yscale
						local a_loc, b_loc = clone.raw[j].va, clone.raw[j].vb
						local aa, bb, cc = clone.raw[j], clone.raw[a_loc], clone.raw[b_loc]
						lg.polygon("fill", aa.x * xs, aa.y * ys, bb.x * xs, bb.y * ys, cc.x * xs, cc.y * ys)
						
					end
					
					j = j + 1
				
				end
			
			elseif clone.kind == "ellipse" then
			
				local xs, ys = tbl.xscale, tbl.yscale
				if #clone.raw > 1 then
				
					-- Load points from raw
					local aa, bb = clone.raw[1], clone.raw[2]
					local cx, cy, cw, ch
					
					-- Calculate w/h
					cw = math.abs(aa.x - bb.x) / 2
					ch = math.abs(aa.y - bb.y) / 2
					
					-- Make x/y the points closest to the north west
					if bb.x < aa.x then cx = bb.x else cx = aa.x end
					if bb.y < aa.y then cy = bb.y else cy = aa.y end
					
					cx = cx + cw
					cy = cy + ch
					
					local cseg, cang = clone.segments, clone._angle
					
					-- Ellipse vars
					local v, k = 0, 0
					local cinc = (360 / cseg)
					local _rad, _cos, _sin = math.rad, math.cos, math.sin
					
					while k < cseg do
		
						local cx2, cy2, cx3, cy3, cxx2, cyy2, cxx3, cyy3
						cx2 = polygon.lengthdir_x(cw, _rad(v))
						cy2 = polygon.lengthdir_y(ch, _rad(v))
						cx3 = polygon.lengthdir_x(cw, _rad(v + cinc))
						cy3 = polygon.lengthdir_y(ch, _rad(v + cinc))
						
						if (cang % 360 ~= 0) then
							local cang2 = _rad(-cang)
							local cc, ss = _cos(cang2), _sin(cang2)
							cxx2 = polygon.rotateX(cx2, cy2, 0, 0, cc, ss)
							cyy2 = polygon.rotateY(cx2, cy2, 0, 0, cc, ss)
							cxx3 = polygon.rotateX(cx3, cy3, 0, 0, cc, ss)
							cyy3 = polygon.rotateY(cx3, cy3, 0, 0, cc, ss)
						else -- Do less math if not rotating
							cxx2, cyy2, cxx3, cyy3 = cx2, cy2, cx3, cy3
						end
						
						lg.polygon("fill", cx * xs, cy * ys, (cx + cxx2) * xs, (cy + cyy2) * ys, (cx + cxx3) * xs, (cy + cyy3) * ys)
						
						v = v + cinc
						k = k + 1
					
					end
				
				end
			
			end
			
			lg.pop()
		end
		-- End of drawing the shape
		
		i = i + 1
	end
	
	if tbl.bbox_visible then
		lg.setColor(c_black)
		lg.rectangle("line", 0, 0, tbl.width * tbl.xscale, tbl.height * tbl.yscale)
	end

end

function polygon.lengthdir_x(length, dir)
	return length * math.cos(dir)
end

function polygon.lengthdir_y(length, dir)
	return -length * math.sin(dir)
end

function polygon.rotateX(x, y, px, py, c, s)
	return (c * (x - px) + s * (y - py) + px)
end

function polygon.rotateY(x, y, px, py, c, s)
	return (s * (x - px) - c * (y - py) + py)
end

return polygon