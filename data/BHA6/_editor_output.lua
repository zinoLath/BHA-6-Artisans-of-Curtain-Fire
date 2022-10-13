_author="LuaSTG User"
_mod_version=4096
_allow_practice=true
_allow_sc_practice=true
local path = GetCurrentScriptDirectory()
Include(path.."lib/misc.lua")
Include(path.."lib/effect.lua")
Include(path.."background/mistylake.lua")
--region load_anim
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
--endregion
bha6_boss = zclass(boss)
function bha6_boss:init(cards,anim_manager)
	boss.init(self,cards)
	anim_manager = anim_manager or reimu_anim_mngr
	local boss_anim_mngr = anim_manager:copy()
	boss_anim_mngr:attachObj(self)
	self.x = lstg.world.pr + 64
	self.y = lstg.world.pt + 64
end
local function wait_until_death(__boss)
	while IsValid(__boss) and not __boss.noncombat do
		task.Wait(1)
	end
end
local rp1 = require("BHA6.patterns.reimu_non1")
local rp2 = require("BHA6.patterns.reimu_spell1")
local sp1 = require("BHA6.patterns.suika_non1")
local sp2 = require("BHA6.patterns.suika_spell1")
local mp1 = require("BHA6.patterns.marisa_non1")
local mp2 = require("BHA6.patterns.marisa_spell1")
local hp1 = require("BHA6.patterns.housui_non1")
local hp2 = require("BHA6.patterns.housui_spell1")
stage.group.New('menu',{},"Normal",{lifeleft=2,power=100,faith=50000,bomb=3},true,1)
stage.group.AddStage('Normal','Stage 1@Normal',{lifeleft=7,power=300,faith=50000,bomb=3},true)
stage.group.DefStageFunc('Stage 1@Normal','init',function(self)
	item.PlayerInit()
    difficulty=self.group.difficulty    --New(mask_fader,'open')
    --New(reimu_player)
	New(sanae_player)
    task.New(self,function()
        do
			New(mistylake_bg)
            -- New(MyScene)
			-- New(G2048)
        end
		New(cutin_border)
		task.Wait(_infinite)
		New(boss_timer)
		New(straight_hpbar)
		local __boss = New(bha6_boss, { rp1},reimu_anim_mngr); wait_until_death(__boss)
		local __boss = New(bha6_boss, { sp2, sp1 },suika_anim_mngr); wait_until_death(__boss)
		local __boss = New(bha6_boss, { rp2},reimu_anim_mngr); wait_until_death(__boss)
		local __boss = New(bha6_boss, { mp1},marisa_anim_mngr); wait_until_death(__boss)
		local __boss = New(bha6_boss, { hp2, hp1 },housui_anim_mngr); wait_until_death(__boss)
		local __boss = New(bha6_boss, { mp2},marisa_anim_mngr); wait_until_death(__boss)
		while true do
			task.Wait(1)
		end
    end)

    task.New(self,function()
		while coroutine.status(self.task[1])~='dead' do task.Wait() end
		stage.group.FinishReplay()
		New(mask_fader,'close')
		task.New(self,function()
			local _,bgm=EnumRes('bgm')
			for i=1,30 do 
				for _,v in pairs(bgm) do
					if GetMusicState(v)=='playing' then
					SetBGMVolume(v,1-i/30) end
				end
				task.Wait()
		end end)
		task.Wait(30)
		stage.group.FinishStage()
	end)
end)

Include "BHA6\\menu\\main.lua"
--do return end
stage_init = stage.New('init', true, true)
function stage_init:init()
	stage.group.Start(stage.groups["Normal"])
end