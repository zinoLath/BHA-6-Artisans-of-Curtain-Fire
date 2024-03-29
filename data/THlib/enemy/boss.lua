local base_enemy = enemybase
local path = GetCurrentScriptDirectory()
local lerp = math.lerp
local event = lstg.eventDispatcher


boss = zclass(base_enemy)
local M = boss
M.patterns = {}
function M:init(cards)
    base_enemy.init(self,999999,false,self.class.anim_manager)
    self.colli = true
    self.group = GROUP_ENEMY
    self.cardlist = { }
    for k,v in pairs(cards) do
        self.cardlist[k] = v
    end
    self.img = "parimg10"
    self.hscale, self.vscale = 3,3
    self.bound = false
    self.cards = cards or self.class.patterns
    self.current_card = cards[1]
    self.card_num = 0
    self.current_card = self.cards[1]
    self.hp = 1000
    self.cardco = coroutine.create(self.current_card.coroutine or self.class.card_coroutine)
    self.ui_time = 0
    --self.hpbar = New(circular_hpbar,self)
    --self.hpbar = New(straight_hpbar,self)
    --self.timer_obj = New(boss_timer,self)
    self.a, self.b = 32,32
    self.rect = false
    self.bonus = item.sc_bonus_max
    self.skip_card = false
    self.dmg_red_ratio = 1
    self.dmg_list = {}
    _boss = self
end
function M:frame()
    self.dmg_red_ratio = 1
    if self.timer % 4 == 0 then
        for k,v in pairs(self.dmg_list) do
            table.clear(v)
        end
    end
    local card = self.current_card
    if not card.noncombat then
        if self.timer < card.invult then
            self.dmgratio = 0
        elseif self.timer < card.armor then
            self.dmgratio = 0.1
        else
            self.dmgratio = 1
        end
    else
        self.dmgratio = 0
    end
    self.hp = max(self.hp,-1)
    base_enemy.frame(self)
    if coroutine.status(self.cardco) ~= "dead" then
        local C, E = coroutine.resume(self.cardco, self)
        if(not C)then
            error(E)
        end
    end
