---BMF LuaSTG System by Zino Lath v0.01a
local M = {}
BMF = M
local ffi = require "ffi"
ffi.cdef[[
typedef struct {
    int id;
    int _char;
    int state;
    double x;
    double y;
} zfontrender;
]]
local GCSD = GetCurrentScriptDirectory()
local bytetofloat = 1/255
M.states = {}
M.fonts = {}
M.charlist = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ', '!', '"', '#', '$',
    '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/', ':', ';', '<', '=',
    '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[',
    '\\',']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
    'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
    'z', '{', '|', '}', '~'
}
M.punctuation = {
    ["!"] = true,
    ["."] = true,
    [","] = true,
    ["?"] = true,
    [";"] = true,
    [":"] = true,
}
local ctdefault = Color(255,255,255,255)
local cbdefault = Color(255,255,255,255)
local outdefault = Color(255,0,0,0)
CreateRenderTarget("BMF_FONT_BUFFER")
CreateRenderTarget("BMF_FONT_BORDER")
LoadFX("BMF_BORDER_SHADER", GCSD .. "shader.fx")

for k,v in ipairs(M.charlist) do
    M.charlist[v] = k
end
--
M.font_functions = {}
function M:loadFont(name,path)
    --local data = xml:ParseXmlText(FU:getStringFromFile(path))
    local handler = xml2lua.dom:new()
    local parser = xml2lua.parser(handler)
    parser:parse(LoadTextFile(path .. name .. ".fnt"))
    local data = handler.root
    Print("BMFFONT LOADED: "..name)
    local tex_name = "bmftexture:" .. name
    local textures = {}
    for k,_v in pairs(data._children[3]._children) do
        local v = _v._attr
        textures[v.id] = LoadTexture(tex_name .. v.id, path .. v.file)
    end
    local ret = {}
    local chars = {}
    local function getValueN(tb, id)
        return tonumber(tb[string.sub(id,2)])
    end
    for k,_v in pairs(data._children[4]._children) do
        local v = _v._attr
        chars[string.char(getValueN(v, '@id'))] = {
            id = (getValueN(v, '@id')),
            x = getValueN(v, '@x'), y = getValueN(v, '@y'),
            width = getValueN(v, '@width'), height = getValueN(v, '@height'),
            xoffset = getValueN(v, '@xoffset'), yoffset = getValueN(v, '@yoffset'),
            xadvance = getValueN(v, '@xadvance'),
            sprite_name = name .. v['id']
        }
        local curchr = chars[string.char(getValueN(v, '@id'))]
        curchr.sprite =
        LoadImage(name .. v['id'], textures[v.page], curchr.x,curchr.y,curchr.width, curchr.height,0,0,false)
        if M.charlist[string.char(getValueN(v, '@id'))] then
            chars[M.charlist[string.char(getValueN(v, '@id'))]] = chars[string.char(getValueN(v, '@id'))]
        end
        local spr = chars[string.char(getValueN(v, '@id'))].sprite
        SetImageCenter(spr,0,getValueN(v, '@height'))
        SetImageState(spr,"grad+alpha",color.White)
        --SetImageCenter(name .. v['id'],0,getValueN(v, '@height')*0)
    end
    local info = data._children[1]._attr
    local common = data._children[2]._attr
    ret.face = info['face']
    ret.size = tonumber(info['size'])
    ret.bold = info['bold'] == '1'
    ret.charset = info['charset']
    ret.stretchH = info['stretchH']
    ret.smooth = info['smooth']
    ret.padding = info['padding']
    ret.spacing = info['spacing']
    ret.outline = tonumber(info['outline'])
    ret.lineHeight = tonumber(common['lineHeight'])
    ret.base = tonumber(common['base'])
    ret.scaleW = tonumber(common['scaleW'])
    ret.scaleH = tonumber(common['scaleH'])
    ret.pages = tonumber(common['pages'])
    ret.alpha = info['alphaChnl'] == '1'
    ret.chars = chars
    ret.is_bmf = true
    ret.movescale = 1
    local font_count = #M.fonts
    M.fonts[font_count+1] = ret
    M.fonts[name] = ret
    ret.id = font_count+1
    ret.name = name
    ret.mono_exception = {}
    for k,v in pairs(self.font_functions) do
        ret[k] = v
    end
    return ret
