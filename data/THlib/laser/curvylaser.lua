curvy_laser = Class()
function curvy_laser:init(x,y,img,width,node_count,_color)
    self.x, self.y = x,y
    self.img = img or "laser"
    self.__w = width or 16
    self.w = width or 32
    self.len = node_count or 64
    self.data = BentLaserData()
    self.layer = LAYER_ENEMY_BULLET+10
    self.group = GROUP_INDES
    self._blend = "add+add"
    self._color = _color or color.Red
    self.bound = false
    self._bound = true
    self.update_laser = true
end
function curvy_laser:frame()
    task.Do(self)
    if self.update_laser then
        self.data:Update(self,self.len,self.__w)
    end
    local is_colli = self.data:CollisionCheckWidth(player.x, player.y, player.rot, player.a, player.b,-self.__w*0.3, player.rect)
    if self.colli and is_colli then
        Collide(self,player)
    end
    self.bound = false
    if self._bound and (not self.data:BoundCheck()) then
        Del(self)
    end
end
function curvy_laser:render()
    local ux, uy, uw, uh = GetImageUV(self.img)
    local tex = GetImageTexture(self.img)
    self.data:Render(tex, self._blend, self._color, ux, uy, uw, uh, self.hscale*1)
end
function curvy_laser:del()
    self.data:Release()
end
function curvy_laser:kill()
    self.data:Release()
end

warning_curvy = Class()
CopyImage("curvy_white","white")
function warning_curvy:init(x,y,img,width,node_count,_color)
    self.x, self.y = x,y
    self.img = img or "curvy_white"
    self.__w = width or 2
    self.w = width or 2
    self.len = node_count or 64
    self.data = BentLaserData()
    self.layer = LAYER_ENEMY_BULLET+10
    self.group = GROUP_INDES
    self._blend = "mul+alpha"
    self._color = _color or color.Red
    self.bound = false
    self._bound = true
    self.update_laser = true
end
function warning_curvy:frame()
    task.Do(self)
    if self.update_laser then
        self.data:Update(self,self.len,self.w)
    end
    self.bound = false
    if self._bound and (not self.data:BoundCheck()) then
        Del(self)
    end
end
function warning_curvy:render()
    local ux, uy, uw, uh = GetImageUV(self.img)
    local tex = GetImageTexture(self.img)
    self.data:Render(tex, self._blend, self._color, ux, uy, uw, uh, self.hscale*1)
end
function warning_curvy:del()
    self.data:Release()
end
function warning_curvy:kill()
    self.data:Release()
end

function CreateCurvyLaser(x,y,img,width,node_count,_color)
    return New(curvy_laser,x,y,img,width,node_count,_color)
end
function CreateCurvyWarning(x,y,img,width,node_count,_color)
    return New(warning_curvy,x,y,img,width,node_count,_color)
end