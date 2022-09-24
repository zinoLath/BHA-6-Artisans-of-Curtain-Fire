local center = Vector(0,100)
local sc = boss.card:new("", 60, 2, 2, 600, false)
function sc:before()
    self.x = lstg.world.pr + 64
    self.y = lstg.world.pt + 64
    New(boss_particle_trail,self)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        local impact_wait = 5
        local impact_times = 50
        local idk_timing = 5
        local var_spd = {"linear",3,0.25}
        while(true) do
            task.Wait(impact_wait)
            AdvancedFor(6,var_spd,function(spd)
                AdvancedFor(impact_times,{"linear",0,360,true},function(ang)
                    CreateShotR(self.x,self.y,spd,ang,"amulet",color.Red,spd*10)
                end)
                task.Wait(idk_timing)
            end)
            ReimuWarp(self,-100,150,3,60)
            task.Wait(impact_wait)
            AdvancedFor(6,var_spd,function(spd)
                AdvancedFor(impact_times,{"linear",0,360,true},function(ang)
                    CreateShotR(self.x,self.y,spd,ang,"amulet",color.Red,spd*10)
                end)
                task.Wait(idk_timing)
            end)
            task.Wait(impact_wait)
            ReimuWarp(self,100,150,-3,60)
            task.Wait(impact_wait)
            AdvancedFor(6,var_spd,function(spd)
                AdvancedFor(impact_times,{"linear",0,360,true},function(ang)
                    CreateShotR(self.x,self.y,spd,ang,"amulet",color.Red,spd*10)
                end)
                task.Wait(idk_timing)
            end)
            task.Wait(impact_wait)
            ReimuWarp(self,0,-100,-3,60)
            task.New(self,function()
                MoveTo(self,ran:Float(-100,100),center.y,180,math.tween.quadOut)
                task.Wait(60)
                --ReimuWarp(self,0,100,-15,300) do return end
                for i=1, 10 do
                    MoveRandom(self,32,128,lstg.world.l+32,lstg.world.r-32,50,lstg.world.t-64,30)
                    --task.Wait(30)
                end
            end)
            local wwait = 5
            AdvancedFor(420/wwait,{"incremental",0,15},{"linear",2,5},function(ang,_spd)
                AdvancedFor(6,{"linear",0,360,true},function(_ang)
                    AdvancedFor(5,{"linear",0,5},{"linear",_spd*0.925,_spd*1.075},function(__ang,spd)
                        local a = ang+_ang+__ang+Angle(self,player)
                        local obj = CreateShotA(self.x,self.y,0.4,a,"amulet",color.Gray)
                        obj.layer = LAYER_ENEMY_BULLET + 30
                        task.New(obj,function()
                            task.Wait(120)
                            for i=1, 30 do
                                local t = math.tween.cubicInOut(i/30)
                                local sp = math.lerp(0.4,spd,t)
                                SetV(obj,sp,a)
                                coroutine.yield()
                            end
                        end)
                    end)
                end)
                task.Wait(wwait)
            end)
            task.Wait(30)
        end
    end)
end

return sc