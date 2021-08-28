local sample_state =class_base:extend()


local function get_point(angle,radius,w_off,h_off)
	local px = w_off + radius*math.sin(math.rad(angle)) 
	local py = h_off + radius*math.cos(math.rad(angle)) 
	
	return {px,py}
end

local lifetime = 0
function reset_canvas()
	global.bgc_canvas = love.graphics.newCanvas(global.scr_width,global.scr_height)
	
	love.graphics.setCanvas(global.bgc_canvas)
	love.graphics.rectangle("fill",0,0,global.scr_width,global.scr_height)
	love.graphics.setCanvas()
	
	
	global.bgc_shader:send("half_width",global.scr_width/2)
	global.bgc_shader:send("half_height",global.scr_height/2)
	global.bgc_shader:send("angle_offset",global.circle_offset)
end

local function spawn_obstacle()
	local base_dist = (global.scr_width + global.scr_height)/2 +40
	global.obstacle ={} --definition of obstacle
	
	if love.math.random(10) >5 then
		--insert simple three obstacle
		for i= (love.math.random(10)%2)+1,6,2 do
			global.obstacle[i] ={points={},distance=base_dist}
		end
	else
		local jmp_number = love.math.random(5)
		for i=1, 6 do
			if i ~= jmp_number then
				global.obstacle[i] ={points={},distance=base_dist}
			end
		end
	end
	
	recalc_obstacles()
end

function recalc_obstacles()
	
	local poly_height = 40
		
	for idx,item in pairs(global.obstacle) do
		if item.distance < 30 then
			spawn_obstacle()
			break
		end
		
		global.obstacle[idx].points={}
		
		table.insert(global.obstacle[idx].points,  get_point((idx)*60 +global.circle_offset +30,item.distance +poly_height,global.scr_width/2,global.scr_height/2)  ) --top left
		table.insert(global.obstacle[idx].points,  get_point((idx+1)*60 +global.circle_offset +30,item.distance +poly_height,global.scr_width/2,global.scr_height/2)  ) --top right
		table.insert(global.obstacle[idx].points,  get_point((idx+1)*60 +global.circle_offset +30,item.distance,global.scr_width/2,global.scr_height/2)  ) --bot right
		table.insert(global.obstacle[idx].points,  get_point((idx+0)*60 +global.circle_offset +30,item.distance,global.scr_width/2,global.scr_height/2)  ) --bot left
	end
	
end



function sample_state:new()

    global.circle_offset = 0
    print("initialised!!")
	
	global.player ={dist=100,angle=0}
	
	global.bgc_shader = love.graphics.newShader [[
		//#pragma language glsl3
        extern vec4 ColorA;
        extern vec4 ColorB;
		
		extern float half_width;
		extern float half_height;
		
		extern float angle_offset;
		
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {	
			
			
			float angle =degrees(atan(pixel_coords.y-half_height,pixel_coords.x-half_width))+angle_offset;
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
	spawn_obstacle()
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
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill",0,0,100,100)
	love.graphics.setColor(255,255,255,255)
	
	
	local p=get_point(global.player.angle +global.circle_offset,
		      global.player.dist,
			  global.scr_width/2,
			  global.scr_height/2)
	
	
	love.graphics.circle("fill",p[1],p[2],10)
  
	
  
  
	-------------------------------------
	-- draw obstacle
	
	for id,obstacle in pairs(global.obstacle) do
		local point_list ={}
		
		for _ ,point in  pairs(obstacle.points) do
			table.insert(point_list,point[1])
			table.insert(point_list,point[2])
		end
		love.graphics.polygon("fill",point_list)
	end
	
	
	love.graphics.print(lifetime,0,30)
	love.graphics.print(  math.floor((global.player.angle+30) / 60)%6 +1,0,45)
	
	local nums=""
	for key ,_ in pairs(global.obstacle) do
		nums= nums.."||"..key
	end
	love.graphics.print(nums,0,60)
	
end




function sample_state:update()
	lifetime = lifetime +love.timer.getDelta()
    global.circle_offset=global.circle_offset-0.3
	global.bgc_shader:send("angle_offset",global.circle_offset)
	
	for id,obstacle in pairs(global.obstacle) do
		global.obstacle[id].distance= global.obstacle[id].distance- 5
	end
	recalc_obstacles()
	
	
	
	local p_sector = math.floor((global.player.angle+30) / 60)%6 +1
	if global.obstacle[p_sector] ~= nil and global.obstacle[p_sector].distance <50 then
		lifetime=0
		spawn_obstacle()
	end
	
	
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