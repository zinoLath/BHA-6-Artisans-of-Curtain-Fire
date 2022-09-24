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
                            local spd = 2.7
                            local x_off = ran:Float(-10,5)
                            CreateShotA(lstg.world.l-15+x_off,math.lerp(lstg.world.b,lstg.world.t,t),
                                    spd+ran:Float(0,0.05),0,grp,color.OrangeRed,nil,"grad+add",3)
                            CreateShotA(lstg.world.r+15-x_off,math.lerp(lstg.world.b,lstg.world.t,t2),
                                    spd+ran:Float(0,0.05),180,grp,color.OrangeRed,nil,"grad+add",3)
                        end)
                    end)
                end)
                task.Wait(60)
            end
        end)
        task.New(self,function()
            local random_grps = {"scale","snowflake","amulet","square"}
            while true do
                PlaySound("ch00", 1)
                MoveRandom(self,32,48,lstg.world.l+64,lstg.world.r-64,50,lstg.world.t-50,120)
                PlaySound("tan00", 1)
                local wvel = 0.2
                local ang = Angle(self,player)
                AdvancedFor(120,{"linear",0,30},{"linear",7,4},function(spread,spd)
                    --ang = ang + math.clamp(AngleDifference(ang,Angle(self,player)),-wvel,wvel)
                    spd = spd + ran:Float(0,0.2)
                    CreateShotA(self.x,self.y,spd,ang + ran:Float(-spread,spread),random_grps[ran:Int(1,#random_grps)],
                        color.DarkCyan)
                    CreateShotA(self.x,self.y,spd,ang + ran:Float(-spread,spread),random_grps[ran:Int(1,#random_grps)],
                            color.DarkCyan)
                    task.Wait(1)
                    PlaySound("tan02", 1)
                end)
                task.Wait(60)
            end
        end)
    end)
end

return sc