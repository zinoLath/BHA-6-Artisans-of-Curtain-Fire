ui = Class(object)
local path = GetCurrentScriptDirectory()
LoadImageFromFile("HUD_image",path ..  "HUD.png",false,0,0)
LoadImageFromFile("ui.div",path ..  "div.png",false,0,0)
LoadImageFromFile("bar_shell",path ..  "bar_shell.png",true,0,0)
LoadImageFromFile("bar_shadow",path ..  "bar_shadow.png",true,0,0)
SetImageColor("bar_shadow", Color(180,255,255,255))
local w,h = GetImageSize("ui.div")
SetImageCenter("ui.div",0,h/2)
w,h = GetImageSize("bar_shell")
SetImageCenter("bar_shell",0,h/2)
LoadFont("menu",font_path.."menu.fnt")
LoadTexture("life_juice", path.."health_scroll.png")
LoadTexture("spell_juice", path.."sp_scroll.png")
LoadTexture("bg_juice", path.."bg_scroll.png")
CopyImage("bar_checker","white")
SetImageState("bar_checker","mul+screen",Color(128,255,255,255))
local hinters = LoadImageGroupFromFile("ui.hinter",path .. "hinters.png",true,1,6,0,0,false)
for k,v in ipairs(hinters) do
    local w,h = GetImageSize(v)
    Print(string.format("name: %s ;width: %d",v,w))
    SetImageCenter(v,0,h/2)
end
LoadFX("blur","shader/blur25.hlsl")
num_font = BMF:loadFont("unispace_bold_lowout",font_path)
local x = 1400
ui.positions = {
    Vector(x,82),
    Vector(x,145),
    Vector(x,265),
    Vector(x,338),
    Vector(x,469),
    Vector(x,525)
}
for k,v in ipairs(ui.positions) do
    v.y = screen.height - v.y
end
ui.DrawOrder = {
    "DrawHiScore", "DrawScore", "DrawLife", "DrawSpell", "DrawPoint", "DrawGraze"
}
ui.draw_vert = {
    {0,0,0,0,0,color.White},
    {1,0,0,1,0,color.White},
    {1,1,0,1,1,color.White},
    {0,1,0,0,1,color.White},
}
ui.pool_vert = {
    {0,0,0,0,0,color.White},
    {1,0,0,1,0,color.White},
    {1,1,0,1,1,color.White},
    {0,1,0,0,1,color.White},
}
ui.bgpool_vert = {
    {0,0,0,0,0,color.White},
    {1,0,0,1,0,color.White},
    {1,1,0,1,1,color.White},
    {0,1,0,0,1,color.White},
}
function ui:DrawFrame()
    RenderRect("HUD_image", screen.dx, screen.width-screen.dx, screen.dy, screen.height-screen.dy)
end
CreateRenderTarget("UI_DROP_SHADOW")
function ui:DrawStats()
    PushRenderTarget("UI_DROP_SHADOW")
    SetImageState("white","",Color(255,255,255,255))
    RenderClear(0)
    ui.DrawShadowed(self)
    PopRenderTarget("UI_DROP_SHADOW")
    local offset = Vector(0.5,1) * -0.005
    PostEffect("blur","UI_DROP_SHADOW",2,"",{ { 7, offset.x, offset.y, 1 }})
    --PostEffect("EMPTY_SHADER","UI_DROP_SHADOW",2,"",{ { 10, 0, 0, 1 }})
    for k,v in ipairs(self.divs) do
        Render("ui.div",v.x,v.y)
    end
end
function ui:DrawShadowed()
    for k,v in ipairs(ui.positions) do
        if ui[ui.DrawOrder[k]] then
            ui[ui.DrawOrder[k]](self,v,k)
        end
    end
end
local function FormatScore(num)
    return string.format("%03d.%03d.%03d",
            math.mod(int(num/1000^2),1000),
            math.mod(int(num/1000^1),1000),
            math.mod(int(num/1000^0),1000))
end
function ui:DrawHiScore(pos,id)
    Render("ui.hinter1",pos.x,pos.y)
    local top_color,bot_color = Color(255,255,255,255), Color(255,186,200,222)
    num_font:renderOutline(FormatScore(lstg.tmpvar.hiscore or lstg.var.score),pos.x+220,pos.y-13,0.85,"left","bottom",
            {top_color,top_color,bot_color,bot_color},nil,4,Color(255*0.75,0,2,21))
    self.divs[id] = Vector(pos.x,pos.y-30)
end
function ui:DrawScore(pos,id)
    Render("ui.hinter2",pos.x,pos.y)
    local top_color,bot_color = Color(255,255,255,255), Color(255,186,200,222)
    num_font:renderOutline(FormatScore(lstg.var.score),pos.x+220,pos.y-13,0.85,"left","bottom",
            {top_color,top_color,bot_color,bot_color},nil,4,Color(255*0.75,0,2,21))
    self.divs[id] = Vector(pos.x,pos.y-30)
