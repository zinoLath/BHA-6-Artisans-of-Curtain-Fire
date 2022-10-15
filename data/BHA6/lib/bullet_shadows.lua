local path = GetCurrentScriptDirectory()
bullet_shadow = Class()
local bullet_shadow_push = Class()
CreateRenderTarget("RT:BULLET_SHADOW")
function bullet_shadow:init()
    self.rtname = "RT:BULLET_SHADOW"
    self.layer = LAYER_ENEMY_BULLET+100
    self.push = New(bullet_shadow_push,self,LAYER_ENEMY_BULLET-20)
    self.args = { { 7, 0,0, 1 }}
end
function bullet_shadow:render()
    PopRenderTarget(self.rtname)
    local alpha = setting.bulshadows/50
    self.args[1][4] = alpha
    if alpha == 0 then
        self.hide = true
    end
    PostEffect("blur",self.rtname,2,"",self.args)
end

function bullet_shadow_push:init(master,layerb)
    self.master = master
    self.rtname = self.master.rtname
    self.layer = layerb
end
function bullet_shadow_push:render()
    if self.master.hide then
        return
    end
    PushRenderTarget(self.master.rtname)
    RenderClear(0)
end

function bullet_shadow_push:kill()
    PreserveObject(self)
end
function bullet_shadow_push:del()
    PreserveObject(self)
end
function bullet_shadow:kill()
    PreserveObject(self)
end
function bullet_shadow:del()
    PreserveObject(self)
end