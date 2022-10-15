mistylake_bg = Class(background)
local path = GetCurrentScriptDirectory()
LoadImageFromFile("noiseTex", path.."noiseTexture.png")
LoadImageFromFile("skybox", path.."skybox.png")
LoadImageFromFile("mountains", path.."mountains.png")
LoadImageFromFile("worter", path.."worter.png")
SetImageState("worter","",Color(170,255,255,255))
CopyImage("bg_black","white")
CreateRenderTarget("BG_WATER")
LoadFX("BG_WATER_SHADER", path.."water.fx")
function mistylake_bg:init()
    background.init(self,false)
    Reset3D()
    self.fog_color = Color(0)
    lstg.view3d.fog = { 0,0, self.fog_color}
    lstg.view3d.eye = { 0, 3, -3 }
    lstg.view3d.at = { 0, 0, -1 }
    self.scroll_speed = 10
    self.scroll = 0
    self.spell_color = Color(128,64,0,0,0)
    self.spell_t = 0
    self.is_spell = false
    local shadow = 240
    local water_color = Color(255,78, 163, 194)
    local water_color_shadow = water_color * Color(255,shadow,shadow,shadow)
    local water_color_highlight = InterpolateColor(water_color,Color(255,255, 200, 64),0.6)
    self.water = {
        {water_color.r/255,water_color.g/255,water_color.b/255,water_color.a/255},
        {water_color_shadow.r/255,water_color_shadow.g/255,water_color_shadow.b/255,water_color_shadow.a/255},
        {water_color_highlight.r/255,water_color_highlight.g/255,water_color_highlight.b/255,water_color_highlight.a/255},
    }
    task.New(self,function()
        while not KeyIsPressed("special") do
            task.Wait(1)
        end
        CallClass(self,"viewSun")
    end)
end
function mistylake_bg:frame()
    task.Do(self)
    lstg.view3d.fog[3] = self.fog_color
    self.scroll = self.scroll + self.scroll_speed
end
function mistylake_bg:viewSun(t)
    task.NewHashed(self,"camMovement",function()
        SetFieldInTime(lstg.view3d.at,t or 300,math.tween.cubicOut,{3,3})
    end)
    task.NewHashed(self,"scrollMovement",function()
        SetFieldInTime(self,t or 300,math.tween.cubicOut,{"scroll_speed",0})
    end)
