local M = zclass(MenuSys.menu)
M.option = zclass(main_menu_option_base)
local path = GetCurrentScriptDirectory()
function M.option:ctor(data,manager)
    self._a = 0
    self.scale = 1.3
    self.onEnter = data[1]
    self.font = option_font
    self.unselect_color = self._color
    self.out_color = Color(255,0,0,0)
    self.select_color = Color(255,0,0,0)
    self.out_unselect_color = Color(255,0,0,0)
    self.out_select_color = Color(255,255,255,255)
    task.NewHashed(self,"select",function()
        task.Wait(2)
        if self.selected then
            local col = self._color
            local ocol = self.out_color
            local ecol = self.select_color
            local eocol = self.out_select_color
            self._r = ecol.r
            self._g = ecol.g
            self._b = ecol.b
            self.out_color.r = eocol.r
            self.out_color.g = eocol.g
            self.out_color.b = eocol.b
        end
    end)
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
    task.NewHashed(self,"select",function()
        task.Wait(5)
        local col = self._color
        local ocol = self.out_color
        local ecol = self.select_color
        local eocol = self.out_select_color
        for i=1, 15 do
            self._r = math.lerp(col.r,ecol.r,i/15)
            self.out_color.r = math.lerp(ocol.r,eocol.r,i/5)
            self._g = math.lerp(col.g,ecol.g,i/15)
            self.out_color.g = math.lerp(ocol.g,eocol.g,i/5)
            self._b = math.lerp(col.b,ecol.b,i/15)
            self.out_color.b = math.lerp(ocol.b,eocol.b,i/5)
            task.Wait(1)
        end
        self._r = ecol.r
        self._g = ecol.g
        self._b = ecol.b
        self.out_color.r = eocol.r
        self.out_color.g = eocol.g
        self.out_color.b = eocol.b
    end)
    menu.selindicator:select(self)
end
function M.option:_unselect()
    task.NewHashed(self,"select",function()
        local col = self._color
        local ocol = self.out_color
        local ecol = self.unselect_color
        local eocol = self.out_unselect_color
        for i=1, 5 do
            self._r = math.lerp(col.r,ecol.r,i/5)
            self.out_color.r = math.lerp(ocol.r,eocol.r,i/5)
            self._g = math.lerp(col.g,ecol.g,i/5)
            self.out_color.g = math.lerp(ocol.g,eocol.g,i/5)
            self._b = math.lerp(col.b,ecol.b,i/5)
            self.out_color.b = math.lerp(ocol.b,eocol.b,i/5)
            task.Wait(1)
        end
        for i=1, 17 do
            self._r = ecol.r
            self._g = ecol.g
            self._b = ecol.b
            self.out_color.r = eocol.r
            self.out_color.g = eocol.g
            self.out_color.b = eocol.b
            task.Wait(1)
        end
    end)
end

M.options = {
    {M.option,"Start Game", { function(self)
        CallClass(self.manager,"switch_menu","start")
    end }},
    {M.option,"Attack Practice", { function()
        Print("AttackP")
    end }},
    {M.option,"Replays", { function()
        Print("Replays")
    end }},
    {M.option,"Options", { function(self)
        CallClass(self.manager,"switch_menu","options")
    end }},
    {M.option,"Extra", { function()
        Print("Extra")
    end }},
    {M.option,"Exit", { function()
        Print("Exit")
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
    self._x, self._y = 50+self.id*50, screen.height/2 - (self.id-#opt_cnt/2) * 80-200
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