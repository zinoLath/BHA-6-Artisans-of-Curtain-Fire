lstg.supported_res = {
	{960,540},
	{1280,720},
	{1366,768},
	{1600,900},
	{1920,1080},
	{2560,1440},
	{3840,2160}
}
local default_res = 2
lstg.title = "Bullet Hell Artistry #6 - Artisans of Curtain Fire"
default_setting = {
	username = 'User',
	locale = "en_us",
	timezone = 8,
	resx = lstg.supported_res[default_res][1],
	resy = lstg.supported_res[default_res][2],
	resid = default_res,
	windowed = true,
	vsync = false,
	mastervolume = 70,
	sevolume = 100,
	bgmvolume = 100,
	bulshadows = 0,
	autoshoot = false,
	renderskip = false,
	keys = {
		up = KEY.UP,
		down = KEY.DOWN,
		left = KEY.LEFT,
		right = KEY.RIGHT,
		slow = KEY.SHIFT,
		shoot = KEY.Z,
		spell = KEY.X,
		special = KEY.C,
	},
	keys2 = {
		up = KEY.NUMPAD5,
		down = KEY.NUMPAD2,
		left = KEY.NUMPAD1,
		right = KEY.NUMPAD3,
		slow = KEY.A,
		shoot = KEY.S,
		spell = KEY.D,
		special = KEY.F,
	},
	keysys = {
		repfast = KEY.CTRL,
		repslow = KEY.SHIFT,
		menu = KEY.ESCAPE,
		menu_up = KEY.UP,
		menu_down = KEY.DOWN,
		menu_left = KEY.LEFT,
		menu_right = KEY.RIGHT,
		menu_confirm = KEY.Z,
		menu_cancel = KEY.X,
		menu_special = KEY.C,
		menu_ctrl = KEY.CTRL,
		menu_shift = KEY.SHIFT,
		snapshot = KEY.HOME,
		retry = KEY.R,
	},
}

---@param str string
---@return string
local function format_json(str)
	local ret = ''
	local indent = '	'
	local level = 0
	local in_string = false
	for i = 1, #str do
		local s = string.sub(str, i, i)
		if s == '{' and (not in_string) then
			level = level + 1
			ret = ret .. '{\n' .. string.rep(indent, level)
		elseif s == '}' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s}', ret, string.rep(indent, level))
		elseif s == '"' then
			in_string = not in_string
			ret = ret .. '"'
		elseif s == ':' and (not in_string) then
			ret = ret .. ': '
		elseif s == ',' and (not in_string) then
			ret = ret .. ',\n'
			ret = ret .. string.rep(indent, level)
		elseif s == '[' and (not in_string) then
			level = level + 1
			ret = ret .. '[\n' .. string.rep(indent, level)
		elseif s == ']' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s]', ret, string.rep(indent, level))
		else
			ret = ret .. s
		end
	end
	return ret
end

string.format_json = format_json

local function get_file_name()
	return lstg.LocalUserData.GetRootDirectory() .. "/setting.json"
end

function Serialize(o)
	if type(o) == 'table' then
		-- 特殊处理：lstg中部分表将数据保存在metatable的data域中，因此对于table必须重新生成一个干净的table进行序列化操作
		function visitTable(t)
			local ret = {}
			if getmetatable(t) and getmetatable(t).data then
				t = getmetatable(t).data
			end
			for k, v in pairs(t) do
				if type(v) == 'table' then
					ret[k] = visitTable(v)
				else
					ret[k] = v
				end
			end
			return ret
		end

		o = visitTable(o)
	end
	return cjson.encode(o)
end

function DeSerialize(s)
	return cjson.decode(s)
end

function loadConfigure()
	local f, msg
	f, msg = io.open(get_file_name(), 'r')
	if f == nil then
		setting = DeSerialize(Serialize(default_setting))
	else
		setting = DeSerialize(f:read('*a'))
		f:close()
	end
end

function saveConfigure()
	local f, msg
	f, msg = io.open(get_file_name(), 'w')
	if f == nil then
		error(msg)
	else
		f:write(format_json(Serialize(setting)))
		f:close()
	end
end

function loadConfigureTable()
	local f, msg
	f, msg = io.open(get_file_name(), 'r')
	if f == nil then
		local t = DeSerialize(Serialize(default_setting))
		return t
	else
		local t = DeSerialize(f:read('*a'))
		f:close()
		return t
	end
end

function saveConfigureTable(t)
	local f, msg
	f, msg = io.open(get_file_name(), 'w')
	if f == nil then
		error(msg)
	else
		f:write(format_json(Serialize(t)))
		f:close()
	end
end

loadConfigure() -- 先加载一次配置
