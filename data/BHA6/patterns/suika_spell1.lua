local center = Vector(0,100)
local black_hole = Class()
local function pullObj(self,obj)
    local dist = Dist(self,obj)
    local resist = obj.pull_resist or 1
    if false and dist < self.r1 then
        return true
    else
        local ndist = math.clamp(self.r2-dist,0,self.r2)/self.r2
        ndist = ndist * ndist
        if ndist ~= 0 then
            local difvec = Vector(self.x-obj.x,self.y-obj.y)
            difvec = difvec.normalized * self.force * ndist * resist
            if tostring(difvec.x) ~= "nan" and tostring(difvec.y) ~= "nan" then
                obj.x = obj.x + difvec.x
                obj.y = obj.y + difvec.y
            end
        end
    end
end
function black_hole:init(x,y,r1,r2,force)
    self.r1 = r1 or 32
    self.r2 = r2 or 512
    self.x, self.y = x,y
    self.force = force or 1
    self.layer = LAYER_ENEMY_BULLET+100
    self.bound = false
end
function black_hole:frame()
    task.Do(self)
    if not self.colli then return end
    for i,obj in ObjList(GROUP_ENEMY_BULLET) do
        if not obj.pull_free and pullObj(self,obj) then
            --[[
            local a = -obj.rot
            local _obj = CreateShotA(obj.x,obj.y,4,a,"scale",color.Blue,color.LightGray)
            _obj.pull_free = true
            task.New(_obj,function()
                SetV(_obj,5,a)
                task.Wait(15)
                for t=0,1,1/15 do
                    SetV(_obj,math.lerp(5,3,math.tween.cubicInOut(t)),a)
                    task.Wait(1)
                end
            end)
            Del(obj)
            --]]
        end
    end
    for i,obj in ObjList(GROUP_PLAYER_BULLET) do
        if not obj.pull_free and pullObj(self,obj) then
        end
    end
    player.pull_resist = 0.25
    pullObj(self,player)
end
function black_hole:render()
    rendercircle(self.x, self.y, self.r1, 32)
end
local sc = boss.card:new("Gathering Oni - I dont know", 60, 5, 2, 1200, false)
function sc:before()
    self.x = lstg.world.pr + 64
    self.y = lstg.world.pt + 64
    New(boss_particle_trail,self)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        local hole = New(black_hole,self.x,self.y,0,0,0)
        task.New(hole,function()
            SetFieldInTime(hole,60,math.tween.cubicOut,{"r1",64},{"r2",1024},{"force",2})
            while true do
                for i,obj in ObjList(GROUP_ENEMY_BULLET) do
                    task.New(obj,function()
                        for i=1,15 do
                            obj._r = 255*(1-(i/15))
                            obj._b = 255*((i/15))
                            task.Wait(1)
                        end
                        obj.pull_free = true
                    end)
                end
                SetFieldInTime(hole,16,math.tween.cubicOut,{"force",0})
                task.Wait(15)
                SetFieldInTime(hole,120,math.tween.cubicOut,{"force",4})
                PlaySound("ch00",1)
                task.Wait(60)
                PlaySound("slash",1)
            end
        end)
        task.New(hole,function()
            local shape_ang = 0
            local ang = 0
            local radvec = Vector(32,150)
            while(IsValid(self)) do
                ang = ang + 1
                shape_ang = shape_ang + math.pi*0.07
                local yassvec = (radvec * Vector.fromAngle(ang)):rotated(shape_ang)
                hole.x = self.x + yassvec.x
                hole.y = self.y + yassvec.y
                task.Wait(1)
            end
        end)
        task.Wait(120)
        task.New(self,function()
            local __ang = 0
            for i=1,_infinite do
                AdvancedFor(10,{"linear",0,360,false}, function(ang)
                    local obj = CreateShotA(self.x,self.y,2,ang+__ang,"scale",color.Red)
                    obj.navi = true
                    obj.pull_resist = 0.25
                end)
                __ang = __ang + i * 0.3
                task.Wait(10)
            end
        end)
        task.New(self, function()
            task.Wait(240)
            for i=1,_infinite do
                local __ang = Angle(self,player)
                local spr = 75 + 15 * cos(self.timer)
                AdvancedFor(5,{"linear",-spr,spr,true}, function(ang)
                    AdvancedFor(2,{"linear",6,5.5},function(spd)
                        local obj = CreateShotA(self.x,self.y,spd,ang+__ang+ran:Float(-1,1),"amulet",color.Red)
                        --obj.pull_resist = 1.25
                    end)
                end)
                task.Wait(10)
            end
        end)
    end)
end

return sc