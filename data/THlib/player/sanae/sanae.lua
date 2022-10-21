sanae_player = zclass(player_class)
local M = sanae_player
local path = GetCurrentScriptDirectory()

LoadImageFromFile("sanae_arrow", path.."sanae_arrow.png",true,64,64,false)
SetImageScale("sanae_arrow",2.25)
SetImageState("sanae_arrow","mul+add",color.White)

local sanae_sheet = LoadTexture("sanae_sheet", path.."sanae_player.png")
local sanae_std = LoadImageGroup("sanae_std", "sanae_sheet", 0, 0, 32, 48, 8, 1, 0.5, 0.5, false)
local sanae_left = LoadImageGroup("sanae_left", "sanae_sheet", 0, 48, 32, 48, 8, 1, 0.5, 0.5, false)
local sanae_right = LoadImageGroup("sanae_right", "sanae_sheet", 0, 96, 32, 48, 8, 1, 0.5, 0.5, false)

LoadTexture("sanae_bomb", path.."sanae_bomb.png")
CopyImage("sanae_bomb_inside","white")
local w,h = GetTextureSize("sanae_bomb")
local sanae_bomb_poly_count = 5
local sanae_bomb_mesh = lstg.MeshData((sanae_bomb_poly_count+1)*2,(sanae_bomb_poly_count+1)*5+2)
local polyc = sanae_bomb_poly_count
for i=0, polyc do
    local ii = i*6
    local vi = i*2
    sanae_bomb_mesh:setIndex(ii+0,vi+0)
    sanae_bomb_mesh:setIndex(ii+1,vi+1)
    sanae_bomb_mesh:setIndex(ii+2,vi+2)
    sanae_bomb_mesh:setIndex(ii+3,vi+1)
    sanae_bomb_mesh:setIndex(ii+4,vi+2)
    sanae_bomb_mesh:setIndex(ii+5,vi+3)
end
sanae_bomb_mesh:setIndex((sanae_bomb_poly_count+1)*5+0,0)
sanae_bomb_mesh:setIndex((sanae_bomb_poly_count+1)*5+1,1)
local function SetupMesh(mesh,x,y,r1,r2,angle,umult,uoff,color,subcolor)
    local polyc = sanae_bomb_poly_count
    for i=0, polyc do
        local _angle = 360*i/polyc+angle
        local vi = i*2
        mesh:setVertex(vi+0,x+cos(_angle)*r1,y+sin(_angle)*r1,0,i*umult+uoff,1,color)
        mesh:setVertex(vi+1,x+cos(_angle)*r2,y+sin(_angle)*r2,0,i*umult+uoff,0,color)
        mesh:setVertexSubColor(vi+0,subcolor)
        mesh:setVertexSubColor(vi+1,subcolor)
    end
end

local anim_indexes = SizedTable(8) --{{1,2,3,4,5},{6,7,8}}
local sanae_std_anim = frame_anim(sanae_std, SizedTable(8),6)
local sanae_left_anim = side_anim(sanae_left, SizedTable(8),6)
local sanae_right_anim = side_anim(sanae_right, SizedTable(8),6)
local ux_spc = 16
local fx_spc = 13
local uy1, uy2 = -20,-15
local fy1, fy2 = -25,15
local uxoff, fxoff = 10,5
M.optlist = {
    {
        Vector(-ux_spc*2-uxoff,uy2), Vector(-ux_spc-uxoff,uy1), Vector(ux_spc+uxoff, uy1), Vector(ux_spc*2+uxoff,uy2)
    },
    {
        Vector(-fx_spc*2-fxoff,fy2), Vector(-fx_spc-fxoff,fy1), Vector(fx_spc+fxoff, fy1), Vector(fx_spc*2+fxoff,fy2)
    }
}
M.optionimg = LoadImageFromFile("sanae_opt", path.."sanae_option.png",true,0,0,false)
function M:init()
    if lstg.var.shot_type == 2 then
        player_class.spawnOptions(self,M.optlist,nil,function(self,opt)
            opt.omiga = 1.3
            opt.lerp_pos = true
        end)
    end
    player_class.init(self)
    local sanae_manager = ZAnim(true)
    sanae_manager:addAnimation(sanae_left_anim,"left")
    sanae_manager:addAnimation(sanae_right_anim,"right")
    sanae_manager:addAnimation(sanae_std_anim,"stand")
    sanae_manager.side_frame_max = 8
    sanae_manager:attachObj(self)
    self.uspeed = 4
    self.fspeed = 2
