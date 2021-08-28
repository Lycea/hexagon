local sample_state =class_base:extend()


local function get_point(angle,radius,w_off,h_off)
	local px = w_off + radius*math.sin(math.rad(angle)) 
	local py = h_off + radius*math.cos(math.rad(angle)) 
	
	return px,py
end


function reset_canvas()
	global.bgc_canvas = love.graphics.newCanvas(global.scr_width,global.scr_height)
	--function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
	--degrees
	
	love.graphics.setCanvas(global.bgc_canvas)
	love.graphics.rectangle("fill",0,0,global.scr_width,global.scr_height)
	love.graphics.setCanvas()
	
	
	global.bgc_shader:send("half_width",global.scr_width/2)
	global.bgc_shader:send("half_height",global.scr_height/2)
	global.bgc_shader:send("angle_offset",global.circle_offset)
end

function sample_state:new()

    global.circle_offset = 0
    print("initialised!!")
	
	global.player ={dist=100,angle=0}
	
	global.bgc_shader = love.graphics.newShader [[
        extern vec4 ColorA;
        extern vec4 ColorB;
		
		extern float half_width;
		extern float half_height;
		
		extern float angle_offset;
		
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {	
			
			
			float angle =degrees(atan(pixel_coords.x-half_width,pixel_coords.y-half_height))+angle_offset;
			float sector = fract(angle/120);
			
			if(sector >0.5)
			{
				return vec4(0.0,0.0,1.0,1.0);
			}
			else
			{
				return vec4(0.0,1.0,0.0,1.0);
			}
			
            
        }
    ]]
	
	
	reset_canvas()
	
	
end




function sample_state:startup()

end





function sample_state:draw()
	
	
	-------------------------------------
	-- draw the lines / rectangles
	
	love.graphics.setShader(global.bgc_shader)
	love.graphics.draw(global.bgc_canvas,0,0)
	love.graphics.setShader()
	
	
	-------------------------------------
	--get the player position and draw it
	
	local px,py=get_point(global.player.angle,
		      global.player.dist,
			  global.scr_width/2,
			  global.scr_height/2)
	
	
	love.graphics.rectangle("fill",px,py,20,20)
  
end



function sample_state:update()
    global.circle_offset=global.circle_offset-0.3
	global.bgc_shader:send("angle_offset",global.circle_offset)
end

function sample_state:handle_action(action)
	
	if action["resize"] then
		reset_canvas()
	end
	if action["move"] and game_state==GameStates.PLAYING then
		global.player.angle=global.player.angle+action["move"][1]
		
	end
        
        
	if action["exit"]  then
		
		if exit_timer +0.3 < love.timer.getTime() then
			love.event.quit()
		end
		
	end
end


function sample_state:shutdown()
    
end





return sample_state()