local path = GetCurrentScriptDirectory()
CreateRenderTarget("TRANSITION_MASK")
CreateRenderTarget("TRANSITION_LOAD")
LoadFX("mask",path.."mask.fx")
local scroll = 0
local animations = {}
LoadTexture("loading_scroll",path.."loading_scroll.png")
LoadImageFromFile("loading_screen",path.."loading_screen.png")
lstg.itrans = 0
function Transition(event,_in,_out,t1,t2,t3)
    t1 = t1 or 30
    t2 = t2 or 0
    t3 = t3 or 30
    task.New(lstg.gtasks,function()
        lstg.is_paused = true
        SetFieldInTime(lstg,t1,math.tween.cubicOut,{"itrans",1})
        task.Wait(t2/2)
        event()
        task.Wait(t2/2)
        lstg.is_paused = false
        SetFieldInTime(lstg,t3,math.tween.cubicOut,{"itrans",0})
    end)
end
function DrawLoading()
    SetViewMode("ui")
    RenderRect("loading_screen",0,screen.width,0,screen.height)
    scroll = scroll + 1
    local scrollx, scrolly = scroll,scroll
    local cw = Color(170,255,0,255)
    local l,r,t,b = 0,screen.width,0,screen.height
    local uv_mult = 0.7
    RenderTextureT("loading_scroll","",
                    l,t,0,l*uv_mult+scrollx,t*uv_mult+scrolly,cw,
                    r,t,0,r*uv_mult+scrollx,t*uv_mult+scrolly,cw,
                    r,b,0,r*uv_mult+scrollx,b*uv_mult+scrolly,cw,
                    l,b,0,l*uv_mult+scrollx,b*uv_mult+scrolly,cw
    )
end
CopyImage("transition_square","white")
function DrawMask()
    SetViewMode("ui")
    local i = lstg.itrans or 0
    local _t = i
    for _x = 0, 16 do
        for _y = 0, 9 do
            local x = math.lerp(0,screen.width,_x/16)
            local y = math.lerp(0,screen.height,_y/9)
            local scale = math.lerp(0,12,_t)
            Render("transition_square",x,y,lstg.timer,scale,scale)
        end
    end
end
Event:new("onAfterRender",function()
    if lstg.itrans > 0.001 then
        PushRenderTarget("TRANSITION_MASK")
        RenderClear(0)
        DrawMask()
        PopRenderTarget("TRANSITION_MASK")
        PushRenderTarget("TRANSITION_LOAD")
        RenderClear(0)
        DrawLoading()
        PopRenderTarget("TRANSITION_LOAD")
        PostEffect("mask","TRANSITION_LOAD",6,"",{{0,0,0,0}},{{ "TRANSITION_MASK", 6 }})
    end
end)