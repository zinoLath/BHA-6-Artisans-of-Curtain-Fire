_author="LuaSTG User"
_mod_version=4096
_allow_practice=true
_allow_sc_practice=true
local path = GetCurrentScriptDirectory()
Include(path.."lib/misc.lua")
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
test_boss = zclass(boss)
function test_boss:init(cards)
	boss.init(self,cards)
	local boss_anim_mngr = ZAnim(true)
	boss_anim_mngr:addAnimation(reimu_left,"left")
	boss_anim_mngr:addAnimation(reimu_right,"right")
	boss_anim_mngr:addAnimation(reimu_std,"stand")
	--boss_anim_mngr.side_frame_max = 8
	boss_anim_mngr.side_deadzone = 0.01
	boss_anim_mngr:attachObj(self)
	self.x = lstg.world.r + 100
	self.y = lstg.world.t + 200
end
local sc1 = require("BHA6.patterns.reimu_non1")
local sc2 = require("BHA6.patterns.suika_non1")
local sc3 = require("BHA6.patterns.marisa_non1")
local sc4 = require("BHA6.patterns.housui_non1")
sc1.cutin_img = LoadImageFromFile("nicki_cutin",path.."cutin.png")
sc2.cutin_img = LoadImageFromFile("nicki_cutin",path.."cutin.png")
sc3.cutin_img = LoadImageFromFile("nicki_cutin",path.."cutin.png")
SetImageScale("nicki_cutin",1.2)
--table.insert(test_boss.patterns, sc1)
table.insert(test_boss.patterns, sc2)
--table.insert(test_boss.patterns, sc3)
stage.group.New('menu',{},"Normal",{lifeleft=2,power=100,faith=50000,bomb=3},true,1)
stage.group.AddStage('Normal','Stage 1@Normal',{lifeleft=7,power=300,faith=50000,bomb=3},true)
stage.group.DefStageFunc('Stage 1@Normal','init',function(self)
	item.PlayerInit()
    difficulty=self.group.difficulty    --New(mask_fader,'open')
    --New(reimu_player)
	New(DEBUG_BG)
	New(sanae_player)
    task.New(self,function()
        do
            -- New(river_background)
            -- New(MyScene)
			-- New(G2048)
        end
		task.Wait(120)
		New(test_boss, test_boss.patterns)
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

--do return end
stage_init = stage.New('init', true, true)
function stage_init:init()
	stage.group.Start(stage.groups["Normal"])
end