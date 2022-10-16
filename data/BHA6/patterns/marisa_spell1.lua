local center = Vector(0,100)
local path = GetCurrentScriptDirectory()
local sc = boss.card:new("6th Degree of Separation ~ Love Dive", 60, 6, 2, 800, false)
LoadImageFromFile("mari_laser", path.."marisa_square.png")
function sc:before()
    New(boss_particle_trail,self)
end
local function ShapeTask(obj)
    obj.bound = false
    task.Wait(900/obj._spd)
    Del(obj)
end
local marisa_polygon = Class()
local marisa_poly_laser = Class()
function marisa_polygon:init(x,y,_sign,_sang,spd,initang,_somiga,roff)
    self.point_count = 3
    local point_count = self.point_count
    self.bul_list = {}
    spd = spd or 1
    _somiga = _somiga or 0
    initang = initang or 0
    self.x, self.y = x,y
    self._sign = _sign
    self.spd = spd
    self.angomg = 0.1 * _sign
    self.ang = initang
    self.somiga = _somiga
    self.sang = _sang
    self.radius = roff
    self._edges = {}
    self.edges = {}
    for i=1, point_count do
        self._edges[i] = Vector.fromAngle(i*360/point_count)
        self.edges[i] = Vector.fromAngle(i*360/point_count)
    end
    local obj_count = 35
    local star_color = _sign == 1 and color.Red or color.Blue
    self._color = (star_color + Color(255,64,64,64)) * Color(128,255,255,255)
    AdvancedFor(obj_count,{"linear",0,360},function(_ang)
        local _x, _y = x,y
        local _obj = CreateShotA(_x,_y,0,0,"smallstar",star_color)
        _obj.omiga = 3
        _obj._spd = spd
        table.insert(self.bul_list,_obj)
    end)
    local spd = 1.7/100
    local len = 0.999
    self.laser = New(marisa_poly_laser,self,0,len,-spd*_sign)
    self.laser._color = color.Yellow
    self.wlaser = New(marisa_poly_laser,self,-len*_sign,len,-spd*_sign)
    self.wlaser._color = color.Purple * Color(64,255,255,255)
    self.wlaser._subcolor = (color.Purple + Color(255,128,128,128)) * Color(255,255,255,255)
    self.wlaser.colli = false
    self.group = GROUP_INDES
    self.layer = LAYER_ENEMY_BULLET-51
end
function marisa_polygon:frame()
    self.radius = self.radius + self.spd
    if self.radius > 700 then
        Del(self)
    end
    self.sang = self.sang + self.somiga
    for i=1, self.point_count do
        self.edges[i] = self._edges[i]:rotated(self.sang) * self.radius
    end
    local __len = #self.bul_list
    for k,v in ipairs(self.bul_list) do
        if IsValid(v) then
            local t = (k/__len) + self.timer * 0.0003 * self._sign
            local vec = Vector.list_lerp(self.edges,t*self.point_count)
            v.x, v.y = self.x + vec.x, self.y + vec.y
        end
    end
end
function marisa_polygon:render()
    local pos_vec = Vector(self.x,self.y)
    SetImageState("curvy_white","",self._color)
    for k=1, #self.edges do
        local nextk = LoopTableK(self.edges,k+1)
        local v1, v2 = self.edges[k]+pos_vec, self.edges[nextk]+pos_vec
        local pervec = (v1 - v2).normalized:perpendicular() * 1
        Render4Vec("curvy_white",v1 - pervec, v1 + pervec, v2 + pervec, v2- pervec)
    end
end
function marisa_polygon:del()
    Del(self.laser)
    Del(self.wlaser)
    for k,v in ipairs(self.bul_list) do
        if IsValid(v) then
            Del(v)
        end
    end
end
function marisa_polygon:kill()
    Kill(self.laser)
    Kill(self.wlaser)
    for k,v in ipairs(self.bul_list) do
        if IsValid(v) then
            Kill(v)
        end
    end
end
function marisa_poly_laser:init(master,i,len,spd)
    self.master = master
    self.t = i
    self.len = len
    self.spd = spd
    self.img = "mari_laser"
    --self.data = BentLaserData()
    self.vec = {}
    self._blend = "grad+add"
    self.width = 4
    self.group = GROUP_INDES
