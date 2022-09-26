local center = Vector(0,100)
local hide_rad = 100
local sc = boss.card:new("Shifting Spell ~ Temporal Mismatch", 60, 6, 2, 600, false)
local bullet_first = Class(straight)
function bullet_first:frame()
    self._alpha = 170
    straight.frame(self)
    local isactive = Dist(self,player) < hide_rad
    self.hide = isactive
    self.colli = false
end
local bullet_second = Class(straight)
function bullet_second:init(time,...)
    self.delay = false
    self.args = {...}
    self.timer = -time
    self.group = GROUP_ENEMY_BULLET
end
function bullet_second:frame()
    if self.timer == 0 then
        straight.init(self,unpack(self.args))
    end
    if self.timer >= 0 then
        straight.frame(self)
    end
    local isactive = Dist(self,player) > hide_rad
    self.hide = isactive
    self.colli = not isactive
end
local invert_range = Class()
function invert_range:init(boss)
    self.layer = LAYER_TOP
    self.boss = boss
    table.insert(boss._servants,self)
end
function invert_range:render()
    rendercircle(player.x,player.y,1000,32)
    rendercircle(player.x,player.y,hide_rad,32)
end
local default_sub = color.White
local default_delay = 5
local default_blend = "grad+alpha"
local function HCreateShotA(x,y,speed,angle,graphic,color,subcolor,blend,delay)
    --do return {} end
    subcolor = subcolor or default_sub
    delay = delay or default_delay
    blend = blend or default_blend
    local obj1 = New(bullet_first,graphic,color,subcolor,x,y,angle,speed,0,blend,delay)
    local obj2 = New(bullet_second,60,graphic,color,subcolor,x,y,angle,speed,0,blend,delay)
    return obj1,obj2
end
function sc:before()
    self.x = lstg.world.pr + 64
    self.y = lstg.world.pt + 64
    New(boss_particle_trail,self)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        New(invert_range,self)
        task.New(self,function()
            local wait1 = 60
            local wait2 = 30
            for i=1, _infinite do
                MoveRandom(self,32,64,lstg.world.l+64,lstg.world.r-64,100,lstg.world.t-80,wait1)
                task.Wait(wait2)
            end
        end)
        task.New(self,function()
            while true do
                AdvancedFor(5,{"linear",-90,270},function(ang)
                    local spread = 18 + (18-9) * cos(self.timer*6)
                    HCreateShotA(self.x,self.y,7,ang + spread,"big_ellipse",color.Black,color.White)
                    HCreateShotA(self.x,self.y,7,ang - spread,"big_ellipse",color.White,color.Black)
                end)
                task.Wait(3)
            end
        end)
        task.Wait(120)
        local _sign = 1
        for count=1, _infinite do
            local ang = Angle(self,player)
            AdvancedFor(3,{"linear",0,0*_sign},function(_off)
                AdvancedFor(10,{"linear",4,9},function(spd)
                    HCreateShotA(self.x,self.y,spd,ang+_off,"heart",color.Red)
                end)
                task.Wait(3)
            end)
            task.Wait(60)
            local pos = Vector(self.x,self.y)
            AdvancedFor(5, {"linear",0,1,true},{"linear",0,90*_sign},{"linear",4,2,true},function(_t,_sang,_spd)
                AdvancedFor(15,{"linear",0,360},function(_ang)
                    AdvancedFor(4,{"linear",0,5},function(_spread)
                        local poly_vec = Vector.fromPolygon(3,(_ang+_spread)/360):rotated(_sang)
                        local pos_vec = Vector(120*-_sign,-30)*_t + pos
                        HCreateShotA(pos_vec.x,pos_vec.y,poly_vec.length*_spd,poly_vec.angle,"amulet",color.Green)
                    end)
                end)
                task.Wait(5)
            end)
            _sign = -_sign
            task.Wait(60)
        end
    end)
end

return sc