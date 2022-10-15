_author="LuaSTG User"
_mod_version=4096
_allow_practice=true
_allow_sc_practice=true
local path = GetCurrentScriptDirectory()
Include(path.."lib/misc.lua")
Include(path.."lib/effect.lua")
Include(path.."lib/transition.lua")
Include(path.."lib/bullet_shadows.lua")
Include(path.."background/mistylake.lua")

reimu_boss_data = Include(path.."boss_info/reimu.lua")
suika_boss_data = Include(path.."boss_info/suika.lua")
marisa_boss_data = Include(path.."boss_info/marisa.lua")
housui_boss_data = Include(path.."boss_info/housui.lua")

bha6_boss = zclass(boss)
function bha6_boss:init(cards,anim_manager)
	boss.init(self,cards)
	anim_manager = anim_manager or cards[1].boss_info.anim_manager
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
function NormalStage(self)
	task.Wait(30)
	New(boss_timer)
	New(straight_hpbar)
	local __boss = New(bha6_boss, { rp1, rp2 }); wait_until_death(__boss)
	local __boss = New(bha6_boss, { sp1, sp2 }); wait_until_death(__boss)
	local __boss = New(bha6_boss, { mp1, mp2 }); wait_until_death(__boss)
	local __boss = New(bha6_boss, { hp1, hp2 }); wait_until_death(__boss)

end
function SpellPractice(self)
	New(boss_timer)
	New(straight_hpbar)
	local spell_prac = _sc_table[lstg.var.pat_id]
	local __boss = New(bha6_boss, { spell_prac }); wait_until_death(__boss)

end
stage.group.New('menu',{},"Normal",{lifeleft=2,power=100,faith=50000,bomb=3},true,1)
stage.group.AddStage('Normal','Stage 1@Normal',{lifeleft=7,power=300,faith=50000,bomb=3},true)
stage.group.DefStageFunc('Stage 1@Normal','init',function(self)
	item.PlayerInit()
    difficulty=self.group.difficulty    --New(mask_fader,'open')
    --New(reimu_player)
	New(sanae_player)
	New(bullet_shadow)
    task.NewHashed(self,"main",function()
        do
			New(mistylake_bg)
            -- New(MyScene)
			-- New(G2048)
        end
		if lstg.var.pat_id then
			SpellPractice(self)
		else
			NormalStage(self)
		end
		task.Wait(120)
    end)

    task.New(self,function()
		while coroutine.status(self.task.main)~='dead' do task.Wait() end
		stage.group.FinishReplay()
		if not ext.replay.IsReplay() then
			ext.replay.SaveReplay({"Stage 1@Normal"}, nil, "sanae", 1)
		end
		--New(mask_fader,'close')
		task.New(self,function()
			local _,bgm=EnumRes('bgm')
			for i=1,30 do 
				for _,v in pairs(bgm) do
					if GetMusicState(v)=='playing' then
					SetBGMVolume(v,1-i/30) end
				end
				task.Wait()
			end
		end)
		Transition(function()
			stage.group.ReturnToTitle(true, 1)
		end)
	end)
end)

Include "BHA6\\menu\\main.lua"
do return end
stage_init = stage.New('init', true, true)
function stage_init:init()
	stage.group.Start(stage.groups["Normal"])
end