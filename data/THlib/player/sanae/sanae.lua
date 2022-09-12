sanae_player = zclass(player_class)
local M = sanae_player
local path = GetCurrentScriptDirectory()

local sanae_sheet = LoadTexture("sanae_sheet", path.."sanae_player.png")
local sanae_std = LoadImageGroup("sanae_std", "sanae_sheet", 0, 0, 32, 48, 8, 1, 0.5, 0.5, false)
local sanae_left = LoadImageGroup("sanae_left", "sanae_sheet", 0, 48, 32, 48, 8, 1, 0.5, 0.5, false)
local sanae_right = LoadImageGroup("sanae_right", "sanae_sheet", 0, 96, 32, 48, 8, 1, 0.5, 0.5, false)

local sanae_std_anim = frame_anim(sanae_std, SizedTable(8),6)
local sanae_left_anim = side_anim(sanae_left,{{1,2,3,4,5},{6,7,8}},6)
local sanae_right_anim = side_anim(sanae_right,{{1,2,3,4,5},{6,7,8}},6)
M.optlist = {
    {
        Vector(-32,15), Vector(-16,20), Vector(16, 20), Vector(32,15)
    },
    {
        Vector(-20,15), Vector(-10,25), Vector(10, 25), Vector(20,15)
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

--sanae_player.init:addEvent(function() error("a")  end, "player.debug")