end
local scroll_w, scroll_h = GetTextureSize("life_juice")
scroll_w = scroll_w + 1
function ui:DrawLife(pos,id)
    Render("ui.hinter3",pos.x,pos.y)
    local pool_vt = ui.pool_vert
    local bgpool_vt = ui.bgpool_vert
    local draw_vt = ui.draw_vert
    local ratio = math.clamp((lstg.var.lifeleft)/6,0,1)
    local rw,rh = scroll_w*ratio,50
    local tw,th = scroll_w*ratio,scroll_h
    local _u,_v = -self.timer*0.4, 0
    local _x, _y = pos.x+155, pos.y+5
    for k,v in ipairs(pool_vt) do
        local dvt = draw_vt[k]
        v[1] = _x + dvt[1]*rw
        v[2] = _y + (dvt[2]-0.5)*rh
        v[4] = _u + dvt[4]*tw
        v[5] = _v + dvt[5]*th
    end
    local rw2,rh2 = scroll_w,50
    local tw2,th2 = scroll_w,scroll_h
    for k,v in ipairs(bgpool_vt) do
        local dvt = draw_vt[k]
        v[1] = _x + dvt[1]*rw2
        v[2] = _y + (dvt[2]-0.5)*rh2
        v[4] = _u + dvt[4]*tw2
        v[5] = _v + dvt[5]*th2
        v[6] = Color(128,255,64,64)
    end
    local int_life_count = int(ratio*6)/6
    RenderTexture("bg_juice","",unpack(bgpool_vt))
    RenderTexture("life_juice","",unpack(pool_vt))
    SetImageState("bar_checker","mul+screen",Color(255,255,0,0))
    RenderRect("bar_checker",_x,_x+rw2*int_life_count,_y-rh/2,_y+rh/2)
    RenderRect("bar_shadow",_x,_x+rw2,_y-rh/2,_y+rh/2)
    Render("bar_shell",_x-10,_y)
    self.divs[id] = Vector(pos.x,pos.y-30)
end
function ui:DrawSpell(pos,id)
    Render("ui.hinter4",pos.x,pos.y)
    local pool_vt = ui.pool_vert
    local bgpool_vt = ui.bgpool_vert
    local draw_vt = ui.draw_vert
    local ratio = math.clamp((lstg.var.bomb)/6,0,1)
    local rw,rh = scroll_w*ratio,50
    local tw,th = scroll_w*ratio,scroll_h
    local _u,_v = -self.timer*0.4, 0
    local _x, _y = pos.x+155, pos.y+5
    for k,v in ipairs(pool_vt) do
        local dvt = draw_vt[k]
        v[1] = _x + dvt[1]*rw
        v[2] = _y + (dvt[2]-0.5)*rh
        v[4] = _u + dvt[4]*tw
        v[5] = _v + dvt[5]*th
    end
    local rw2,rh2 = scroll_w,50
    local tw2,th2 = scroll_w,scroll_h
    for k,v in ipairs(bgpool_vt) do
        local dvt = draw_vt[k]
        v[1] = _x + dvt[1]*rw2
        v[2] = _y + (dvt[2]-0.5)*rh2
        v[4] = _u + dvt[4]*tw2
        v[5] = _v + dvt[5]*th2
        v[6] = Color(128,64,25,64)
    end
    local int_life_count = int(ratio*6)/6
    RenderTexture("bg_juice","",unpack(bgpool_vt))
    RenderTexture("spell_juice","",unpack(pool_vt))
    SetImageState("bar_checker","mul+screen",Color(200,0,255,0))
    RenderRect("bar_checker",_x,_x+rw2*int_life_count,_y-rh/2,_y+rh/2)
    RenderRect("bar_shadow",_x,_x+rw2,_y-rh/2,_y+rh/2)
    Render("bar_shell",_x-10,_y)
    self.divs[id] = Vector(pos.x,pos.y-30)
end

local function FormatPoint(num)
    local str = tostring(int(num))
    return str
end
function ui:DrawPoint(pos,id)
    Render("ui.hinter5",pos.x,pos.y)
    local top_color,bot_color = Color(255,255,255,255), Color(0xFF779ddd)
    num_font:renderOutline(FormatPoint(lstg.var.pointrate),pos.x+490,pos.y-13,0.85,"right","bottom",
            {top_color,top_color,bot_color,bot_color},nil,4,Color(255*0.75,0,2,21))
    self.divs[id] = Vector(pos.x,pos.y-30)
end
function ui:DrawGraze(pos,id)
    Render("ui.hinter6",pos.x,pos.y)
    local top_color,bot_color = Color(255,255,255,255), Color(0xFFbac8de)
    num_font:renderOutline(FormatPoint(lstg.var.graze),pos.x+490,pos.y-13,0.85,"right","bottom",
            {top_color,top_color,bot_color,bot_color},nil,4,Color(255*0.75,0,2,21))
    self.divs[id] = Vector(pos.x,pos.y-30)
end

function ui:init(stage)
    self.bound = false
    self.colli = false
    self.hide = false
    self.stage = stage
    self.group = GROUP_GHOST
    self.layer = LAYER_UI
    self.divs = {}
end
function ui:render()
    SetViewMode 'ui'
    ui.DrawFrame(self)
    if lstg.var.init_player_data then
        ui.DrawStats(self)
    end
    SetViewMode 'world'
end
function ui:kill()
    PreserveObject(self)
end
function ui:del()
    if not self.deleted then
        PreserveObject(self)
    end
end