end
function M.font_functions:setMonospace(monospace, mono_exception)
    if monospace then
        self.monospace = monospace
        local ret = {}
        for k,v in ipairs(mono_exception) do
            ret[v] = true
        end
        self.mono_exception = ret
    else
        self.monospace = nil
        self.mono_exception = { }
    end
    return self
end
function M.font_functions:getSize(str,scale,offsetfunc)
    local move_scale = 1
    local cursor = Vector(0,-self.base*scale*move_scale/2)
    local chars = self.chars
    local base_c = cursor:clone()
    local monospace = self.monospace
    local min_x,max_x,min_y,max_y = 0,0,0,0
    for i=1, #str do
        local c = str:sub(i,i)
        if c ~= "\n" then
            local char = chars[c]
            local width = char.width*scale * GetImageScale()
            if monospace and not self.mono_exception[c] then
                width = monospace*scale
            end
            local height = char.height*scale * GetImageScale()
            local x,y = cursor.x,
                        cursor.y - char.yoffset*scale*move_scale
            min_x = math.min(min_x,x)
            max_x = math.max(max_x,x + width)
            min_y = math.min(min_y,y)
            max_y = math.max(max_y,y + height)
            if monospace and not self.mono_exception[c] then
                cursor.x = cursor.x + monospace*scale*move_scale
            else
                cursor.x = cursor.x + char.xadvance*scale*move_scale
            end
        else
            base_c.y = base_c.y + self.lineHeight*scale*move_scale
            cursor = base_c
            cursor.x = 0
        end
    end
    return max_x - min_x,  max_y - min_y
end
local white = Color(255,255,255,255)
function M.font_functions:render(str,x,y,scale,halign,valign,color,subcolor,offsetfunc,_move_scale)
    halign = halign or "center"
    valign = valign or "vcenter"
    local move_scale = 1
    if lstg.viewmode ~= "ui" then
        move_scale = 0.4444
    end
    move_scale = move_scale * self.movescale
    move_scale = move_scale * (_move_scale or 1)
    local wd, hg = self:getSize(str,scale*move_scale)
    local cursor = Vector(x,y - self.base*scale*move_scale/2)
    local vec = Vector(0,0)
    if halign == "center" then
        cursor.x = cursor.x - wd/2
    elseif halign == "left" then
        cursor.x = cursor.x
    elseif halign == 'right' then
        cursor.x = cursor.x - wd
    end
    if valign == "top" then
        cursor.y = cursor.y + hg
    elseif valign == 'vcenter' then
        cursor.y = cursor.y + hg/2
    elseif valign == 'bottom' then
        cursor.y = cursor.y
    end
    local base_c = cursor:clone()
    local chars = self.chars
    local monospace = self.monospace
    for i=1, #str do
        local c = str:sub(i,i)
        if c ~= "\n" then
            local char = chars[c]
            local offset = char.xoffset*scale*move_scale
            if offsetfunc then
                vec = offsetfunc(i,c,str)
            end
            if subcolor then
                if type(subcolor) == "userdata" then
                    SetImageSubColor(char.sprite,subcolor)
                else
                    SetImageSubColor(char.sprite,unpack(subcolor))
                end
            end
            if color then
                if type(color) == "userdata" then
                    SetImageState(char.sprite,"grad+alpha",color)
                else
                    SetImageState(char.sprite,"grad+alpha",unpack(color))
                end
            end
            Render(char.sprite,cursor.x + offset + vec.x,cursor.y - char.yoffset*scale*move_scale + vec.y,
                    0,scale,scale,0)
            if color then
                SetImageColor(char.sprite,white)
            end
            if monospace and not self.mono_exception[c] then
                local current_space = monospace
                cursor.x = cursor.x + current_space*scale*move_scale
            else
                cursor.x = cursor.x + char.xadvance*scale*move_scale
            end
        else
            base_c.y = base_c.y - self.lineHeight*scale*move_scale
            cursor = base_c
        end
    end