end
function marisa_poly_laser:frame()
    local master = self.master
    if not IsValid(master) then
        return Del(self)
    end
    self.t = self.t + self.spd
    self.x, self.y = master.x, master.y
    table.clear(self.vec)
    local t1 = self.t
    local t2 = self.t-self.len
    local posv = Vector(self.x, self.y)
    local v = Vector.list_lerp(master.edges,t1) + posv
    table.insert(self.vec,v)
    local v = Vector.list_lerp(master.edges,int(t1)) + posv
    table.insert(self.vec,v)
    local v = Vector.list_lerp(master.edges,t2) + posv
    table.insert(self.vec,v)
    if self.colli then
        for k=1, #self.vec-1 do
            local v1, v2 = self.vec[k], self.vec[k+1]
            if CircleToCapsule(Vector.fromTable(player), player.a,v1,v2,self.width*0.8/2) then
                Collide(self,player)
            end
        end
    end
end
function marisa_poly_laser:render()
    SetImageState(self.img, self._blend, self._color)
    SetImageSubColor(self.img,self._subcolor)
    for k=1, #self.vec-1 do
        local pervec = (self.vec[k+1] - self.vec[k]).normalized:perpendicular() * self.width
        local v1, v2 = self.vec[k], self.vec[k+1]
        local lb, lt, rt, rb = v1 + pervec, v1 - pervec, v2 - pervec, v2 + pervec
        Render4V(self.img,lt.x, lt.y, 0, rt.x, rt.y, 0, rb.x, rb.y, 0, lb.x, lb.y, 0)
    end
end
local function SpawnPolygon(...)
    return New(marisa_polygon,...)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        task.New(self,function()
            task.Wait(300)
            for count=1, _infinite do
                PlaySound("tan02", 0.1)
                AdvancedFor(4,{"linear",0,360},function(ang)
                    local obj = CreateShotA(self.x,self.y,2,ang+self.timer*math.pi*1.3434,"scale",
                            ColorHSV(255,self.timer,100,100))
                    obj.vx = obj.vx * 3
                end)
                task.Wait(1)
            end
        end)
        local _sign = 1
        local speed = 1.3
        local _sang = 90
        while(true) do
            local angoff = ran:Float(180/30,-180/30)
            PlaySound("kira00", 1)
            AdvancedFor(4,{"linear",1.0,1.0},{"linear",0,0},{"linear",0,32},function(spd,ang,off)
                SpawnPolygon(self.x,self.y,_sign,0+_sang,spd*speed,ang+angoff,0.1*_sign,off)
                SpawnPolygon(self.x,self.y,-_sign,180+_sang,spd*speed,ang+angoff,0.1*_sign,off)
            end)
            _sign = -_sign
            task.Wait(120/speed)
            MoveRandom(self,8,16,lstg.world.l+64,lstg.world.r-64,100,lstg.world.t-80,90/speed)
        end
    end)
end
--[[

        task.New(self,function()
            local wait = 60
            local rad = 90
            while true do
                local obj = CreateShotA(self.x,self.y,0,0,"star",color.White,nil,"add+add")
                obj.omiga = 3
                obj.delay = false
                obj.hscale,obj.vscale = 5,5
                obj.colli = false
                local __smear = New(smear,obj,5,nil,nil,0.2)
                task.New(__smear,function()
                    __smear.colormod = ColorHSV(255,self.timer,100,100)
                end)
                task.New(obj,function()
                    local __x,__y = player.x,player.y
                    DelayLine(obj.x,obj.y,Angle(obj,player),64)
                    task.Wait(60)
                    MoveTo(obj,__x,__y,wait,math.tween.cubicOut)
                    task.Wait(30)
                    AdvancedFor(300,{"linear",0,360},function(__a)
                        local _obj = CreateShotA(obj.x,obj.y,0,__a,"scale",ColorHSV(255,__a,100,100))
                        local _rad = ran:Float(rad*0.2,rad)
                        _obj._blend = "grad+add"
                        task.New(_obj,function()
                            MoveTo(_obj,_obj.x+_rad*cos(__a),_obj.y+_rad*sin(__a),60,math.tween.cubicOut)
                            _obj.colli = false
                            for t=0,1,1/15 do
                                _obj._a = math.lerp(255,0,t)
                                task.Wait(1)
                            end
                            RawDel(_obj)
                        end)
                    end)
                    Del(obj)
                end)
                task.Wait(180)
            end
        end)
--]]

sc.boss_info = marisa_boss_data
return sc