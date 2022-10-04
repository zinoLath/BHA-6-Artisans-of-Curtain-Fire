local path = GetCurrentScriptDirectory()
smear = Class(object)
local smear_part = Class()
smear_part.default_function = 0x10
function smear:init(obj,t,d,colormod,alphamod)
    self.obj = obj
    self.t = t or 15
    self.d = d or 1
    self.layer = obj.layer-2
    self.colormod = colormod or color.White
    self.alphamod = alphamod or 1
end
function smear:frame()
    if not IsValid(self.obj) then
        Del(self)
        return
    end
    task.Do(self)
    if self.timer % self.d == 0 then
        local obj = self.obj
        New(smear_part, obj.x, obj.y, obj.img, obj._color * self.colormod, obj.rot, obj.hscale, obj.vscale, obj.layer,obj._blend,self.alphamod, self.t)
    end
end
function smear_part:init(x,y,img,color,rot,hscale,vscale,layer,blend,alphamod,t)
    self.x, self.y, self.img, self._color, self.rot, self.hscale, self.vscale, self.t = x,y,img,color,rot,hscale,vscale,t
    self._blend = blend
    self.layer = layer
    self._a = self._a * alphamod
    self.__a = self._a
end
function smear_part:frame()
    if self.timer > self.t then Del(self); return end
    local t = math.clamp(self.timer/self.t,0,1)
    self._a = self.__a * (1-t)
end

LoadImageFromFile("delay_white",path.."delay_white.png",true)
SetTextureSamplerState("delay_white","linear+wrap")
SetImageState("delay_white","",color.Red)
local w,h = GetImageSize("delay_white")
SetImageCenter("delay_white",0,h/2)
line_delay = Class()
function line_delay:init(x,y,rot,width,length,color,t1,t2,t3)
    self.x, self.y = x,y
    self.img = "delay_white"
    self.rot = rot
    self.width = width
    self.length = length
    self._color = color
    self.__a = self._a
    self.h = h
    self.tween = math.tween.cubicInOut
    self.layer = LAYER_ENEMY_BULLET-50
    self.group = GROUP_BOSS_EFFECT
    self.hscale = self.length/(h/4)
    self.bound = false
    task.New(self,function()
        for i=1, t1 do
            local t = self.tween(i/t1)
            self.vscale = math.lerp(0,self.width/w,t)
            task.Wait(1)
        end
        task.Wait(t2)
        for i=1, t3 do
            local t = self.tween(i/t3)
            self._a = math.lerp(self.__a,0,t)
            task.Wait(1)
        end
        Del(self)
    end)
end
function line_delay:frame()
    task.Do(self)
end
function DelayLine(x,y,rot,width,length,color,t1,t2,t3)
    length = length or 1000
    color = color or Color(64,255,0,0)
    t1,t2,t3 = t1 or 15, t2 or 0, t3 or 45
    return New(line_delay,x,y,rot,width,length,color,t1,t2,t3)
end