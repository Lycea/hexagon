local timer =class_base:extend()



function timer:new(check_offset)
   self.offset = check_offset
   self.__start = love.timer.getTime()
end

function timer:check()
    local time_now = love.timer.getTime()
    if time_now > self.__start + self.offset then
       self.__start =time_now
       return true
    end
    
    return nil
end




local runner_ =[[
function time_checker(trigger_time)
    
    local last_trigger = love.timer.getTime()
    print("starting ... with time: "..trigger_time)
    
    
    while true do
        local time_now = love.timer.Time()
        if last_trigger < love.timer.getTime()-trigger_time then
          love.thread.getChannel("timeout"):push(true)
          last_trigger = time_now
        end
    end
end
]]



local timer_threaded = timer:extend()


function timer_threaded:new(check_offset,cb)
    self.__cb = cb
    self.super(check_offset)
    
    self.__offset=check_offset
    
end    

function timer_threaded:start()

    self._thread = love.thread.newThread(runner_)
    self._thread:start(self.__offset)
end

function timer_threaded:check()
    return love.thread.getChannel("timeout"):pop()
end

return timer
