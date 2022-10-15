local center = Vector(0,100)
local sc = boss.card:new("6th Degree of Separation ~ Love Dive", 60, 6, 2, 600, false)
function sc:before()
    New(boss_particle_trail,self)
end
local function ShapeTask(obj)
    obj.bound = false
    task.Wait(900/obj._spd)
    Del(obj)
end
local function SpawnPolygon(x,y,_sign,_sang,spd,initang,_somiga,roff)
    local shape_list1 = {}
    spd = spd or 1
    _somiga = _somiga or 0
    initang = initang or 0
    local obj_count = 35
    local star_color = _sign == 1 and color.Red or color.Blue
    AdvancedFor(obj_count,{"linear",0,360},function(_ang)
        local _x, _y = x,y
        local _obj = CreateShotA(_x,_y,0,0,"smallstar",star_color)
        _obj.omiga = 3
        _obj._spd = spd
        local __sign = _sign
        task.New(_obj,function()
            --do return end
            while(true) do
                local poly_vec = Vector.fromPolygon(3,(_ang + _obj.timer * 0.1 * __sign+initang)/360):rotated(_sang+_obj.timer*_somiga) * (_obj.timer*spd-roff)
                _obj.x = _x + poly_vec.x
                _obj.y = _y + poly_vec.y
                task.Wait(1)
            end
        end)
        table.insert(shape_list1,_obj)
        task.New(_obj,ShapeTask)
    end)
    --[[
    AdvancedFor(obj_count,{"linear",0-ang_diff,360-ang_diff},function(_ang)
        local poly_vec = Vector.fromPolygon(4,(_ang)/360):rotated(_sang+ang_diff)
        local _obj = CreateShotA(self.x,self.y,poly_vec.length*spd*1,poly_vec.angle,"smallstar",color.Blue)
        table.insert(shape_list2,_obj)
        task.New(_obj,ShapeTask)
    end)
    --]]
    local final_shape = {}
    for i=1, #shape_list1,1 do
        if IsValid(shape_list1[i]) then
            table.insert(final_shape,shape_list1[i])
        end
        --table.insert(final_shape,shape_list2[i])
    end
    local node_count = 64
    local tspace = obj_count*0.4
    local tspeed = spd*_sign*obj_count/(8*30)
    local crobj = CreateCurvyLaser(x,y,nil,nil,node_count,color.Yellow)
    crobj.update_laser = false
    crobj._bound = false
    local crobjW = CreateCurvyLaser(x,y,nil,nil,node_count,color.Purple * Color(64,255,255,255))
    crobjW.update_laser = false
    crobjW._bound = false
    crobjW.colli = false
    local crline = CreateCurvyWarning(x,y,nil,nil,node_count,(star_color + Color(255,128,128,128)) * Color(200,255,255,255))
    crline.update_laser = false
    crline._bound = false
    task.New(crobj,function()
        --do return end
        local x_pos, y_pos = {},{}
        local x_pos1, y_pos1 = {},{}
        local x_pos2, y_pos2 = {},{}
        local vec_list = {}
        for i=1, _infinite do
            for k,v in ipairs(final_shape) do
                if not IsValid(v) then
                    Del(crobj)
                    Del(crobjW)
                    Del(crline)
                    return
                end
                vec_list[k] = Vector(v.x,v.y)
                x_pos1[k] = v.x
                y_pos1[k] = v.y
            end
            x_pos1[#final_shape+1] = x_pos1[1]
            y_pos1[#final_shape+1] = y_pos1[1]
            for i=1, node_count do
                local vec = Vector.list_lerp(vec_list,crobj.timer*tspeed + tspace*i/node_count - 2)
                x_pos[i] = vec.x
                y_pos[i] = vec.y
                local vec2 = Vector.list_lerp(vec_list,crobj.timer*tspeed + tspace*i/node_count - 2+8*_sign)
                x_pos2[i] = vec2.x
                y_pos2[i] = vec2.y
            end
            crobj.data:UpdateAllNode(node_count-2, x_pos, y_pos, crobj.w)
            crobjW.data:UpdateAllNode(node_count-2, x_pos2, y_pos2, crobj.w)
            crline.data:UpdateAllNode(#x_pos1, x_pos1, y_pos1, 4)
            task.Wait(1)
        end
    end)
end
function sc:init()
    task.New(self,function()
        MoveToV(self,center,60,math.tween.quadOut)
        local _sign = 1
        local speed = 2
        local _sang = 90
        while(true) do
            local angoff = ran:Float(180/30,-180/30)
            AdvancedFor(4,{"linear",1.0,1.0},{"linear",0,0},{"linear",0,32},function(spd,ang,off)
                SpawnPolygon(self.x,self.y,_sign,0+_sang,spd*speed,ang+angoff,0.1*_sign,off)
                SpawnPolygon(self.x,self.y,-_sign,180+_sang,spd*speed,ang+angoff,0.1*_sign,off)
            end)
            _sign = -_sign
            task.Wait(60/speed)
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