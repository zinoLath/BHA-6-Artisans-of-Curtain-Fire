local center = Vector(0,100)
local sc = boss.card:new("", 60, 5, 2, 600, false)
function sc:before()
    New(boss_particle_trail,self)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        task.New(self,function()
            for count=1, _infinite do
                local yspread = lstg.world.t/3
                AdvancedFor(3,{"linear",5,-5},function(xoff)
                    AdvancedFor(3, {"linear",lstg.world.b,lstg.world.t,false},function(_y)
                        AdvancedFor(10,{"linear",0,yspread+10,false},function(_yoff)
                            local ty = ((_y+_yoff + yspread + count)-lstg.world.b)/(lstg.world.t+math.abs(lstg.world.b))
                            local _,t = math.modf(ty)
                            local ty2 = ((_y+_yoff + count)-lstg.world.b)/(lstg.world.t+math.abs(lstg.world.b))
                            local _,t2 = math.modf(ty2)
                            local grp = "ice"
                            local spd = math.lerp(1.5,3.5,math.clamp((count/10),0,1))
                            local x_off = ran:Float(-10,5)
                            CreateShotA(lstg.world.l-15+x_off,math.lerp(lstg.world.b,lstg.world.t,t),
                                    spd+ran:Float(0,0.05),0,grp,color.OrangeRed,nil,"add+add",1)
                            CreateShotA(lstg.world.r+15-x_off,math.lerp(lstg.world.b,lstg.world.t,t2),
                                    spd+ran:Float(0,0.05),180,grp,color.OrangeRed,nil,"add+add",1)
                        end)
                    end)
                end)
                task.Wait(45)
            end
        end)
        task.New(self,function()
            local random_grps = {"scale","snowflake","amulet","square"}
            task.Wait(300)
            while true do
                MoveRandom(self,32,48,lstg.world.l+64,lstg.world.r-64,50,lstg.world.t-50,30)
                local wvel = 0.2
                --task.Wait(30)
                local ang = Angle(self,player)
                DelayLine(self.x,self.y,ang,200,1000,Color(128,255,0,0),30,0,15)
                PlaySound("ch00", 1)
                task.Wait(30)
                PlaySound("tan00", 1)
                AdvancedFor(15,{"linear",3,15},{"linear",7,5},function(spread,spd)
                    --ang = ang + math.clamp(AngleDifference(ang,Angle(self,player)),-wvel,wvel)
                    spd = spd + ran:Float(0,0.2)
                    CreateShotA(self.x,self.y,spd,ang + ran:Float(-spread,spread),random_grps[ran:Int(1,#random_grps)],
                        color.DarkCyan,nil,"add+add")
                    CreateShotA(self.x,self.y,spd,ang + ran:Float(-spread,spread),random_grps[ran:Int(1,#random_grps)],
                            color.DarkCyan,nil,"add+add")
                    task.Wait(1)
                    PlaySound("tan02", 1)
                end)
            end
        end)
        do return end
        task.New(self,function()
            task.Wait(300)
            while true do
                AdvancedFor(15, {"linear",0,360},function(ang)
                    CreateShotA(self.x,self.y,0.5,ang+self.timer*2,"scale",color.Red)
                end)
                task.Wait(120)
            end
        end)
    end)
end

sc.boss_info = suika_boss_data
return sc