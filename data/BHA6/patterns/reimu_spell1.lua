local center = Vector(0,0)
local sc = boss.card:new("Trigger Happy - Tripwire Barrier", 60, 3, 2, 800, false)
local reimu_square = Class()
local sq_img = LoadImageFromFile("reimu_square",GetCurrentScriptDirectory().."reimu_square.png")
function reimu_square:init(x,y,rot)
    self.x, self.y = x,y
    self._color = Color(64,0,0,255)
    self.rot = rot
    self._blend = "add+add"
    self.__w = 0
    self.verts = {
        Vector(-1,1),
        Vector(1,1),
        Vector(1,-1),
        Vector(-1,-1),
    }
    self.v = {}
    self.v1,self.v2,self.v3,self.v4 = {},{},{},{}
    self.rad = 0
    self.img = sq_img
    self.colli = false
    self.group = GROUP_INDES
end
function reimu_square:frame()
    task.Do(self)
    for k,v in ipairs(self.verts) do
        self.v[k] = Vector(self.x,self.y) + (v*self.rad):rotated(self.rot)
    end
    for k,v in ipairs(self.verts) do
        local v1,v2 = v, LoopTable(self.verts,k+1)
        self.v1[k] = Vector(self.x,self.y) + (v1*(self.rad-self.__w/2)):rotated(self.rot)
        self.v2[k] = Vector(self.x,self.y) + (v1*(self.rad+self.__w/2)):rotated(self.rot)
        self.v3[k] = Vector(self.x,self.y) + (v2*(self.rad+self.__w/2)):rotated(self.rot)
        self.v4[k] = Vector(self.x,self.y) + (v2*(self.rad-self.__w/2)):rotated(self.rot)
        if self.timer % 5 == 0 then
            New(reimu_square_particle,self,self.v1[k],self.v2[k],self.v3[k],self.v4[k])
        end
    end
    if not self.colli then return end
    for k,v in ipairs(self.verts) do
        local v1,v2 = self.v[k], LoopTable(self.v,k+1)
        local bool = CircleToCapsule(Vector.fromTable(player),1,v1,v2,self.__w*0.25)
        if bool then
            Collide(self,player)
        end
    end
end
function reimu_square:render()
    SetImageState(self.img,self._blend,self._color)
    for k,v in ipairs(self.verts) do
        local vert1 = self.v1[k]
        local vert2 = self.v2[k]
        local vert3 = self.v3[k]
        local vert4 = self.v4[k]
        Render4V(self.img,vert1.x,vert1.y,0,vert2.x,vert2.y,0,vert3.x,vert3.y,0,vert4.x,vert4.y,0)
    end
end
reimu_square_particle = Class()
function reimu_square_particle:init(master,vert1,vert2,vert3,vert4)
    self.master = master
    self.v1,self.v2,self.v3,self.v4 = vert1,vert2,vert3,vert4
    self._color = master._color
    self.img = master.img
    self._blend = master._blend
    self.__a = master._a
end
function reimu_square_particle:frame()
    if self.timer < 15 then
        self._a = math.lerp(self.__a,0,self.timer/15)
    else
        Del(self)
    end
    task.Do(self)
end
function reimu_square_particle:render()
    SetImageState(self.img,self._blend,self._color)
    Render4V(self.img,self.v1.x,self.v1.y,0,self.v2.x,self.v2.y,0,self.v3.x,self.v3.y,0,self.v4.x,self.v4.y,0)
end
function sc:before()
    New(boss_particle_trail,self)
