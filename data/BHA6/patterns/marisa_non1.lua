local center = Vector(0,100)
local sc = boss.card:new("", 60, 6, 2, 600, false)
local marisa_familiar = Class()
function marisa_familiar:init(x,y,boss)
    --enemybase.init(self,100,true)
    self.x,self.y = x,y
    self.omiga = 3
    self.img = "parimg10"
    self.layer = LAYER_ENEMY-10
    self.hscale, self.vscale = 2.25,2.25
    self._dmg_transfer = 1
    self.bound=false
    self.boss = boss
    table.insert(boss._servants,self)
end
function marisa_familiar:frame()
    --enemybase.frame(self)
    if not IsValid(self.boss) then
        Del(self)
        return
    end
    task.Do(self)
end
function sc:before()
    self.x = lstg.world.pr + 64
    self.y = lstg.world.pt + 64
    New(boss_particle_trail,self)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        local shape_angle = 0
        task.New(self,function()
            --while(true) do shape_angle = shape_angle + 0.1; task.Wait(1) end
        end)
        task.New(self,function()
            while(true) do
                MoveRandom(self,32,64,lstg.world.l+64,lstg.world.r-64,100,lstg.world.t-80,60)
                local ap = Angle(self,player)
                AdvancedFor(3,{"incremental",0,1},function(i)
                    AdvancedFor(4+i%2,{"linear",-45,45,true},function(ang)
                        local a = ap+ang

                        PlaySound("kira01",0.3)
                        local obj = CreateShotA(self.x,self.y,1,a,"star",
                                ColorHSV(255,self.timer+180,100,100),nil,"add+add")
                        obj.layer = LAYER_ENEMY_BULLET+50
                        obj.omiga = 3
                        DelayLine(self.x,self.y,a,96,nil,nil,15,60,15)
                        New(smear,obj,nil,nil,nil,0.2)
                        task.New(obj,function()
                            task.Wait(30)
                            while IsValid(self) do
                                PlaySound("tan01",0.1)
                                local col = ColorHSV(255,self.timer+180,100,100)
                                local a = Angle(obj.dx,obj.dy,0,0)+ran:Float(-5,5)
                                local eff = CreateShotR(obj.x,obj.y,1+obj.timer/10+ran:Float(-1,1),a,
                                        "smallstar",col,-32,a,InterpolateColor(col,color.White,0.7),"add+add",
                                        math.lerp(30,3,math.clamp(obj.timer/60,0,1)))
                                eff.layer = LAYER_ENEMY_BULLET-10
                                eff.omiga = 3
                                task.Wait(2)
                            end
                        end)
                        task.New(obj,function()
                            SetV(obj,3,a)
                            task.Wait(30)
                            local t = 45
                            for i=1, t do
                                local t = math.tween.circIn(i/t)
                                local sp = math.lerp(3,7,t)
                                SetV(obj,sp,a)
                                coroutine.yield()
                            end
                        end)
                    end)
                    task.Wait(15)
                end)
                task.Wait(15)
            end
        end)
        AdvancedFor(6,{"linear",0,360,false},function(familiar_ang)
            local familiar = New(marisa_familiar,self.x,self.y,self)
            New(smear,familiar,nil,nil,nil,0.8)
            local fam = familiar
            local maxrad = 100
            familiar.rad1, familiar.rad2, familiar.ang, familiar.shape_ang = 0,0,familiar_ang,shape_angle
            fam.omg = 1
            task.New(familiar,function()
                SetFieldInTime(familiar,60,math.tween.cubicOut,{"rad1",maxrad},{"rad2",maxrad/2})
            end)
            task.New(familiar,function()
                for i=1, _infinite do
                    familiar.shape_ang = shape_angle
                    fam.ang = fam.ang + fam.omg
                    local offset = Vector.rotate(Vector.fromAngle(fam.ang) * Vector(familiar.rad1,familiar.rad2),familiar.shape_ang)
                    fam.x = self.x + offset.x
                    fam.y = self.y + offset.y
                    task.Wait(1)
                end
            end)
            --do return end
            task.New(familiar,function()
                task.Wait(60)
                for i=1, _infinite do
                    PlaySound("tan02",0.2)
                    local __spd = 3
                    AdvancedFor(3,{"linear",__spd*0.95,__spd},function(spd)
                        AdvancedFor(4,{"linear",-45,45,true},function(spread)
                            local a = (fam.ang+45+120)+spread
                            local spd1 = 0.5
                            local obj = CreateShotA(fam.x, fam.y, spd1, a,"smallstar",ColorHSV(255,self.timer,100,100))
                            obj.omiga = 3
                            task.New(obj,function()
                                task.Wait(90)
                                for i=1, 15 do
                                    local t = math.tween.circIn(i/15)
                                    local sp = math.lerp(spd1,spd,t)
                                    local _a = math.lerp(a, a-45-120,t)
                                    SetV(obj,sp,_a)
                                    coroutine.yield()
                                end
                            end)
                        end)
                    end)
                    task.Wait(10)
                end
            end)
        end)
    end)
end

sc.boss_info = marisa_boss_data
return sc