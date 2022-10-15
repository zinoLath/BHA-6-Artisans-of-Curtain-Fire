option_base = zclass(main_menu_option_base)
local path = GetCurrentScriptDirectory()

function option_base:ctor(data,manager)
    self._a = 0
    self.onEnter = data.onEnter or data[1]
    self.font = option_font
    self.unselect_color = self._color
    self.out_color = Color(255,0,0,0)
    self.select_color = Color(255,0,0,0)
    self.out_unselect_color = Color(255,0,0,0)
    self.out_select_color = Color(255,255,255,255)
    task.New(self,function()
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
function option_base:_in()
    self.active = true
    SetFieldInTime(self, 60, math.tween.cubicInOut, {"_a",255})
end
function option_base:_out()
    self.active = false
    SetFieldInTime(self, 30, math.tween.cubicInOut, {"_a",0})
end
function option_base:_select()
    local menu = self.menu
    task.New(self,function()
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
function option_base:_unselect()
    task.New(self,function()
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
option_multihori = Class(option_base)
function option_multihori:ctor(data,manager)
    self._a = 0
    self.__subselect = data.init_value or data[3] or 0
    self.onHori = data.onHori
    self.onEnter = data.onEnter or data[2]
    self.__text = data[1]
    self.__alphas = {}
    for k,v in ipairs(data[1]) do
        self.__alphas[k] = 0
    end
    self.font = option_font
    self.unselect_color = self._color
    self.out_color = Color(255,0,0,0)
    self.select_color = Color(255,0,0,0)
    self.out_unselect_color = Color(255,0,0,0)
    self.out_select_color = Color(255,255,255,255)
    task.New(self,function()
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
function option_multihori:hori_scroll(id)
    self.__subselect = self.__subselect+id
    CallClass(self, "onHori")
end
function option_multihori:render()
    SetViewMode("ui")
    if self.img then
        DefaultRenderFunc(self)
        return
    end
    local font = self.font or self.class.font
    font:renderOutline(self.tid,self.x,self.y,self.scale,"right","bottom",
            self._color+color.Black,self.offset_func,self.out_size or 4,self.out_color or color.Black,"",self._a/255)
    local selected = LoopTableK(self.__alphas,self.__subselect)
    self.selected_text = self.__text[selected]
    for k,v in ipairs(self.__alphas) do
        if k == selected then
            self.__alphas[k] = SnapLerp(self.__alphas[k],1,0.2)
        else
            self.__alphas[k] = SnapLerp(self.__alphas[k],0,0.2)
        end
        if self.__alphas[k] ~= 0 then
            font:renderOutline(self.__text[k],self.x,self.y,self.scale,"left","bottom",
                    self._color+color.Black,self.offset_func,self.out_size or 4,self.out_color or color.Black,"",
                    self._a*self.__alphas[k]/255)
        end
    end
end
CopyImage("option_bar_default", "white")
CopyImage("option_barbg_default", "white")
option_slider = Class(option_base)
function option_slider:ctor(data,manager)
    self._a = 0
    self.onEnter = data[2]
    local bar_info = {} or data[1]
    self.total_step = bar_info.total_step or 100
    self.shift_step = bar_info.shift_step or 5
    self.ctrl_step = bar_info.ctrl_step or 1
    self.normal_step = bar_info.normal_step or 10
    self.barimg = bar_info.barimg or "option_bar_default"
    self.barimgbg = bar_info.barimg or "option_barbg_default"
    self.barcolor = bar_info.barcolor or color.White
    self.barcolorbg = bar_info.barcolorbg or Color(128,0,0,0)
    self.bg_out = bar_info.bg_out or 5
    self.width = bar_info.width or 500
    self.height = bar_info.height or 32
    self.baryoff = (bar_info.baryoff or 0) * self.scale
    self.fill = data.init_value or data[3]
    self.onHori = data.onHori or data[4]
    self.setBar = data[5]
    CallClass(self,"setBar")
    self.font = option_font
    self.unselect_color = self._color
    self.out_color = Color(255,0,0,0)
    self.select_color = Color(255,0,0,0)
    self.out_unselect_color = Color(255,0,0,0)
    self.out_select_color = Color(255,255,255,255)
    task.New(self,function()
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
function option_slider:hori_scroll(id)
    local isctrl = SysKeyIsDown("menu_ctrl")
    local isshift = SysKeyIsDown("menu_shift")
    local step = id
    if isctrl then
        step = step * self.ctrl_step
    elseif isshift then
        step = step * self.shift_step
    else
        step = step * self.normal_step
    end
    self.fill = math.clamp(self.fill + step, 0, self.total_step)
    CallClass(self,"onHori")
end
function option_slider:render()
    SetViewMode("ui")
    if self.img then
        DefaultRenderFunc(self)
        return
    end
    local font = self.font or self.class.font
    font:renderOutline(self.tid,self.x,self.y,self.scale,"right","bottom",
            self._color+color.Black,self.offset_func,self.out_size or 4,self.out_color or color.Black,"",self._a/255)
    local o2 = self.bg_out
    local ac = Color(self._a,255,255,255)

    SetImageState(self.barimgbg,"",self.barcolorbg * ac)
    SetImageState(self.barimg,"",self.barcolor * ac)
    RenderRect(self.barimgbg,self.x-o2,self.x + self.width+o2,
            self.y-self.height/2+self.baryoff-o2,self.y+self.height/2+self.baryoff+o2)
    RenderRect(self.barimg,self.x,self.x + self.width*(self.fill/self.total_step),
            self.y-self.height/2+self.baryoff,self.y+self.height/2+self.baryoff)
end