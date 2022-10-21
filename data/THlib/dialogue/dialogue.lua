local M = Class()
local path = GetCurrentScriptDirectory()
dialogue_font = BMF:loadFont("philosopher",font_path)
dialogue_manager = M
sample_dialogue = LoadTextFile(path.."dialogue.xml")

LoadImageFromFile("kagerou", path .. "kage_port.png",true)
CopyImage("textbox", "white")
SetImageState("textbox","",Color(160,0,0,0))
LoadImageFromFile("kage_title_R", path .. "kagerou_right.png",true)
LoadImageFromFile("kage_title_L", path .. "kagerou_left.png",true)
M.tag_list = {}
M.tag_list.message = {}
---Make it update the objects text render command
function M.tag_list.message.init(obj,actiondata,id,xml)
    local data = actiondata
    local state = {
        font = dialogue_font,
        scale = 1,
        --monospace = 70,
        --monospace_exception = {}
    }
    --{id = 100 (where to pause), time = 20 (frames to pause, or string for key)}
    data.wait_positions = {}
    local i=1
    --error(PrintTableRecursive(xml._children))
    for k,v in ipairs(xml._children) do
        if v._type == "ELEMENT" then
            if v._name == "wait" then
                local time = v._attr.time
                if tonumber(time) then
                    time = tonumber(time)
                end
                data.wait_positions[i] = time
            end
        elseif v._type == "TEXT" then
            i = i + #v._text
        end
    end
    data.render_pool = BMF:pool(xml,state,obj.width,10,30)
    data.speaker = xml._attr.speaker
end
function M.tag_list.message.co(obj,id,actiondata)
    obj.render_pool = actiondata.render_pool
    CallClass(obj,"setSpeaker",actiondata.speaker)
    obj.count = 0
    for i=1, actiondata.render_pool.length do
        if actiondata.wait_positions[i] then
            local _wait = actiondata.wait_positions[i]
            if _wait == "input" then
                while(not SysKeyIsPressed("menu_confirm")) do
                    coroutine.yield()
                end
            else
                task.Wait(_wait)
            end
        end
        obj.count = i
        coroutine.yield()
    end
    while(not SysKeyIsPressed("menu_confirm")) do
        --Print(obj.render_pool)
        coroutine.yield()
    end
end
function M:init(data)
    self.width = 1000
    self.count = 0
    if type(data) == "string" then
        local handler = xml2lua.dom:new()
        local parser = xml2lua.parser(handler,1)
        parser:parse(data)
        data = handler.root
    end
    self.meta = data._children[1]
    self.speakers = {}
    for k,v in ipairs(self.meta._children) do
        if v._name == "speaker" then
            self.speakers[v._attr.id] = deepcopy(v._attr)
        end
    end
    ---make a table for each action, and then run it on a coroutine
    self.actions = data._children[2]._children
    self.actiondata = {}
    for k,v in ipairs(self.actions) do
        if M.tag_list[v._name] then
            self.actiondata[k] = {}
            self.actiondata[k].co_func = M.tag_list[v._name].co
            M.tag_list[v._name].init(self,self.actiondata[k],k,v)
        end
    end
    self.current_speaker = {}
    self.current_speakerid = "none"
    self.actionid = 1
    self.control_co = coroutine.create(function()
        for k,v in ipairs(self.actiondata) do
            v.co_func(self,self.actionid,self.actiondata[self.actionid])
            self.actionid = self.actionid + 1
        end
    end)
    self.layer = LAYER_UI+100
    self.bound = false
    Print("Nicki")
end
function M:frame()
    task.Do(self)
    if self.control_co then
        if coroutine.status(self.control_co) ~= "dead" then
            local C, E = coroutine.resume(self.control_co,self,self.actionid,self.actiondata[self.actionid])
            --Print(self.render_pool)
            if(not C)then
                error(E)
            end
        end
    end
    do return end
    if self.co then
        if coroutine.status(self.co) ~= "dead" then
            local C, E = coroutine.resume(self.co,self,self.actionid,self.actiondata[self.actionid])
            --Print(self.render_pool)
            if(not C)then
                error(E)
            end
        end
    end
end
function M:render()
    SetViewMode("ui")
    local scale = 1
    local x,y = screen.width/2,200
    RenderRect("textbox", 0, screen.width, 0, y+150)
    dialogue_font:renderOutline(self.current_speaker.name or "",100,y+100,0.8,"left","bottom")
    if self.render_pool then
        RenderRect("dialogue_bound_viewer", x-600, x-600+self.width*scale*0.5, y-0,y+50)
        BMF:renderPool(self.render_pool,x-600,y+50,scale,self.count,self.timer)
    end
    SetViewMode("world")
end
function M:nextAction()
    self.actionid = self.actionid + 1
    self.co = coroutine.create(self.actiondata[self.actionid].co_func)
end
function M:setSpeaker(speaker_id)
    self.current_speakerid = speaker_id
    self.current_speaker = self.speakers[speaker_id]
end
return M