local path = GetCurrentScriptDirectory()
local MenuSys = MenuSys

option_font = BMF:loadFont("sabado",font_path)
option_font.movescale = 1.1
option_font.chars.i.xadvance = option_font.chars.i.xadvance*1.2
main_menu_option_base = zclass(MenuSys.option)
function main_menu_option_base:render()
    SetViewMode("ui")
    if self.img then
        DefaultRenderFunc(self)
        return
    end
    local pool = self.pool or self.class.pool
    if pool then
        BMF:renderPool(pol,self.x,self.y,self.scale,9999999,self.timer)
    end
    local font = self.font or self.class.font
    if not font then
        SetFontState("menu","",self._color)
        RenderText('menu',self.tid,self.x,self.y,0.6*2.25*self.scale,'center')
    elseif type(font) == "table" then
        font:renderOutline(self.tid,self.x,self.y+0*self.scale,self.scale,"left","bottom",
                self._color+color.Black,self.offset_func,self.out_size or 4,self.out_color or color.Black,"",self._a/255)
    else
        SetFontState(font,self._blend,self._color)
        RenderText(font,self.tid,self.x,self.y,0.6*2.25*self.scale,'center')
    end
end
LoadMusic("title_song",path.."JamTitle.ogg",0,0)
LoadImageFromFile("main_menu_bg",path.."mainmenu_bg.png")
LoadTexture("scroll_mainmenu",path.."scroll.png")
LoadImageFromFile("sanae_title",path.."sanae.png")
sanae_title = Class()
function sanae_title:init()
    self.img = "sanae_title"
    self.bound = false
    self._x, self._y = screen.width-500,screen.height/2
    self._initx,self._inity = self._x, self._y
    self.x = self._x
    self.y = self._y
    local scale = 0.8
    self.hscale, self.vscale = 0.5*scale,0.5*scale
    self.layer = LAYER_MENU+70
end
function sanae_title:frame()
    task.Do(self)
    self.x = self._x
    self.y = self._y+10*sin(self.timer)
    self.rot = 2*sin(self.timer/2)
end
function sanae_title:_in(x,y,t)
    SetFieldInTime(self,t or 60,math.tween.cubicOut,{"_a",255},{"_x",x or self._initx},{"_y",y or self._inity})
end
function sanae_title:_out(x,y,a,t)
    SetFieldInTime(self,t or 60,math.tween.cubicOut,{"_a",a or 0},{"_x",x or self._x + 60},{"_y",y or self._y})
end
function sanae_title:goIn(...)
    local args = {...}
    task.NewHashed(self,"inOut",function()
        CallClass(self,"_in",unpack(args))
    end)
end
function sanae_title:goOut(...)
    local args = {...}
    task.NewHashed(self,"inOut",function()
        CallClass(self,"_out",unpack(args))
    end)
end
local M = {}
M.manager = zclass(MenuSys.manager)
M.manager.name = "MainMenuManager"
M.manager.intro_menu = "main"
function M.manager:ctor()
    self.layer = LAYER_BG
    self.dropshadow = New(menu_dropshadow)
    self.sanae = New(sanae_title)
end
function M.manager:render()
    SetViewMode("ui")
    RenderRect("main_menu_bg",0,screen.width,0,screen.height)
    local x,y = screen.width,screen.height*0.5
    local tx,ty = self.timer,self.timer*0.1
    RenderTexture("scroll_mainmenu","",
            {0,y,0,0+tx,y+ty,Color(0,255,255,255)},
            {x,y,0,x+tx,y+ty,Color(0,255,255,255)},
            {x,0,0,x+tx,0+ty,Color(128,255,255,255)},
            {0,0,0,0+tx,0+ty,Color(128,255,255,255)}
    )
end
local optdef = Include(path.."option_def.lua")
local submenu_path = path.."submenu/"
local main = Include(submenu_path.."main.lua")
local start = Include(submenu_path.."start.lua")
local spell_prac = Include(submenu_path.."spell_prac.lua")
local replay = Include(submenu_path.."replay.lua")
local options = Include(submenu_path.."options.lua")
M.manager.menus = {
    {main, "main"},
    {start, "start"},
    {spell_prac, "spell_prac"},
    {options, "options"},
    {replay, "replay"}
}

CreateRenderTarget("MENU_DROP_SHADOW")
menu_dropshadow_push = zclass(object)
function menu_dropshadow_push:init(anchor)
    self.anchor = anchor
    self.bound = false
    self.colli = false
    self.layer = LAYER_MENU-70
end
function menu_dropshadow_push:frame()
    if not IsValid(self.anchor) then
        RawDel(self)
        return
    end
end
function menu_dropshadow_push:render()
    if not IsValid(self.anchor) then
        RawDel(self)
        return
    end
    PushRenderTarget("MENU_DROP_SHADOW")
    RenderClear(0)
end
menu_dropshadow = zclass(object)
function menu_dropshadow:init()
    self.offset = Vector(80,60)
    New(menu_dropshadow_push,self)
    self.layer = LAYER_MENU+1000
end
function menu_dropshadow:render()
    PopRenderTarget("MENU_DROP_SHADOW")
    local offset = self.offset * -0.0001
    PostEffect("blur","MENU_DROP_SHADOW",2,"",{ { 5, offset.x, offset.y, 0.5 }})
    --PostEffect("EMPTY_SHADER","MENU_DROP_SHADOW",2,"",{ { 10, 0, 0, 1 }})
end

local fftimg = CopyImage("fftimg","white")
stage_init = stage.New("menu",true,true)
function stage_init:init()
    New(M.manager)
end