end
function mistylake_bg:render()
    SetViewMode("3d")
    RenderClear(lstg.view3d.fog[3])
    local scale = 20
    local y_level = -0.5
    local yl = y_level
    local zdist = 0.5
    local v1, v2, v3, v4 = Vector3(-3,yl*2,-zdist)/2,Vector3(1,yl*2,-zdist)/2, Vector3(1,yl*2,zdist)/2, Vector3(-3,yl*2,zdist)/2
    local water_scroll = int(lstg.view3d.eye[3]/scale)
    local uv_mult = 64
    local scroll_speed = 0.7
    local uv_scrollx = self.timer*scroll_speed/math.pi
    local uv_scrolly = self.timer*scroll_speed*1.23434
    local uvscy = self.scroll
    local uv_offx = 120
    local uv_offy = 60
    local cwn = Color(128,90,128,255)
    local cwf = Color(128,255,0,255)
    --SetImageState("noiseTex","grad+alpha",color.DarkCyan)
    --SetImageSubColor("noiseTex",color.Orange)
    local fog_color = lstg.view3d.fog[3]
    lstg.view3d.fog[3] = Color(0)
    local _x = lstg.view3d.eye[1]
    local _x1, _x2 = _x-scale,_x+scale
    local _y1, _y2 = 60,yl*scale
    local _z = zdist*5*scale
    local _z2 = zdist*5*scale-0.5
    Render4V("skybox",_x1,_y1,_z,_x2,_y1,_z,_x2,_y2,_z,_x1,_y2,_z)
    SetImageState("mountains","", Color(255,255,255,255))
    Render4V("mountains",_x1,_y1,_z2,_x2,_y1,_z2,_x2,_y2,_z2,_x1,_y2,_z2)
    PushRenderTarget("BG_WATER")
    RenderClear(0)
    SetViewMode("3d",true)
    for x_count = 0, 1 do
        for y_count = 0, 5 do
            local offset = Vector3(x_count+lstg.view3d.eye[1]/scale,0,y_count*zdist+lstg.view3d.eye[3]/scale)*scale
            local _v1 = (v1)*scale+offset
            local _v2 = (v2)*scale+offset
            local _v3 = (v3)*scale+offset
            local _v4 = (v4)*scale+offset
            local t1 = (y_count/5)
            local t2 = ((y_count+1)/5)
            local cw1 = InterpolateColor(cwn,cwf,1-t1)
            local cw2 = InterpolateColor(cwn,cwf,1-t2)
            --[[
            RenderTexture("noiseTex","",
                    {_v1.x, _v1.y, _v1.z,
                        _v1.x*uv_mult+uv_scrollx+uv_offx*(x_count),_v1.z*uv_mult+uv_scrolly+uv_offy*(y_count),cw},
                    {_v2.x, _v2.y, _v2.z,
                        _v2.x*uv_mult+uv_scrollx+uv_offx*(x_count+1),_v2.z*uv_mult+uv_scrolly+uv_offy*(y_count),cw},
                    {_v3.x, _v3.y, _v3.z,
                        _v3.x*uv_mult+uv_scrollx+uv_offx*(x_count+1),_v3.z*uv_mult+uv_scrolly+uv_offy*(y_count+1),cw},
                    {_v4.x, _v4.y, _v4.z,
                        _v4.x*uv_mult+uv_scrollx+uv_offx*(x_count),_v4.z*uv_mult+uv_scrolly+uv_offy*(y_count+1),cw})
            RenderTexture("noiseTex","",
                    {_v1.x, _v1.y, _v1.z,
                     _v1.x*uv_mult-uv_scrollx-uv_offx*(x_count),_v1.z*uv_mult-uv_scrolly-uv_offy*(y_count),cw},
                    {_v2.x, _v2.y, _v2.z,
                     _v2.x*uv_mult-uv_scrollx-uv_offx*(x_count+1),_v2.z*uv_mult-uv_scrolly-uv_offy*(y_count),cw},
                    {_v3.x, _v3.y, _v3.z,
                     _v3.x*uv_mult-uv_scrollx-uv_offx*(x_count+1),_v3.z*uv_mult-uv_scrolly-uv_offy*(y_count+01),cw},
                    {_v4.x, _v4.y, _v4.z,
                     _v4.x*uv_mult-uv_scrollx-uv_offx*(x_count),_v4.z*uv_mult-uv_scrolly-uv_offy*(y_count+1),cw})
           --]]
            ---[[
            for k=1, 3 do

                RenderTextureT("noiseTex","",
                        _v1.x, _v1.y, _v1.z,
                        _v1.x*uv_mult+uv_scrollx+uv_offx*(x_count),_v1.z*uv_mult+uv_scrolly+uv_offy*(y_count)+uvscy,cw1,
                        _v2.x, _v2.y, _v2.z,
                        _v2.x*uv_mult+uv_scrollx+uv_offx*(x_count+1),_v2.z*uv_mult+uv_scrolly+uv_offy*(y_count)+uvscy,cw1,
                        _v3.x, _v3.y, _v3.z,
                        _v3.x*uv_mult+uv_scrollx+uv_offx*(x_count+1),_v3.z*uv_mult+uv_scrolly+uv_offy*(y_count+1)+uvscy,cw2,
                        _v4.x, _v4.y, _v4.z,
                        _v4.x*uv_mult+uv_scrollx+uv_offx*(x_count),_v4.z*uv_mult+uv_scrolly+uv_offy*(y_count+1)+uvscy,cw2)
                RenderTextureT("noiseTex","",
                        _v1.x, _v1.y, _v1.z,
                        _v1.x*uv_mult-uv_scrollx-uv_offx*(x_count),_v1.z*uv_mult-uv_scrolly-uv_offy*(y_count)+uvscy,cw1,
                        _v2.x, _v2.y, _v2.z,
                        _v2.x*uv_mult-uv_scrollx-uv_offx*(x_count+1),_v2.z*uv_mult-uv_scrolly-uv_offy*(y_count)+uvscy,cw1,
                        _v3.x, _v3.y, _v3.z,
                        _v3.x*uv_mult-uv_scrollx-uv_offx*(x_count+1),_v3.z*uv_mult-uv_scrolly-uv_offy*(y_count+1)+uvscy,cw2,
                        _v4.x, _v4.y, _v4.z,
                        _v4.x*uv_mult-uv_scrollx-uv_offx*(x_count),_v4.z*uv_mult-uv_scrolly-uv_offy*(y_count+1)+uvscy,cw2)
            end
              --]]
        end
    end
    PopRenderTarget("BG_WATER")
    lstg.view3d.fog[3] = fog_color
    --SetViewMode("3d",true)
    PostEffect("BG_WATER_SHADER","BG_WATER",6,"",self.water)
    SetImageState("mountains","", Color(32,255,255,255))
    Render4V("mountains",_x1,-_y1,_z2,_x2,-_y1,_z2,_x2,_y2,_z2,_x1,_y2,_z2)
    local ymult = 0.2
    local zmult = -0.3
    local yy2 = -9.5
    Render4V("worter",_x1,-_y1*ymult,_z2*zmult,_x2,-_y1*ymult,_z2*zmult,_x2,yy2,_z2,_x1,yy2,_z2)
    SetViewMode("world")
    local __l,__r,__b,__t = -1000,1000,-1000,1000
    SetImageState("bg_black","",InterpolateColor(Color(0),Color(150,0,0,0),1-((setting.bgbright or 0)/100)))
    RenderRect("bg_black",__l,__r,__b,__t)
    if self.is_spell then
        SetImageState("bg_black","",(self.spell_color) * Color(255 * self.spell_t, 255,255,255))
        RenderRect("bg_black",__l,__r,__b,__t)
    end
end