end
M.shot = Class(player_bullet_straight)
M.shot.type = "sanaeA_shot"
M.shot.dmg = 3
local spdrat = 0.25
function M.shot:kill()
    task.Clear(self)
    PreserveObject(self)
    self.group = GROUP_GHOST
    self.vx, self.vy = self.vx*spdrat, self.vy*spdrat
    task.New(self,function()
        for t=1, 0, -1/15 do
            --local t = i/10
            self._a = 128 * t
            task.Wait(1)
        end
        Del(self)
    end)
end
M.shot2 = Class(M.shot)
M.shot2.type = "sanaeB_shot"
M.shot2.dmg = 2.3
local obj_tsk = function(obj)
    obj.bound = false
    local maxalpha = player.maxalpha or 170
    for t=0, 1, 1/5 do
        --local t = i/10
        obj._a = maxalpha * t
        task.Wait(1)
    end
    obj._a = maxalpha
    obj.bound = true
end
function M:shoot()
    if lstg.var.shot_type == 2 then
        if self.timer % 4 == 0 then
            local roff = 24
            for k,v in ipairs(self.options) do
                local t = (k-1)/(#self.options-1)
                local spread = math.lerp(15,5,self.slowf)
                local ang = math.lerp(spread,-spread,t)
                local spd, angle = 16, 90+ang
                local obj = New(M.shot,"sanae_arrow", v.x - roff * cos(angle), v.y - roff * sin(angle), spd, angle, M.shot.dmg)
                --obj._blend = "mul+add"
                task.New(obj, obj_tsk)
            end
            local spd, angle = 16, 90
            local obj = New(M.shot,"sanae_arrow", self.x - roff * cos(angle), self.y - roff * sin(angle), spd, angle, M.shot.dmg)
            --obj._blend = "mul+add"
            task.New(obj, obj_tsk)
        end
    else
        player.maxalpha = 120
        self.ang_shoot = self.ang_shoot or 0
        self.ang_shoot = self.ang_shoot + 2
        local count = 8
        for i=1, count do
            local roff = 0
            local angle = 360*i/count+self.ang_shoot
            if self.timer % 4 == 0 then
                local spd = 16
                local obj = New(M.shot2,"sanae_arrow", self.x - roff * cos(angle), self.y - roff * sin(angle), spd, angle, M.shot2.dmg)
                task.New(obj, obj_tsk)
                task.New(obj,function()
                    local hom = 10
                    obj.navi = true
                    for i=1, 15 do
                        hom = hom + 1
                        if IsValid(player.target) then
                            local ang = obj.rot + math.clamp(AngleDifference(obj.rot,Angle(obj,player.target)),-hom,hom)
                            SetV(obj,spd,ang)
                        end
                        task.Wait(1)
                    end
                end)
            end
        end
    end
end
function M:spell()
    PlaySound("hyz_exattack",1)
    local bombobj = New(sanae_bomb,self.x,self.y,lstg.var.bomb_type)
    --return IsValid(bombobj)
end

sanae_bomb = Class()
sanae_bomb.type = "sanae_bomb"
function sanae_bomb:init(x,y,_type)
    self.x,self.y = x,y
    self.rad1 = 0
    self.rad2 = 0
    self.bgmult = 0.6
    local extraprot = 120
    self._blend = "grad+alpha"
    self.group = GROUP_SPELL
    self.layer = LAYER_PLAYER_SPELL
    self.killflag = true
    self.omiga = 2
    if _type == 2 then
        self.dmg = 2
        self._color = color.Green
        local max_rad = 180
        local _t = 15+10+15+180+extraprot
        ProtectPlayer(_t)
        player.nextspell = max(_t,player.nextspell)
        task.NewHashed(self,"bombTask", function()
            SetFieldInTime(self,15, math.tween.cubicOut,{"rad2",max_rad})
            --task.Wait(15)
            SetFieldInTime(self,10, math.tween.cubicOut,{"rad1",max_rad-16})
            task.Wait(180)
            SetFieldInTime(self,15, math.tween.cubicOut,{"rad1",max_rad},{"_a",0})
            Del(self)
        end)
    else
        self.dmg = 10
        local max_rad = 128
        self.vy = 10
        self._color = color.Blue
        --self._subcolor = color.Black
        local _t = 15+15+15+60+extraprot
        ProtectPlayer(_t)
        player.nextspell = max(_t,player.nextspell)
        task.NewHashed(self,"bombTask", function()
            SetFieldInTime(self,15, math.tween.cubicOut,{"rad2",max_rad})
            task.Wait(5)
            SetFieldInTime(self,10, math.tween.cubicOut,{"rad1",max_rad-16})
            task.Wait(60)
            SetFieldInTime(self,15, math.tween.cubicOut,{"rad1",max_rad},{"_a",0})
            Del(self)
        end)
        task.New(self,function()
            SetFieldInTime(self,60,math.tween.cubicOut,{"vy",0.2})
        end)
    end
end
function sanae_bomb:frame()
    task.Do(self)
    local _rad = self.rad2+8
    if self.timer % 1 == 0 then
        New(sanae_bomb_smear,self,self.x,self.y,self.rad1,self.rad2,self.rot,2,self.timer/100,self._color,self._subcolor)
    end
    if not self.colli then return end
    ForeachGroup({GROUP_NONTJT,GROUP_ENEMY}, function(group)
        for i,obj in ObjList(group) do
            if PointToPolygon(Vector(obj.x, obj.y),Vector(self.x,self.y),5,_rad,self.rot) then
                Collide(self,obj)
            end
        end
    end)
    for i,obj in ObjList(GROUP_ENEMY_BULLET) do
        if PointToPolygon(Vector(obj.x, obj.y),Vector(self.x,self.y),5,_rad,self.rot) then
            Kill(obj)
        end
    end
end
function sanae_bomb:render()
    local polyc = sanae_bomb_poly_count
    local posv = Vector(self.x,self.y)
    local angle = self.rot
    local c1 = self._color * Color(255*self.bgmult,255,255,255)
    local c2 = self._color - Color(255,0,0,0)
    SetImageState("sanae_bomb_inside","",c1,c1,c2,c2)
    for i=1, polyc do
        local v1 = (Vector.fromAngle(i*360/polyc) * self.rad2):rotate(angle)
        local v2 = (Vector.fromAngle((i+1)*360/polyc) * self.rad2):rotate(angle)
        Render4Vec("sanae_bomb_inside",v1 + posv,v2 + posv,posv,posv)
    end
    SetupMesh(sanae_bomb_mesh,self.x,self.y,self.rad1,self.rad2,angle,2,self.timer/100,self._color,self._subcolor)
    RenderMesh("sanae_bomb",self._blend,sanae_bomb_mesh)
end

sanae_bomb_smear = Class()
function sanae_bomb_smear:init(master,x,y,rad1,rad2,angle,umult,uoff,col,subcol)
    self.x, self.y, self.rad1, self.rad2, self.rot, self.umult, self.uoff, self._color, self.subcolor = x,y,rad1,rad2,angle,umult,uoff,col,col + Color(0,64,64,64)
    self._blend = "grad+add"
    self.layer = master.layer-0.5
end
local fcount = 60
function sanae_bomb_smear:frame()
    local t = self.timer/fcount
    if self.timer > fcount then
        Del(self)
    else
        self._a = (1-t)*255
        self.hscale = 1 + 0.6 * t
    end
end
function sanae_bomb_smear:render()
    SetupMesh(sanae_bomb_mesh,self.x, self.y, self.rad1*self.hscale, self.rad2*self.hscale, self.rot, self.umult, self.uoff,
            self._color, self.subcolor)
    RenderMesh("sanae_bomb",self._blend,sanae_bomb_mesh)
end

--sanae_player.init:addEvent(function() error("a")  end, "player.debug")