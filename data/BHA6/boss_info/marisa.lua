local path = GetCurrentScriptDirectory()
local M = {}
M.name = "Marisa Kirisame"
M.title = "Ordinary Magician of the Sky and Cosmos"
M.short_name = "Marisa"
M.color = Color(255,255,255,0)
M.spell_bg_color = Color(128,64,64,0)
local marisa_sprites = LoadImageGroupFromFile("dot_marisa",path.."dot_marisa.png",true,8,4,16,16,false)
local ms = marisa_sprites
local function gsl(x,y) return x+(y-1)*8 end
local marisa_std = frame_anim(marisa_sprites, {
    gsl(1,1),gsl(1,2),gsl(1,3),gsl(2,1),gsl(2,2)
},8)
local marisa_left = side_anim(marisa_sprites, {
    gsl(1,1),gsl(3,1),gsl(3,2)
},8)
local marisa_right = side_anim(marisa_sprites, {
    gsl(1,1),gsl(3,3),gsl(3,4)
},8)
local marisa_anim_mngr = ZAnim(true)
marisa_anim_mngr:addAnimation(marisa_left,"left")
marisa_anim_mngr:addAnimation(marisa_right,"right")
marisa_anim_mngr:addAnimation(marisa_std,"stand")
--reimu_anim_mngr.side_frame_max = 8
marisa_anim_mngr.side_deadzone = 0.01
M.anim_manager = marisa_anim_mngr
M.song = LoadMusic("marisa_theme",path.."marisa_theme.ogg",0,0)

return M