boss_particle_trail = Class()
local boss_particle_instance = Class()
function boss_particle_trail:init(boss)
    if boss.particle_trail then
        RawDel(boss.particle_trail)
    end
    self.bound = false
    self.layer = boss.layer - 10
    self.anim = boss.animManager
    self.boss = boss
    boss.particle_trail = self
    self.maxf = 15
    self.maxscale = 2
    self.c1,self.c2 = Color(64,255,64,64),Color(0,255,255,255)
    self.freq = 4
end
function boss_particle_trail:frame()
    if not IsValid(self.boss) then
        Del(self)
        return
    end
    task.Do(self)
    if self.timer % self.freq == 0 then
        New(boss_particle_instance,self.boss.x,self.boss.y,self.anim:getImage(),self.boss.hscale,self.maxf,self.maxscale,self.c1,self.c2)
    end
end

function boss_particle_instance:init(x,y,img,scale,maxf,maxscale,color1,color2)
    self.layer = LAYER_ENEMY-10
    self.x, self.y = x,y
    self.img = img
    self.maxf = maxf
    self._blend = "mul+add"
    self.scale = scale
    self.maxscale = maxscale
    self.c1 = color1
    self.c2 = color2
end
function boss_particle_instance:frame()
    if self.timer > self.maxf then
        Del(self)
    end
    local t = self.timer/self.maxf
    local scale = math.lerp(self.scale,self.scale*self.maxscale,t)
    local color = InterpolateColor(self.c1,self.c2,t)
    self.hscale, self.vscale = scale,scale
    self._color = color
end

function ReimuWarp(self,x,y,loop,t,tween,loopy)
    local prevmaxf = self.particle_trail.maxf
    local maxscale = self.particle_trail.maxscale
    local prevfreq = self.particle_trail.freq
    local colli = self.colli
    self.colli = false
    self.particle_trail.maxf = t/math.abs(loop)
    self.particle_trail.maxscale = 1
    self.particle_trail.freq = 1
    tween = tween or math.tween.circInOut
    local w = (lstg.world.r-lstg.world.l)
    local h = (lstg.world.t-lstg.world.b)
    local _x, _y = w*loop + x, y + h*(loopy or 0)
    local initx, inity = self.x, self.y
    local posx, posy = initx, inity
    for i=1, t do
        local t = tween(i/t)
        posx = math.lerp(initx,_x,t)
        posy = math.lerp(inity,_y,t)
        self.x = (posx-lstg.world.l) % w + lstg.world.l
        self.y = (posy-lstg.world.b) % h + lstg.world.b
        coroutine.yield()
    end
    self.particle_trail.maxf = prevmaxf
    self.particle_trail.maxscale = maxscale
    self.particle_trail.freq = prevfreq
    self.colli = colli
end

function MoveCurveDown(self, x2_, y2_, time_, curveScale_, tween_, maxt)
    maxt = maxt or 1
    local x1 = self.x;
    local y1 = self.y;

    local angle = NormalizeAngle(atan2(y2_ - y1, x2_ - x1));
    local angleN = (90 <= angle and angle <= 270) and angle - 90 or angle + 90;

    local dist = hypot(y2_ - y1, x2_ - x1);
    local midDist = dist / 2;

    local controlDist = dist * curveScale_;

    local xC = x1 + midDist * cos(angle) + controlDist * cos(angleN);
    local yC = y1 + midDist * sin(angle) + controlDist * sin(angleN);

    for t=1, time_ do
        local interp = tween_(t*maxt/time_)*maxt
        self.x, self.y = Interpolate_QuadraticBezier(x1,x2_,xC,interp), Interpolate_QuadraticBezier(y1,y2_,yC,interp)
        task.Wait(1)
    end

    return;
end

function PlayBossTheme(theme)
    do return end
    if lstg.var.current_theme then
        local v = lstg.var.current_theme
        task.New(stage.current_stage,function()
            AdvancedFor(30,{"linear",0,1,true},function(t)
                if GetMusicState(v)=='playing' then
                    SetBGMVolume(v,math.lerp(1,0,math.tween.cubicOut(t)))
                end
                task.Wait(1)
            end)
            StopMusic(v)
        end)
    end
    PlayMusic(theme)
    lstg.var.current_theme = theme
    SetBGMVolume(theme,0)
    task.New(stage.current_stage,function()
        AdvancedFor(30,{"linear",0,1,true},function(t)
            if GetMusicState(theme)=='playing' then
                SetBGMVolume(theme,math.lerp(0,1,math.tween.cubicOut(t)))
            end
            task.Wait(1)
        end)
    end)

end