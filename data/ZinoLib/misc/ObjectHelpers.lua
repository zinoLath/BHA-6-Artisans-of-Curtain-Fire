function MoveTo(obj,x,y,t,tween)
    local initx = obj.x
    local inity = obj.y
    tween = tween or math.tween.quadInOut
    for i=1, t do
        local t = tween(i/t)
        obj.x = math.lerp(initx,x,t)
        obj.y = math.lerp(inity,y,t)
        coroutine.yield()
    end
    return obj
end
function MoveToV(obj,v,t,tween)
    MoveTo(obj,v.x,v.y,t,tween)
end
function MoveRandom(obj,rangemin,rangemax,xmin,xmax,ymin,ymax,t,tween)
    local ang = ran:Float(0,360)
    local range = ran:Float(rangemin,rangemax)
    local nextx = cos(ang)*range
    local nexty = sin(ang)*range
    local finalx, finaly = obj.x + nextx, obj.y + nexty
    if math.clamp(finalx,xmin, xmax) ~= finalx then
        nextx = -nextx
    end
    if math.clamp(finaly,ymin, ymax) ~= finaly then
        nexty = -nexty
    end
    finalx, finaly = obj.x + nextx, obj.y + nexty
    if math.clamp(finalx,xmin, xmax) ~= finalx then
        finalx = math.clamp(finalx,xmin, xmax)
    end
    if math.clamp(finaly,ymin, ymax) ~= finaly then
        finaly = math.clamp(finaly,ymin, ymax)
    end
    MoveTo(obj,finalx,finaly,t,tween)
end
function MoveRandomV(obj,range,bound,t,tween)
    MoveRandom(obj,range.x,range.y,bound.l,bound.r,bound.b,bound.t,t,tween)
end
function KillGroup(group)
    for i,obj in ObjList(group) do
        Kill(obj)
    end
end
function DelGroup(group)
    for i,obj in ObjList(group) do
        Del(obj)
    end
end
function KillEnemies()
    KillGroup(GROUP_ENEMY)
    KillGroup(GROUP_NONTJT)
end
function DelEnemies()
    DelGroup(GROUP_ENEMY)
    DelGroup(GROUP_NONTJT)
end
function KillBullets()
    KillGroup(GROUP_ENEMY_BULLET)
    KillGroup(GROUP_INDES)
end
function DelBullets()
    DelGroup(GROUP_ENEMY_BULLET)
    DelGroup(GROUP_INDES)
end
function ForeachGroup(groups,func)
    for _,group in ipairs(groups) do
        func(group)
    end
end
function IsGroupBullet(group)
    return group == GROUP_ENEMY_BULLET or group == GROUP_INDES
end
function IsGroupEnemy(group)
    return group == GROUP_ENEMY_BULLET or group == GROUP_NONTJT
end