end
local color_buffer = {}
function M.font_functions:renderOutline(str,x,y,scale,halign,valign,color,offsetfunc,outline_size,outline_color,blend,alpha,_move_scale)
    blend = blend or "mul+alpha"
    --PushRenderTarget("BMF_FONT_BUFFER")
    --RenderClear(Color(0x00000000))
    alpha = alpha or 1
    color = color or Color(255,255,255,255)
    outline_color = outline_color or Color(255,0,0,0)
    local alphcolor = Color(255*alpha,255,255,255)
    local _color
    if type(color) == "table" then
        _color = color_buffer
        for i=1, #color do
            _color[i] = color[i] * alphcolor
        end
    else
        _color = color * alphcolor
    end
    self:render(str,x,y,scale,halign,valign,_color,outline_color,offsetfunc,_move_scale)
    --PopRenderTarget("BMF_FONT_BUFFER")
    do return end
    local _color = outline_color
    local _size = outline_size
    alpha = alpha or 1
    lstg.PostEffect("BMF_BORDER_SHADER", "BMF_FONT_BUFFER", 6, "mul+alpha",
            {
                { _color.r*bytetofloat, _color.g*bytetofloat, _color.b*bytetofloat, _color.a*bytetofloat },
                { _size, alpha, 0, 0}
            })
end
M.tag_funcs = {}
M.tag_funcs.state = {
    init = function(tag,state)
        state.render_funcs = state.render_funcs or {}
        if tag._attr.color then
            state.color_top = StringToColor(tag._attr.color)
            state.color_bot = state.color_bot or StringToColor(tag._attr.color)
        end
        if tag._attr.bcolor then
            state.color_bot = StringToColor(tag._attr.bcolor)
        end
        if tag._attr.alpha then
            state.alpha = tonumber(tag._attr.alpha)
        end
    end
}
M.tag_funcs.shake = {
    init = function(tag,state)
        state.render_funcs = state.render_funcs or {}
        state.render_funcs.shake = function(render_command,_state,char,timer,v)
            render_command.y = render_command.y + 10 * sin(timer*5 + v.id * 30)
        end
    end
}
M.tag_funcs.border = {
    init = function(tag,state)
        state.render_funcs = state.render_funcs or {}
        if tag._attr.color then
            state.out_color = StringToColor(tag._attr.color)
        end
    end
}
M.tag_funcs.space = {
    init = function(tag,state,cursor)
        if tag._attr.x then
            cursor.x = cursor.x + tonumber(tag._attr.x)
        end
        if tag._attr.y then
            cursor.y = cursor.y + tonumber(tag._attr.y)
        end
    end
}
local function fontcopy(tb)
    if type(tb) == "table" then
        local ret = setmetatable({  }, getmetatable(tb))
        for k,v in pairs(tb) do
            if type(v) ~= "table" and k ~= "font" then
                ret[k] = v
            else
                ret[k] = fontcopy(v)
            end
        end
        return ret
    else
        return tb
    end
