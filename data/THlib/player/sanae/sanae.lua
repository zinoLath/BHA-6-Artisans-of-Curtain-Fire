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
    player_class.spawnOptions(self,M.optlist,nil,function(self,opt)
        opt.omiga = 1.3
        opt.lerp_pos = true
    end)
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
local obj_tsk = function(obj)
    obj.bound = false
    local maxalpha = 170
    for t=0, 1, 1/5 do
        --local t = i/10
        obj._a = maxalpha * t
        task.Wait(1)
    end
    obj._a = maxalpha
    obj.bound = true
end
function M:shoot()
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
end

--sanae_player.init:addEvent(function() error("a")  end, "player.debug")