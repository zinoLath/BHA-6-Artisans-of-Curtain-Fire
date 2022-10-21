local path = GetCurrentScriptDirectory()
local M = {}
M.name = "Housui Henkawa"
M.title = "Living Battery born from Energy and Entropy"
M.short_name = "Housui"
M.color = Color(255,255,0,255)
M.spell_bg_color = Color(128,64,0,64)
local housui_sprites = LoadImageGroupFromFile("dot_housui",path.."dot_housui.png",true,2,3,16,16,false)
local ms = housui_sprites
local function gsl(x,y) return x+(y-1)*8 end
local housui_std = frame_anim(housui_sprites, {
    1,2,1
},8)
local housui_left = side_anim(housui_sprites, {
    3,4
},8)
local housui_right = side_anim(housui_sprites, {
    5,6
},8)
local housui_anim_mngr = ZAnim(true)
housui_anim_mngr:addAnimation(housui_left,"left")
housui_anim_mngr:addAnimation(housui_right,"right")
housui_anim_mngr:addAnimation(housui_std,"stand")
--reimu_anim_mngr.side_frame_max = 8
housui_anim_mngr.side_deadzone = 0.01
M.anim_manager = housui_anim_mngr
--M.song = LoadMusic("housui_theme",path.."housui_theme.ogg",0,0)

return M