end
local function returnTList(txt,info,state,ret,state_list,cursor)
    state = state or {}
    state_list = state_list or {}
    state.scale = state.scale or 1
    state.alpha = state.alpha or 1
    local cr_state = fontcopy(state)
    state_list[#state_list+1] = cr_state
    local state_id = #state_list
    ret = ret or {}
    info = info or {}
    local width = info.width or 99999

    local chars = cr_state.font.chars
    cursor = cursor or Vector(0,0)
    for k,v in ipairs(txt._children) do
        if v._type == "TEXT" then
            local str = v._text
            for i = 1, #str do
                local c = str:sub(i,i)
                if c ~= "\n" then
                    local nextc, nextchar
                    if i < #str then
                        nextc = str:sub(i+1,i+1)
                        nextchar = cr_state.font.chars[nextc]
                    end
                    local scale = cr_state.scale
                    local char = cr_state.font.chars[c]
                    if char then
                        local char_advance, nextchar_width
                        if (not cr_state.monospace) and (not (cr_state.monospace_exception and cr_state.monospace_exception[c])) then
                            char_advance = chars[c].xadvance*scale
                        else
                            char_advance = cr_state.monospace
                        end
                        if nextc and nextchar then
                            nextchar_width = nextchar.width - nextchar.xoffset
                        else
                            nextchar_width = 0
                        end
                        if cursor.x + char_advance + nextchar_width*0 > width and c == " " then
                            cursor.x = 0
                            cursor.y = cursor.y - info.maxheight or 0
                        end
                        local glyph = ffi.new("zfontrender",0,M.charlist[c] or 0,state_id, cursor.x + char.xoffset*scale, cursor.y - char.yoffset*scale - cr_state.font.base*scale)
                        cursor.x = cursor.x + char_advance
                        if M.punctuation[c] then
                            if nextc then
                                if not M.punctuation[nextc] then
                                    cursor.x = cursor.x + chars[" "].xadvance*scale
                                end
                            else
                                cursor.x = cursor.x + chars[" "].xadvance*scale
                            end
                        end
                        info.maxheight = math.max(info.maxheight or 0, cr_state.font.lineHeight * cr_state.scale)
                        table.insert(ret, glyph)
                    end
                end
            end
            --table.remove(ret)
        else
            if M.tag_funcs[v._name] then
                M.tag_funcs[v._name].init(v,state,cursor)
            end
            returnTList(v,info,state,ret,state_list,cursor)
            --table.insert(ret, { _type = "TAG_END" })
        end
    end
    return ret,state_list
end
---text is the table ver of a xml element!!!
function M:pool(text,init_state,width)
    if type(text) == "string" then
        text = "<TXT>" .. text .. "</TXT>"
        local handler = xml2lua.dom:new()
        local parser = xml2lua.parser(handler,false)
        parser:parse(text)
        text = handler.root
    end
    if not text._children then
        text = {children = text}
    end
    --Print(PrintTableRecursive(text))
    init_state = init_state or {}

    local glyphList, stateList = returnTList(text,{width = width},init_state)
    local borderList = {}
    local i = 1
    local si = 1
    local max_border_size = 0
    local first_border_size = 0
    local ret = {glyphList = glyphList, stateList = stateList, length = #glyphList}
    return ret
end
function M:getPoolRect(pool)
    local max_x = 0
    local min_x = 0
    local min_y = 0
    local max_y = 0
    for k,v in ipairs(pool.glyphList) do
        local state = pool.stateList[v.state]
        local char = state.font.chars[M.charlist[v._char]]
        min_x = math.min(min_x, v.x)
        max_x = math.max(max_x, v.x + char.width * GetImageScale())
        min_y = math.min(min_y, v.y)
        max_y = math.max(max_y, v.y + char.height * GetImageScale())
    end
    return min_x, max_x, min_y, max_y
end
function M:getPoolWidth(pool)
    local x1, x2, y1, y2 = M:getPoolRect(pool)
    return x2-x1
end
local render_command = {}
local border_command = {
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0}
}
function M:renderPool(pool,x,y,scale,count,timer,imgscale,alpha)
    table.clear(render_command)
    scale = scale or 1
    count = count or 9999999999
    timer = timer or 0
    imgscale = imgscale or 1
    render_command._xorg = x
    render_command._yorg = y
    alpha = alpha or 1
    local alphmult = Color(255*alpha,255,255,255)
    for k,v in ipairs(pool.glyphList) do
        if k > count then
            break
        end
        local state = pool.stateList[v.state]
        local char = state.font.chars[M.charlist[v._char]]
        render_command.x = x+v.x*scale
        render_command.y = y+v.y*scale
        render_command.img = char.sprite
        render_command.scale = scale*state.scale*imgscale
        render_command.topcolor = state.color_top or ctdefault
        render_command.botcolor = state.color_bot or cbdefault
        render_command.out_color = state.out_color or outdefault
        render_command.rot = 0
        if state.render_funcs then
            for _,_funcs in pairs(state.render_funcs) do
                _funcs(render_command,state,char,timer,v)
            end
        end
        local topc, botc = render_command.topcolor*alphmult,render_command.botcolor*alphmult
        SetImageState(render_command.img, "grad+alpha", topc,topc,botc,botc)
        SetImageSubColor(render_command.img, render_command.out_color*alphmult)
        Render(render_command.img,render_command.x,render_command.y,render_command.rot,render_command.scale,render_command.scale)
    end
end
function M.font_functions:clone()
    local ret = {}
    for k,v in pairs(self) do
        if type(v) == "table" then
            ret[k] = M.font_functions.clone(v)
        else
            ret[k] = v
        end
    end
    return ret
end

return M