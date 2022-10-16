local M = zclass(MenuSys.menu)
M.option = zclass(MenuSys.option)
function M.option:ctor()
    self._a = 0
end
function M.option:_in()
    self.active = true
    SetFieldInTime(self, 60, math.tween.cubicInOut, {"_a",255})
end
function M.option:_out()
    self.active = false
    SetFieldInTime(self, 30, math.tween.cubicInOut, {"_a",0})
end
function M.option:_select()
    local menu = self.menu
    menu.selindicator:select(self)
end
function M.option:_unselect()
end

M.select_indicator = zclass()
function M.select_indicator:init(menu)
    self.bound = false
    self.group = GROUP_MENU
    self.layer = LAYER_MENU-10
    self.vscale = 0
    self.menu = menu
    menu._servants = menu._servants or {}
    table.insert(self.menu._servants,self)
    self.select = function(self,obj)
        SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",0})
        self.y = obj.y - 30
        SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",1})
    end
    task.New(self,function()
        self:select(menu.options[1])
    end)
end
function M.select_indicator:frame()
    task.Do(self)
end
function M.select_indicator:render()
    SetViewMode("ui")
    SetImageState("select_indicator","",color.Black)
    Render("select_indicator",self.x,self.y,self.rot,self.hscale*1000,self.vscale*4)
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

M.key_events = deepcopy(M.key_events)
function M.key_events:menu()
    if self.manager.pausable and self.timer > 1 then
        CallClass(self.manager,"go_back")
    end
end
function M.key_events:retry()
    if self.manager.retry and self.timer > 1 then
        CallClass(self.manager,"executeEvent","restart")
    end
end
function M:init(manager,tb)
    self.option_def = {}
    for k,v in ipairs(tb) do
        self.option_def[k] = {M.option, v[1], function( )  pause_menu.executeEvent(self.manager,v[2],self) end}
    end
    MenuSys.menu.init(self,manager)
    for k,v in pairs(self.option_def) do
        self.options[k].onEnter = v[3]
    end
end
function M:ctor()
    self.scroll_wait2 = 10
    self.selindicator = New(M.select_indicator,self)
end
function M:obj_init(menu)
    local opt_cnt = menu.option_def or menu.class.options
    self._x, self._y = screen.width/2, screen.height/2 - (self.id-#opt_cnt/2) * 80
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