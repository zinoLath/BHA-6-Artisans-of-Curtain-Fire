local path = GetCurrentScriptDirectory()
local M = {}
M.name = "Suika Ibuki"
M.title = "Mountain Deva of the Earth and Hell"
M.short_name = "Suika"
M.color = Color(255,255,128,0)
M.spell_bg_color = Color(128,64,32,0)
local suika_sprites = LoadImageGroupFromFile("dot_suika",path.."dot_suika.png",true,8,4,16,16,false)
local ms = suika_sprites
local function gsl(x,y) return x+(y-1)*8 end
local suika_std = frame_anim(suika_sprites, {
    gsl(1,1),gsl(1,2),gsl(1,3),gsl(2,1),gsl(2,2)
},8)
local suika_left = side_anim(suika_sprites, {
    gsl(1,1),gsl(3,1),gsl(3,2)
},8)
local suika_right = side_anim(suika_sprites, {
    gsl(1,1),gsl(3,3),gsl(3,4)
},8)
local suika_anim_mngr = ZAnim(true)
suika_anim_mngr:addAnimation(suika_left,"left")
suika_anim_mngr:addAnimation(suika_right,"right")
suika_anim_mngr:addAnimation(suika_std,"stand")
--reimu_anim_mngr.side_frame_max = 8
suika_anim_mngr.side_deadzone = 0.01
M.anim_manager = suika_anim_mngr
--M.song = LoadMusic("suika_theme",path.."suika_theme.ogg",0,0)

return M