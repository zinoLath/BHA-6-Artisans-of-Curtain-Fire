local M = zclass(MenuSys.menu)
M.option = zclass(main_menu_option_base)
local path = GetCurrentScriptDirectory()
M.key_events = deepcopy(M.key_events)
M.repeat_keys = {'menu_up', 'menu_down', 'menu_right', 'menu_left'}
function M.key_events:menu_right()
    local obj1 = self.options[self.selected]
    CallClass(obj1,"hori_scroll",1)
end
function M.key_events:menu_left()
    local obj1 = self.options[self.selected]
    CallClass(obj1,"hori_scroll",-1)
end
M.option2 = zclass(main_menu_option_base)
function M.option2:ctor(data,manager)
    self._a = 0
    self.onEnter = data[1]
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
M.option2._unselect = M.option._unselect
M.option2._select = M.option._select
M.option2._in = M.option._in
M.option2._out = M.option._out
local res_list = lstg.supported_res
local res_names = {}
for k,v in ipairs(res_list) do
    res_names[k] = string.format("%dx%d",v[1],v[2])
end
preconfig = {}
M.options = {
    {option_slider, "Master Volume: ", {onHori = function(self)
        setting.mastervolume = self.fill
        SetBGMVolume(GetBGMVolume() * setting.mastervolume/100)
        SetSEVolume(GetSEVolume() * setting.mastervolume/100)
    end, init_value = setting.mastervolume},
    },
    {option_slider, "BGM Volume: ", {onHori = function(self)
        setting.bgmvolume = self.fill
        SetBGMVolume(setting.bgmvolume/100)
    end, init_value = setting.bgmvolume},
    },
    {option_slider, "SE Volume: ", {onHori = function(self)
        setting.sevolume = self.fill
        SetSEVolume(setting.sevolume/100)
    end, init_value = setting.sevolume},
    },
    {option_multihori, "Resolution: ", {res_names,
                                        onHori = function(self)
                                            local selected = LoopTableK(self.__text,self.__subselect)
                                            preconfig.resx = res_list[selected][1]
                                            preconfig.resy = res_list[selected][2]
                                            preconfig.resid = selected

                                        end,
     function(self)
         setting.resx = preconfig.resx
         setting.resy = preconfig.resy
         setting.resid = preconfig.resid
         ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync)
    end, init_value = setting.resid},
    },
    {option_multihori, "Vsync: ",
     { { "On", "Off" },
       onHori = function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               setting.vsync = true
           else
               setting.vsync = false
           end
       end,
       function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               setting.vsync = true
           else
               setting.vsync = false
           end
           ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync)
       end, init_value = setting.vsync and 1 or 2
    }
    },
    {option_multihori, "Render Skip: ",
     { { "On", "Off" },
       onHori = function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               preconfig.renderskip = true
           else
               preconfig.renderskip = false
           end
       end,
        onEnter = function(self)
            setting.renderskip = preconfig.renderskip
        end
     , init_value = setting.renderskip and 1 or 2
     }
    },
    {option_multihori, "Low Performance Mode: ",
     { { "On", "Off" },
       onHori = function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               preconfig.lowperf = true
           else
               preconfig.lowperf = false
           end
       end,
       onEnter = function(self)
           setting.lowperf = preconfig.lowperf
       end
     , init_value = setting.lowperf and 1 or 2
     }
    },
    {option_multihori, "Auto Shoot: ",
     { { "On", "Off" },
       onHori = function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               setting.autoshoot = true
           else
               setting.autoshoot = false
           end
       end, init_value = setting.autoshoot and 1 or 2
     }
    },
    {option_slider, "Bullet Shadows: ", {onHori = function(self)
        setting.bulshadows = self.fill
    end, init_value = setting.bulshadows},
    },
    {option_slider, "Background Brightness: ", {onHori = function(self)
        setting.bgbright = self.fill
    end, init_value = setting.bgbright},
    },
    {option_multihori, "One Life in Practice: ",
     { { "On", "Off" },
       onHori = function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               setting.replaydeath = true
           else
               setting.replaydeath = false
           end
       end, init_value = setting.replaydeath and 1 or 2
     }
    },
    {option_multihori, "Judge Mode: ",
     { { "On", "Off" },
       onHori = function(self)
           local selected = LoopTable(self.__text,self.__subselect)
           if selected == "On" then
               setting.judging = true
           else
               setting.judging = false
           end
       end, init_value = setting.judging and 1 or 2
     }
    },
    {option_base, "Save and Return", {function(self)
        for k,v in pairs(preconfig) do
            setting[k] = v
        end
        saveConfigure()
        SetBGMVolume(setting.bgmvolume/100 * setting.mastervolume/100)
        SetSEVolume(setting.sevolume/100 * setting.mastervolume/100)
        ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync)
        CallClass(self.manager,"go_back")
    end}
     }
}

M.select_indicator = zclass()
function M.select_indicator:init(menu)
    self.bound = false
    self.group = GROUP_MENU
    self.layer = LAYER_MENU+20
    self.vscale = 0
    self.menu = menu
    self.off_scale = self.menu.options[self.menu.selected].scale
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
    local sanae = self.menu.manager.sanae
    CallClass(sanae,"goOut")
    SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",1})
end
function M.select_indicator:_out()
    CallClass(self.menu.manager.sanae,"goIn")
    SetFieldInTime(self,5,math.tween.cubicInOut,{"vscale",0})
end
function M.select_indicator:frame()
    self.off_scale = math.lerp(self.off_scale,self.menu.options[self.menu.selected].scale,0.1)
    task.Do(self)
end
function M.select_indicator:render()
    SetViewMode("ui")
    SetImageState("select_indicator","",Color(200,0,0,0))
    Render("select_indicator",self.x,self.y+0*self.off_scale,self.rot,self.hscale*1000,self.vscale*4)
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
    self._x, self._y = 450, screen.height/2 - (self.id-#opt_cnt/2) * 60
    self.scale = 0.7
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