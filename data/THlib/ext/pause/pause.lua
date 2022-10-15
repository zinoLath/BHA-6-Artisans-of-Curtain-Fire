local path = GetCurrentScriptDirectory()
local MenuSys = MenuSys
local M = {}
local deathmusic = 'deathmusic'--疮痍曲

LoadMusic(deathmusic, 'THlib/music/player_score.ogg', 34.834, 27.54)
M.manager = zclass(MenuSys.manager)
pause_menu = M.manager
M.manager.name = "PauseManager"
M.manager.intro_menu = "main"
LoadTexture("pausemenu_halftone", path.."uihalftone.png")
local submenu_path = path.."submenu/"
local main = Include(submenu_path.."main.lua")
M.manager.menus = {
    {main, "main"}
}
CopyImage("pausemenu_bg","white")
CopyImage("select_indicator","white")

function M.manager:init(opt_list)
    opt_list = opt_list or {
        { "Resume", "resume" },
        { "Return to Title", "quit" },
        { "Restart", "restart" }
    }
    self.pausable = false
    for k,v in ipairs(opt_list) do
        if v[2] == "resume" then
            self.pausable = true
        end
    end
    lstg.is_paused = true
    self.color = Color(0)
    MenuSys.manager.init(self,opt_list)
    self.vert = {
        {0,0,0,0,0,color.White},
        {1,0,0,1,0,color.White},
        {1,1,0,1,1,color.White},
        {0,1,0,0,1,color.White},
    }
    self.dirty_vert = {
        {0,0,0,0,0,color.White},
        {1,0,0,1,0,color.White},
        {1,1,0,1,1,color.White},
        {0,1,0,0,1,color.White},
    }
    task.New(self,function()
        for i=0, 1, 1/30 do
            self.color = InterpolateColor(Color(0), Color(255,0,0,0),i)
            task.Wait(1)
        end
    end)
end
function M.manager:exit()
    task.New(self, function()
        local menu = self.stack[0]
        local menu_opts = menu.options
        CallClass(self,"kill")
        task.New(self,function()
            for i=1, 0, -1/60 do
                self.color = InterpolateColor(Color(0), Color(255,0,0,0),i)
                task.Wait(1)
            end
        end)
        while true do
            local is_dead = false
            for k,v in ipairs(menu_opts) do
                is_dead = is_dead or v.status ~= "normal"
            end
            if is_dead then
                break
            end
            task.Wait(1)
        end
        lstg.is_paused = false
        self.active = false
        task.Wait(30)
        RawKill(self)
    end)
end
function M.manager:render()
    SetViewMode("ui")
    SetImageState("pausemenu_bg","",InterpolateColor(self.color,Color(0),0.5))
    RenderRect("pausemenu_bg",0,screen.width,0,screen.height)
    for k,v in ipairs(self.dirty_vert) do
        local dv = self.vert[k]
        v[1] = dv[1] * screen.width
        v[2] = dv[2] * screen.height
        v[4] = dv[4] * screen.width + self.timer
        v[5] = -dv[5] * screen.height + self.timer
        v[6] = InterpolateColor(self.color,Color(0),0.2)
    end
    RenderTexture("pausemenu_halftone","",unpack(self.dirty_vert))
    SetViewMode("world")
end
function M.manager:executeEvent(event)
    Event:call("pause_menu_on" .. event,self)
    if event == "resume" then
        CallClass(self,"exit")
    end
    if event == "quit" then
        StopMusic(deathmusic)
        Transition(function()
            stage.group.ReturnToTitle(false, 0)
        end)
    end
    if event == "quit_replay" then
        StopMusic(deathmusic)
        if not ext.replay.IsReplay() then
            ext.replay.SaveReplay({"Stage 1@Normal"}, nil, "sanae", 1)
        end
        Transition(function()
            stage.group.ReturnToTitle(true, 0)
        end)
    end
    if event == "restart" then
        StopMusic(deathmusic)
        Transition(function()
            stage.Restart()
        end)
    end
    if event == "continue" then
        StopMusic(deathmusic)
        local temp = lstg.var.score or 0
        lstg.var.score = 0
        item.PlayerReinit()
        lstg.tmpvar.hiscore = lstg.tmpvar.hiscore or 0
        if lstg.tmpvar.hiscore < temp then
            lstg.tmpvar.hiscore = temp
        end
        stage.stages[stage.current_stage.group.title].save_replay = nil
        CallClass(self,"exit")
    end
end

Event:new("onStgFrame",function()
    if not stage.current_stage then return end
    if stage.current_stage.group and SysKeyIsPressed("menu") and not IsValid(lstg.tmpvar.pausemenu) then
        lstg.tmpvar.pausemenu = New(M.manager,{
            { "Resume", "resume" },
            { "Return to Title", "quit" },
            { "Restart", "restart" }
        })
    end
end,"pauseGame")