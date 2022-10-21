local path = GetCurrentScriptDirectory()
local M = {}
M.name = "Reimu Hakurei"
M.title = "Shrine Maiden of Balance and Paradise"
M.short_name = "Reimu"
M.color = Color(255,255,0,0)
M.spell_bg_color = Color(128,64,0,0)
local reimu_sprites = LoadImageGroupFromFile("dot_reimu",path.."dot_reimu.png",true,8,4,16,16,false)
local rs = reimu_sprites
local function gsl(x,y) return x+(y-1)*8 end
local reimu_std = frame_anim(reimu_sprites, {
    gsl(1,1),gsl(1,2),gsl(1,3)
},8)
local reimu_left = side_anim(reimu_sprites, {
    gsl(1,1),gsl(3,1),gsl(3,2)
},8)
local reimu_right = side_anim(reimu_sprites, {
    gsl(1,1),gsl(3,3),gsl(3,4)
},8)
local reimu_anim_mngr = ZAnim(true)
reimu_anim_mngr:addAnimation(reimu_left,"left")
reimu_anim_mngr:addAnimation(reimu_right,"right")
reimu_anim_mngr:addAnimation(reimu_std,"stand")
--reimu_anim_mngr.side_frame_max = 8
reimu_anim_mngr.side_deadzone = 0.01
M.anim_manager = reimu_anim_mngr
M.song = LoadMusic("reimu_theme",path.."reimu_theme.ogg",0,0)

return M