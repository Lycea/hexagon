--load up the base class and all the other classes which use the base class
local BASE = (...)..'.' 
print(BASE)
local i= BASE:find("renderer.$")
print (i)
BASE=BASE:sub(1,i-1)
require(BASE.."menue")

RenderOrder = class_base:extend()


function render_menue()
    main_menue()
end




