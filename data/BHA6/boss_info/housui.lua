local path = GetCurrentScriptDirectory()
local M = {}
M.name = "Housui Henkawa"
M.title = "Living Battery born from Energy and Entropy"
M.short_name = "Housui"
M.color = Color(255,255,0,255)
M.spell_bg_color = Color(128,64,0,64)
local housui_sprites = LoadImageGroupFromFile("dot_housui",path.."dot_housui.png",true,8,4,16,16,false)
local ms = housui_sprites
local function gsl(x,y) return x+(y-1)*8 end
local housui_std = frame_anim(housui_sprites, {
    gsl(1,1),gsl(1,2),gsl(1,3),gsl(2,1),gsl(2,2)
},8)
local housui_left = side_anim(housui_sprites, {
    gsl(1,1),gsl(3,1),gsl(3,2)
},8)
local housui_right = side_anim(housui_sprites, {
    gsl(1,1),gsl(3,3),gsl(3,4)
},8)
local housui_anim_mngr = ZAnim(true)
housui_anim_mngr:addAnimation(housui_left,"left")
housui_anim_mngr:addAnimation(housui_right,"right")
housui_anim_mngr:addAnimation(housui_std,"stand")
--reimu_anim_mngr.side_frame_max = 8
housui_anim_mngr.side_deadzone = 0.01
M.anim_manager = housui_anim_mngr

return M