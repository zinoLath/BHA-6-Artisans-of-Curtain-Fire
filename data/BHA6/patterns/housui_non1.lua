local center = Vector(0,100)
local housui_fire = Class()
function housui_fire:init(boss,r1,r2,sa,a,col)
    bullet.init(self,"arrow",col,color.White,"add+add")
    self.colli = true
    self.boss = boss
    self.r1 = r1
    self.r2 = r2
    self.sa = sa
    self.ang = a
    self.saomg = ran:Float(0.2,0.5) * ran:Sign()
    self.omg = ran:Float(2,2) * ran:Sign()
    self.anchor = Vector(boss.x, boss.y)
    self._color = col
    self.rang = 0
    self.romg = ran:Float(0.05,0.6) * ran:Sign()
    self.bound = false
    self.init_ang = a
    self.hscale, self.vscale = 2.5,2.5
    self.ratio = 0
    task.New(self,function()
        AdvancedFor(60,{"linear",0,1,true},function(i)
            self.ratio = math.tween.cubicInOut(i)
            task.Wait(1)
        end)
    end)
    self.sign = ran:Sign()
end
function housui_fire:frame()
    self._color = ColorHSV(255,self.timer*5,100,100)
    self.last_rot = self.rot
    self.rot = Angle(0,0,self.dx,self.dy)
    task.Do(self)
    if self.timer > 2 and self.timer % 2 == 0 then
        local alpha = 200
        local obj = New(bullet,"scale",self._color * Color(alpha,255,255,255),self._subcolor,"grad+add",false)
        obj.x, obj.y = self.x,self.y
        obj.vx,obj.vy = -self.dx*0.1,-self.dy*0.1
        obj.rot = self.rot
        obj.colli = false
        task.New(obj,function()
            for i=0,3,3/15 do
                obj.hscale, obj.vscale = i,i
                task.Wait(1)
            end
            task.Wait(30)
            for i=0,1,1/30 do
                obj._a = math.lerp(alpha,0,i)
                task.Wait(1)
            end
            RawDel(obj)
        end)
    end
    if not IsValid(self.boss) then
        return RawDel(self)
    end
    if self.orbit == false then
        return
    end
    self.anchor = Vector.lerp(self.anchor, Vector(self.boss.x, self.boss.y), 0.2)
    local anchor = self.anchor
    self.ang = self.ang + self.omg
    self.sa = self.sa + self.saomg
    self.rang = self.rang + self.romg
    local off = Vector.fromAngle(self.ang) * Vector(self.r1,self.r2*cos(self.rang))
    off:rotate(self.sa)
    off = off * self.ratio
    self.lastx, self.lasty = self.x, self.y
    self.x, self.y = anchor.x + off.x, anchor.y + off.y
end
function housui_fire:exit()
    self.orbit = false
    self._subcolor = color.Red
    local va = self.rot-self.last_rot
    local vs = Dist(0,0,self.dx,self.dy)
    local a = self.rot
    local homing = 3
    local svs = vs
    local shoming = homing
    local lstg_world = lstg.world
    local __time = 60
    task.New(self,function()
        PlaySound("ch00", 1)
        local delayobj = DelayLine(self.x,self.y,a,96,nil,Color(64,0,0,255),15,0,90)
        for i=1, _infinite do
            local t = math.clamp(i,0,__time)/__time
            vs = math.lerp(svs,10,math.tween.cubicOut(math.clamp(i-__time/2,0,__time)/__time))
            homing = math.lerp(shoming,0,math.tween.cubicOut(t))
            va = math.lerp(va,0,0.2)
            a = a + va
            local da = math.clamp(AngleDifference(a, Angle(self,player)),-shoming,shoming)*(1-t)
            a = a + da
            SetV(self,vs,a)
            if IsValid(delayobj) then
                delayobj.rot = self.rot
                delayobj.x,delayobj.y = self.x,self.y
            end
            coroutine.yield()
            if not BoxCheck(self, lstg_world.l, lstg_world.r, lstg_world.b, lstg_world.t) then
                local base_ang = Angle(self,player)
                AdvancedFor(4, {"incremental",0,0/10,true}, {"linear",2,2.5},function(ang,spd)
                    AdvancedFor(15,{"linear",-180,180,false},function(_ang)
                        AdvancedFor(3,{"linear",-2,2},{"zigzag",0,0.25,1,true},function(__ang,_spd)
                            local ang = _ang+__ang+base_ang+180+ang
                            PlaySound("don00",1)
                            local __obj = CreateShotA(self.x,self.y,0.4-_spd,ang,"amulet",color.Green)
                            task.New(__obj,function()
                                for i=1, 30 do
                                    local t = math.tween.cubicInOut(i/30)
                                    local sp = math.lerp(2-_spd,0,t)
                                    SetV(__obj,sp,ang)
                                    coroutine.yield()
                                end
                                task.Wait(0)
                                for i=1, 120 do
                                    local t = math.tween.cubicInOut(i/120)
                                    local sp = math.lerp(0,_spd+spd,t)
                                    SetV(__obj,sp,ang)
                                    coroutine.yield()
                                end
                            end)
                        end)
                    end)
                end)
                RawDel(self)
                return
            end
        end
    end)
end
local sc = boss.card:new("", 60, 7, 2, 600, false)
function sc:before()
    New(boss_particle_trail,self)
    task.New(self.particle_trail,function()
        while(true) do
            self.particle_trail.c1 = ColorHSV(64,self.timer,100,100)
            self.particle_trail.c2 = ColorHSV(0,self.timer+90,100,100)
            task.Wait()
        end
    end)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        task.New(self,function()
            while(true) do
                for count=1, 4 do
                    for i=1, 4 do
                        PlaySound("tan00",0.6)
                        task.New(self,function()
                            local r1, r2 = ran:Float(32,64),ran:Float(32,64)
                            local fire = New(housui_fire,self,r1, r2,ran:Float(0,360),ran:Float(0,360),color.Red)
                            task.Wait(90)
                            housui_fire.exit(fire)
                        end)
                        task.Wait(3)
                    end
                    MoveRandom(self,8,32,lstg.world.l+64,lstg.world.r-64,100,lstg.world.t-80,100)
                    --task.Wait(100)
                end
                MoveRandom(self,32,64,lstg.world.l+64,lstg.world.r-64,100,lstg.world.t-80,60)
                task.Wait(120)
                local baseang = 0
                AdvancedFor(50,{"sinewave",baseang,baseang+90,0,50},{"sinewave",3,3.5,0,5},{"sinewave",-5,5,0,50},{"linear",10,1,true,math.tween.circOut}
                ,function(angoff,base_spd,spread,wait)
                            PlaySound("tan01",0.3)
                    AdvancedFor(10,{"linear",0,360},function(rad)
                        AdvancedFor(3,{"linear",0,-spread},{"linear",base_spd,base_spd*1.1},function(ang,spd)
                            CreateShotA(self.x,self.y,spd,ang+angoff+rad,"circle",color.Blue)
                        end)
                    end)
                    task.Wait(5)
                end)
                --task.Wait(60)
            end
        end)
        task.New(self,function()
            task.Wait(180)
            while(true) do
                --MoveRandom(self,32,64,lstg.world.l+64,lstg.world.r-64,100,lstg.world.t-80,60)
                task.Wait(60)
            end
        end)
    end)
end
sc.boss_info = housui_boss_data
return sc