end
local function GenerateTask(obj,self,square)
    obj.bound = false
    return function()
        task.Wait(120/Dist(0,0,obj.vx,obj.vy))
        while true do
            for k,v in ipairs(square.verts) do
                local v1,v2 = square.v[k], LoopTable(square.v,k+1)
                local bool,t = CircleToCapsuleUnPen(Vector.fromTable(obj),1,v1,v2,square.__w)
                if bool then
                    local _v1,_v2 =  LoopTable(square.v,k+2), LoopTable(square.v,k+3)
                    local v_final = Vector.lerp(_v1,_v2,1-t)
                    local v_start = Vector.lerp(v1,v2,t)
                    local _x, _y = obj.x, obj.y
                    local _color = obj._color
                    --CreateShotR(v_final.x,v_final.y,1,obj.rot,"amulet",color.Red,square.__w)
                    task.New(self,function()
                        local delay = DelayLine(_x,_y,Angle(v_start.x,v_start.y,v_final.x,v_final.y),32,1000,
                                _color * Color(80,255,255,255),15,45,15)
                        task.New(delay,function()
                            while true do
                                local _v1,_v2 =  LoopTable(square.v,k+2), LoopTable(square.v,k+3)
                                local v1,v2 = square.v[k], LoopTable(square.v,k+1)
                                local v_final = Vector.lerp(_v1,_v2,1-t)
                                local v_start = Vector.lerp(v1,v2,t)
                                delay.x,delay.y = v_start.x,v_start.y
                                delay.rot = delay.rot + square.omiga
                                task.Wait(1)
                            end
                        end)
                        task.Wait(60)
                        local _obj = CreateStraightLaser(v_start.x,v_start.y,90*-k+square.rot,1000,4,1,20,0,_color)
                        _obj.colli = false
                        _obj.bound = false
                        task.New(_obj,function()
                            for i=0,1,1/5 do
                                _obj.w = math.lerp(0,4,math.tween.cubicInOut(i))
                                task.Wait(1)
                            end
                            _obj.colli = true
                            task.Wait(5)
                            _obj.colli = false
                            for i=1,0,-1/5 do
                                _obj.w = math.lerp(0,4,math.tween.cubicInOut(i))
                                task.Wait(1)
                            end
                            Del(_obj)
                        end)
                        task.New(_obj,function()
                            while true do
                                local _v1,_v2 =  LoopTable(square.v,k+2), LoopTable(square.v,k+3)
                                local v1,v2 = square.v[k], LoopTable(square.v,k+1)
                                local v_final = Vector.lerp(_v1,_v2,1-t)
                                local v_start = Vector.lerp(v1,v2,t)
                                _obj.x,_obj.y = v_start.x,v_start.y
                                _obj.rot = _obj.rot + square.omiga
                                task.Wait(1)
                            end
                        end)
                    end)
                    Del(obj)
                end
            end
            task.Wait(1)
        end
    end
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        local square = New(reimu_square,self.x,self.y,0)
        square._a = 0
        square.omiga = 0.1
        square.rad = lstg.world.r*1.5
        table.insert(self._servants,square)
        task.New(square,function()
            SetFieldInTime(square,60,math.tween.cubicInOut,{"rad",lstg.world.r*1.2},{"_a",128},{"__w",8})
            square.colli = true
        end)
        task.Wait(120)
        while true do
            AdvancedFor(3,function()
                AdvancedFor(30,{"linear",0,360},function(ang)
                    local obj = CreateShotA(self.x,self.y,2,ang,"amulet",color.Red)
                    task.New(obj,GenerateTask(obj,self,square))
                end)
                task.Wait(2)
            end)
            task.Wait(120)
            local ang = 90
            AdvancedFor(20, {"linear",3,1},function(spd)
                local prev_ang = ang
                AdvancedFor(3,function()
                    AdvancedFor(4,{"linear",0,360},function(_a)
                        local obj = CreateShotA(self.x,self.y,spd,ang+_a,"amulet",Color(255,32,32,255))
                        task.New(obj,GenerateTask(obj,self,square))
                    end)
                    ang = ang + 1.5
                    task.Wait(1)
                end)
                ang = prev_ang - 15
                task.Wait(10)
            end)
            task.Wait(60)
            local stream = Angle(self,player)
            AdvancedFor(4,{"linear",0,360},function(_a)
                DelayLine(self.x,self.y,stream+_a,128,1000,Color(64,255,255,128))
                AdvancedFor(7,{"linear",-15,15},{"zigzag",1,2,1,true},function(spread,spd)
                    AdvancedFor(4,{"linear",0,0.05},function(_spd)

                        local obj = CreateShotA(self.x,self.y,spd+_spd,stream+spread+_a,"amulet",color.Yellow)
                        task.New(obj,GenerateTask(obj,self,square))
                    end)
                end)
            end)
            task.Wait(180)
        end
    end)
end

--[[
while (true) do
            task.New(self,function()
                ReimuWarp(self,100,50,10,180,math.tween.cubicInOut,3)
            end)
            task.Wait(30)
            AdvancedFor(50,{"linear",32,32},{"linear",0,180},function(rad,ang)
                local obj = New(reimu_square,self.x,self.y,0)
                local tween = math.tween.cubicInOut
                task.New(obj,function()
                    obj.rot = ang + ran:Float(0,360)
                    AdvancedFor(45,{"linear",0,rad,true,tween},{"linear",0,255,true,tween},{"linear",8,16,true,tween},function(_r,_c,_w)
                        obj._a = math.clamp(_c,0,255)
                        obj.rad = _r
                        obj.__w = _w
                        task.Wait(1)
                    end)
                    task.Wait(120)
                    AdvancedFor(15,{"linear",16,64,true,tween},function(_w)
                        obj.__w = _w
                        task.Wait(1)
                    end)
                    task.Wait(120)
                    AdvancedFor(5,{"linear",0,1},function(a1)
                        AdvancedFor(4,{"linear",0,1/25},function(a2)
                            local v = Vector.list_lerp(obj.v,(a1+a2)*4)
                            local v2 = Vector.list_lerp(obj.verts,(a1+a2)*4)
                            CreateShotA(v.x,v.y,v2.length*0.1,Angle(obj.x,obj.y,v.x,v.y),"amulet",color.Blue)
                        end)
                    end)
                    AdvancedFor(60,{"linear",255,0,true,tween},function(_c)
                        obj._a = math.clamp(_c,0,255)
                        task.Wait(1)
                    end)
                    Del(obj)
                end)
                task.Wait(1)
            end)
            task.Wait(_infinite)
        end
--]]
sc.boss_info = reimu_boss_data
return sc