end
function M:onDamage(other,dmg)
    local other_class = other.class
    if not self.dmg_list[other_class.type] then
        self.dmg_list[other_class.type] = {}
    end
    local dmgarr = self.dmg_list[other_class.type]
    dmgarr.sum = dmgarr.sum or 0
    table.insert(dmgarr,dmg)
    local yass_exponent = 1/2^(#dmgarr + 1)
    dmgarr.sum = dmgarr.sum + yass_exponent
    local ratio = dmg *math.tween.circOut(yass_exponent)
    self.lastdmg = ratio
    self.hp = self.hp - ratio
end
function M:kill()
    --Kill(self.hpbar)
    --Kill(self.timer_obj)
    if self.other_boss then
        Kill(self.other_boss)
    end
end
CopyImage("boss_indicator", "white")
SetImageState("boss_indicator", "", Color(128,255,255,255))
function M:render()
    Render("boss_indicator",self.x,self.y,0,200,0.2)
    Render("boss_indicator",self.x,self.y,0,0.2,200)
    if self.animManager then
        self.animManager:render(self)
    else
        DefaultRenderFunc(self)
    end
end
function M:onDeath()
end
function M:changeSpell()
    table.remove(self.cards,1)
    self.current_card = self.cards[1]
    Print(self.current_card.coroutine)
    self.cardco = coroutine.create(self.current_card.coroutine or self.class.card_coroutine)
    self.card_num = self.card_num + 1
    self.timer = 0
end
function M:card_coroutine()
    local card = self.current_card
    local otherb = self.other_boss
    local isspell = card.name ~= ""
    task.Clear(self)
    if otherb then
        task.Clear(otherb)
    end
    CallClass(self, "setBaseHP", card.hp)
    Print(card.hp)
    if otherb then
        for k,v in ipairs(otherb) do
            CallClass(v, "setBaseHP", card.hp)
        end
    end
    --CallClass(self, "setSpellVars", card)
    if card.before then card.before(self) end
    if otherb then
        --CallClass(otherb, "onBefore",card)
    end
    CallClass(self, "startHistory", card)
    CallClass(self, "cardStartEffect", card)
    self.timer = 0
    if otherb then
        otherb.timer = 0
    end
    if card.init then card.init(self,otherb) end
    if otherb then
        --CallClass(otherb, "onInit",card)
    end
    coroutine.yield()
    while(self.hp > 0 and self.timer < card.time and not self.skip_card) do --while card is alive
        lstg.var.boss_timer = self.timer
        self.ui_time = (card.time - self.timer)/60
        if card.frame then card.frame(self) end
        if isspell then
            self.bonus = lerp(item.sc_bonus_max,item.sc_bonus_base,self.timer/card.time)
        else
            self.bonus = 0
        end
        coroutine.yield()
    end
    self.skip_card = false
    if otherb then
        otherb.hp = 0
    end
    if card.kill then card.kill(self) end
    CallClass(self, "killChildren", card,otherb)
    CallClass(self, "cardKillEffect", card,otherb)
    CallClass(self, "endHistory", card,otherb)
    if card.del then card.del(self) end
    if #self.cards == 1 then
        Kill(self)
    else
        CallClass(self, "changeSpell",otherb)
    end
end
function M:cardStartEffect(card)
    --spawn cutin here
    --task.Wait(30)
    local isnon = card.name == ""
    if not isnon then
        self.snameobj = New(cutin_obj,card,self)
        self.cutin_effect = New(cutin_border,card,self)
        lstg.tmpvar.bg.spell_color = card.boss_info.spell_bg_color
        lstg.tmpvar.bg.is_spell = true
        task.NewHashed(lstg.tmpvar.bg,"spellInOut",function()
            SetFieldInTime(lstg.tmpvar.bg,30,math.tween.cubicOut,{"spell_t",1})
        end)
    end
end
function M:cardKillEffect(card)
    --the whole explosion thing
    local isnon = card.name == ""
    if not isnon then
        task.NewHashed(lstg.tmpvar.bg,"spellInOut",function()
            SetFieldInTime(lstg.tmpvar.bg,30,math.tween.cubicOut,{"spell_t",0})
            lstg.tmpvar.bg.is_spell = false
        end)
        Kill(self.snameobj)
    end
end
function M:startHistory(card)
    item.StartChipBonus()
    if not card.noncombat and card.name ~= "" then
        if scoredata.SpellHistory == nil then
            scoredata.SpellHistory = { }
        end
        if scoredata.SpellHistory[card.name] == nil then
            scoredata.SpellHistory[card.name] = scoredata.SpellHistory[card.name] or {}
        end
        for i=1, 4 do
            if scoredata.SpellHistory[card.name][i] == nil then
                scoredata.SpellHistory[card.name][i] = 0
            end
        end
        scoredata.SpellHistory[card.name][4] = scoredata.SpellHistory[card.name][4] + 1
    end
end
function M:endHistory(card)
    if not card.noncombat and card.name ~= ""  then
        scoredata.SpellHistory[card.name][1] = scoredata.SpellHistory[card.name][1] + (lstg.var.chip_bonus and 1 or 0)
        scoredata.SpellHistory[card.name][2] = scoredata.SpellHistory[card.name][2] + (lstg.var.bombchip_bonus and 1 or 0)
        scoredata.SpellHistory[card.name][3] = scoredata.SpellHistory[card.name][3] + ((lstg.var.bombchip_bonus and lstg.var.chip_bonus) and 1 or 0)
    end
    item.EndChipBonus(self.x, self.y)
    lstg.var.score = lstg.var.score + self.bonus
end
function M:killChildren()
    KillBullets()
    KillGroup(GROUP_BOSS_EFFECT)
    for k,o in pairs(self._servants) do
        if IsValid(o) and not o.killflag then
            Kill(o)
        end
    end
    New(tasker,function()
        for i=1, 10 do
            KillBullets()
            KillGroup(GROUP_BOSS_EFFECT)
            if IsValid(self) then
                for k,o in pairs(self._servants) do
                    if IsValid(o) and not o.killflag then
                        Kill(o)
                    end
                end
            end
            task.Wait(1)
        end
    end)
end
function M:initNonCombat()
    self.noncombat = true
    self.colli = false
    if self.other_boss then
        self.other_boss.noncombat = true
        self.other_boss.colli = false
    end
end
function M:endNonCombat()
    self.noncombat = false
    self.colli = true
    if self.other_boss then
        self.other_boss.noncombat = false
        self.other_boss.colli = true
    end
end
local voidfunc = function()  end
M.card = {}
_sc_table = {}
function M.card:new(name,timer,armor,invult,hp,is_survival,class)
    local ret = {}
    ret.time = timer*60; ret.armor = armor*60; ret.invult = invult*60;
    ret.hp = hp; ret.name = name;
    ret.before = voidfunc; ret.init = voidfunc; ret.frame = voidfunc
    ret.render = voidfunc; ret.kill = voidfunc; ret.del = voidfunc
    ret.survival = is_survival
    ret = setmetatable(ret, M.card.mt)
    table.insert(_sc_table,ret)
    if class then
        if class.cards == nil then class.cards = {} end
        table.insert(class.cards, ret)
    end
    return ret
end
function M.card:newNonCombat()
    local ret = {}
    ret.init = voidfunc
    ret.coroutine = function(self)
        task.Clear(self)
        CallClass(self, "initNonCombat")
        self.current_card.init(self)
        CallClass(self, "endNonCombat")
        if #self.cards == 1 then
            self.noncombatend = true
            Kill(self)
        else
            CallClass(self, "changeSpell")
        end
    end
    ret.noncombat = true
    ret = setmetatable(ret, M.card.mt)
    if self then
        if self.cards == nil then self.cards = {} end
        table.insert(self.cards, ret)
    end
    return ret
end
function M.card:newWalkOut(wait,time,x,y,tween)
    time = time or 120
    tween = tween or math.tween.cubicOut
    local ret = M.card.newNonCombat()
    function ret:init()
        x,y = x or ran:Float(lstg.world.l,lstg.world.r),y or lstg.world.t+64
        task.Wait(wait or 60)
        MoveTo(self,x,y,time,tween)
    end
    return ret
end
M.card.mt = {
    __index = M,
    __call = M.card.new
}

mini_boss = Class(enemybase)
function mini_boss:init(boss)
    self.boss = boss
    boss.other_boss = self
    base_enemy.init(self,999999,false)
    self.colli = true
    self.group = GROUP_ENEMY
    self.img = "parimg10"
    self.hscale, self.vscale = 5,5
    self.bound = false
    self.hp = 1000
    --self.hpbar = New(circular_hpbar,self)
    self.hpbar = New(straight_hpbar,self)
    self.a, self.b = 32,32
    self.rect = false
end
function mini_boss:frame()
    enemybase.frame(self)
    self.dmgratio = self.boss.dmgratio
    self.hp = max(self.hp,-1)
end
function mini_boss:kill()
    Kill(self.hpbar)
end
function mini_boss:render()
    Render("boss_indicator",self.x,self.y,0,200,0.2)
    Render("boss_indicator",self.x,self.y,0,0.2,200)
    DefaultRenderFunc(self)
end
function mini_boss:onDeath()
    self.boss.hp = 0
end
Include(path .. "boss_ui.lua")
Include(path .. "spelldebug.lua")
return M