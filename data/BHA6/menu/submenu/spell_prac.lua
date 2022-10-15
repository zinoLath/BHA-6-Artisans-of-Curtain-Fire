local M = zclass(MenuSys.menu)
M.option = zclass(main_menu_option_base)
local path = GetCurrentScriptDirectory()
function M:init(manager)
    self.option_def = {{option_base, "s", { function()
    end }}}
    local tb = _sc_table
    for k,v in ipairs(tb) do
        local tid = v.name
        if tid == "" then
            tid = v.boss_info.short_name .. "'s Nonspell"
        end
        self.option_def[k] = {option_base, tid, { function()
            lstg.var.pat_id = k
            Transition(function()
                stage.group.Start(stage.groups["Normal"])
            end)
        end, boss_info = v.boss_info, pattern = v, pattern_id = k }}
    end
    MenuSys.menu.init(self,manager)
end

M.select_indicator = zclass()
function M.select_indicator:init(menu)
    self.bound = false
    self.group = GROUP_MENU
    self.layer = LAYER_MENU+20
    self.vscale = 0
    self.menu = menu
    menu._servants = menu._servants or {}
    table.insert(self.menu._servants,self)
    self.select = function(self,obj)
        if self.vscale ~= 0 then
            SetFieldInTime(self,10,math.tween.linear,{"y",obj.y},{"x",obj.x},{"vscale",obj.scale})
        else
            self.y = obj.y
            self.x = obj.x
            SetFieldInTime(self,10,math.tween.cubicInOut,{"vscale",obj.scale})
        end
    end
end
function M.select_indicator:_in()
    local _id = self.menu.selected
    self.y = self.menu.options[_id].y
    self.x = self.menu.options[_id].x
    SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",self.menu.options[_id].scale})
end
function M.select_indicator:_out()
    SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",0})
end
function M.select_indicator:frame()
    task.Do(self)
end
function M.select_indicator:render()
    SetViewMode("ui")
    SetImageState("select_indicator","",Color(200,0,0,0))
    Render("select_indicator",self.x+200,self.y,self.rot,self.hscale*1000,self.vscale*4)
    --RenderRect("select_indicator",0,1000,self.y-32,self.y+32)
    SetViewMode("world")
end
function M.select_indicator:kill()
    PreserveObject(self)
    task.New(self,function()
        task.Wait(0)
        SetFieldInTime(self,30,math.tween.cubicInOut,{"vscale",0})
        RawDel(self)
    end)
end
function M:ctor()
    self.scroll_wait2 = 10
    self.selindicator = New(M.select_indicator,self)
end
function M:obj_init(menu)
    local opt_cnt = menu.option_def or menu.class.options
    self._x, self._y = 50 , screen.height-self.id*80-50
    self.scale = 0.9
    self.delx = -400
    self.dely = self._y
    self.x = self._x
    self.y = self._y
end
function M:changeSelect(...)
    local arg = {...}
    task.New(self,function()
        MenuSys.menu.changeSelect(self,unpack(arg))
    end)
end
return M