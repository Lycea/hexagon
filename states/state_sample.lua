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
	
	global.bgc_shader:send("center", {global.scr_width/2, global.scr_height/2})
	global.bgc_shader:send("angleOffset", {math.cos(math.rad(global.circle_offset)),
	                                        math.sin(math.rad(global.circle_offset))})
end

function sample_state:new()

    global.circle_offset = 0
    print("initialised!!")
	
	global.player ={dist=100,angle=0}
	
	global.bgc_shader = love.graphics.newShader [[
#pragma language glsl3
vec4 ColorA = vec4(0.0,0.0,1.0,1.0);
vec4 ColorB = vec4(0.0,1.0,0.0,1.0);

extern vec2 center;
extern vec2 angleOffset;
extern vec3 pointParams; // x y size
extern vec4 ring0Params; // radius with type(0 2 3 -5) rotation
extern vec4 ring1Params; // radius with type(0 2 3 -5) rotation

float distanceAA(vec2 v)
{
    return abs(v.x) + abs(v.y);
}

const vec2[3] faces = vec2[3](vec2(1, 0), vec2(cos(radians(60)), sin(radians(60))), vec2(cos(radians(120)), sin(radians(120))));

bool innerHexagon(vec2 v, out vec4 c)
{
    c = vec4(1);

    for(int i = 0; i < 3; i++)
        if(abs(dot(faces[i], v)) > 60)
            return false;

    for(int i = 0; i < 3; i++)
        if(abs(dot(faces[i], v)) > 50)
            return true;

    c = ColorA;
    return true;
}

bool hexagon(vec2 v, float angle,
             float radius, float width,
             float type, float offset) // type = [0 2 3 -5]
{
    for(int i = 0; i < 3; i++)
        if(abs(dot(faces[i], v)) > radius + width)
            return false;

    for(int i = 0; i < 3; i++)
        if(abs(dot(faces[i], v)) > radius)
        {
            float ccc = angle / radians(360) + offset / 6 + 0.5 / 6;
            return fract(ccc * max(type, 1)) < abs(type / 6.0);
        }

    return false;
}

bool point(vec2 v, vec2 p, float size)
{
    vec2 d = abs(v - p);
    return dot(d, d) < size * size; //max(d.x, d.y) < size;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
    if(point(pixel_coords, pointParams.xy, pointParams.z))
        return vec4(1);

    vec2 v = pixel_coords - center;
    v *= mat2(angleOffset.x, -angleOffset.y,
              angleOffset.y, angleOffset.x);

    vec4 c;
    if(innerHexagon(v, c))
        return c;

    float angle = atan(v.y, v.x);

    if(hexagon(v, angle, ring0Params.x, ring0Params.y, ring0Params.z, ring0Params.w))
        return vec4(1);

    if(hexagon(v, angle, ring1Params.x, ring1Params.y, ring1Params.z, ring1Params.w))
        return vec4(1);

    float sector = fract(angle / radians(120) - 0.25);
    return mix(ColorA, ColorB, float(sector > 0.5));
}]]
	
	
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
  
end



function sample_state:update()
	local px,py=get_point(global.player.angle,
		      global.player.dist,
			  global.scr_width/2,
			  global.scr_height/2)
	global.bgc_shader:send("pointParams", {px, py, 10.0})

	global.bgc_shader:send("ring0Params", {100.0, 40.0, -5.0, 0.0})
	global.bgc_shader:send("ring1Params", {200.0, 20.0, 3.0, 2.0})

    global.circle_offset=global.circle_offset-0.3
	global.bgc_shader:send("angleOffset", {math.cos(math.rad(global.circle_offset)),
	                                        math.sin(math.rad(global.circle_offset))})
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
