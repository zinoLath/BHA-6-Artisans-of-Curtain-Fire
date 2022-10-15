local M = zclass(MenuSys.menu)
local path = GetCurrentScriptDirectory()

M.key_events = deepcopy(M.key_events)
function M.key_events:menu_right()
    local obj1 = self.options[self.selected]
    CallClass(obj1,"hori_scroll",1)
end
function M.key_events:menu_left()
    local obj1 = self.options[self.selected]
    CallClass(obj1,"hori_scroll",-1)
end
M.options = {
    {option_multihori,"Shot Type: ", { { "Rolling Thunder", "Spread Wind" }
    ,onHori = function(self)
            local selected = LoopTableK(self.__text,self.__subselect)
            lstg.var.shot_type = selected
    end }},
    {option_multihori,"Special Type: ", { { "Bomb", "Hyper" }
    , onHori = function()
            local selected = LoopTableK(self.__text,self.__subselect)
            lstg.var.bomb_type = selected
    end }},
    {option_multihori,"Sub Type: ", { { "Burst Bonus", "Communication Collection" }
    , onHori = function()
            local selected = LoopTableK(self.__text,self.__subselect)
            lstg.var.sub_type = selected
    end }},
    {option_base,"Go!!!!!", {onEnter = function()
        lstg.var.pat_id = nil
        Transition(function()
            stage.group.Start(stage.groups["Normal"])
        end)
        end }},
}

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
            SetFieldInTime(self,10,math.tween.linear,{"y",obj.y})
        else
            self.y = obj.y-30
            SetFieldInTime(self,10,math.tween.cubicInOut,{"vscale",1})
        end
    end
end
function M.select_indicator:_in()
    local _id = self.menu.selected
    self.y = self.menu.options[_id].y
    SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",1})
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
    Render("select_indicator",self.x,self.y,self.rot,self.hscale*1000,self.vscale*4)
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
    self._x, self._y = 500, screen.height/2 - (self.id-#opt_cnt/2) * 80-100
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