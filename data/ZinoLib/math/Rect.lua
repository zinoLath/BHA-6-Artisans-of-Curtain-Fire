local Rect = class()
local M = Rect
--local Vector = require("ZinoLib.math.Vector")
require("math")
local special_properties = {
    l = "getL",
    r = "getR",
    t = "getT",
    b = "getB",
    lt = "getLT",
    rt = "getRT",
    rb = "getRB",
    lb = "getLB",
    ratio = "getRatio"
}
function M.__index(t, k)
    if special_properties[k] then
        return M[special_properties[k]](t)
    end
    return rawget(M,k)
end
function M:__tostring()
    return string.format("rect: x=%d, y=%d, w=%d, h=%d",self.x,self.y,self.w,self.h)
end
M.__type = "rect"
function M:init(x,y,w,h)
    self.x, self.y, self.w, self.h = x,y,w,h
end
function M.fromBounds(l,r,t,b)
    local x, y = (l + r)/2, (t + b)/2
    local w, h = (r - l), (t - b)
    return Rect(x, y, w, h)
end
function M:getVectorList()
    return self.lt, self.rt, self.rb, self.lb
end
function M:isInPoint(x,y)
    if x and not y then
        x = x.x; y = x.y
    end
    return (x > self.l and x < self.r) and (y > self.b and y < self.t)
end
function M:getPointInside(x,y)
    return Vector(math.clamp(x))
end
function M:addPosition(x,y)
    if y then
        x = Vector(x,y)
    end
    self.x = self.x + x.x
    self.y = self.y + x.y
    return self
end
function M:addedPosittion(x,y)
    return self:clone():addPosition(x,y)
end
function M:addSize(w,h)
    if h then
        w = Vector(w,h)
    end
    self.w = self.w + w.x
    self.h = self.h + w.y
    return self
end
function M:addedSize(x,y)
    return self:clone():addSize(x,y)
end
function M:multiplySize(w,h)
    if h then
        w = Vector(w,h)
    end
    self.w = self.w * w.x
    self.h = self.h * w.y
    return self
end
function M:multipliedSize(x,y)
    return self:clone():multiplySize(x,y)
end
function M:clone()
    return Rect(self.x, self.y, self.w, self.h)
end

function M:transformPoint(point,dstrect,flipY)
    local b,t = self.b, self.t
    if flipY then
        b, t = self.t, self.b
    end
    local _x = math.map(point.x, self.l, self.r, dstrect.l, dstrect.r)
    local _y = math.map(point.y, b, t, dstrect.b, dstrect.t)
    return Vector(_x,_y)
end
function M:getL() return self.x - self.w/2 end
function M:getR() return self.x + self.w/2 end
function M:getB() return self.y - self.h/2 end
function M:getT() return self.y + self.h/2 end
function M:getLT() return Vector(self.l,self.t) end
function M:getRT() return Vector(self.r,self.t) end
function M:getRB() return Vector(self.r,self.b) end
function M:getLB() return Vector(self.l,self.b) end
function M:getRatio() return self.w/self.h end
function M:isRect() return ctype(self) == "rect" end

return M