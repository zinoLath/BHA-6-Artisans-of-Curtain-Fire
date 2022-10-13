-- LAST UPDATED: 9/25/18
-- added Vector3.getCeil and v.ceil
-- added Vector3.clamp
-- changed float to double as per Mike Pall's advice
-- added Vector3.floor
-- added fallback to table if luajit ffi is not detected (used for unit tests)

--[[
BrineVector3: a luajit ffi-accelerated Vector3 library
Copyright 2018 Brian Sarfati
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]
local ffi
local VECTORTYPE = "cdata"
local lerp = math.lerp
local pi2 = math.pi * 2
local math_cos, math_sin = math.cos, math.sin
local cos, sin = cos, sin
local int = math.floor

if jit and jit.status() then
    ffi = require "ffi"
    ffi.cdef[[
  typedef struct {
    double x;
    double y;
    double z;
  } brinevector3;
  ]]
else
    VECTORTYPE = "table"
end

local Vector3 = {}
setmetatable(Vector3,Vector3)

local special_properties = {
    length = "getLength",
    normalized = "getNormalized",
    angle = "getAngle",
    length2 = "getLengthSquared",
    copy = "getCopy",
    inverse = "getInverse",
    floor = "getFloor",
    ceil = "getCeil",
}

function Vector3.__index(t, k)
    if special_properties[k] then
        return Vector3[special_properties[k]](t)
    end
    return rawget(Vector3,k)
end

function Vector3.getLength(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function Vector3.getLengthSquared(v)
    return v.x*v.x + v.y*v.y + v.z*v.z
end

function Vector3.getNormalized(v)
    local length = v.length
    if length == 0 then return Vector3(0,0) end
    return Vector3(v.x / length, v.y / length, v.z / length)
end

function Vector3.getAngle(v)
    return atan2(v.y, v.x)
end

function Vector3.getCopy(v)
    return Vector3(v.x,v.y,v.z)
end

function Vector3.getInverse(v)
    return Vector3(1 / v.x, 1 / v.y, 1 / v.z)
end

function Vector3.getFloor(v)
    return Vector3(math.floor(v.x), math.floor(v.y), math.floor(v.z))
end

function Vector3.getCeil(v)
    return Vector3(math.ceil(v.x), math.ceil(v.y), math.floor(v.z))
end

function Vector3.__newindex(t,k,v)
    if k == "length" then
        local res = t.normalized * v
        t.x = res.x
        t.y = res.y
        t.z = res.z
        return
    end
    if k == "angle" then
        local res = t:angled(v)
        t.x = res.x
        t.y = res.y
        t.z = res.z
        return
    end
    if t == Vector3 then
        rawset(t,k,v)
    else
        error("Cannot assign a new property '" .. k .. "' to a Vector3", 2)
    end
end

function Vector3.angled(v, angle)
    local length = v.length
    return Vector3(cos(angle) * length, sin(angle) * length)
end

function Vector3.trim(v,mag)
    if v.length < mag then return v end
    return v.normalized * mag
end

function Vector3.split(v)
    return v.x, v.y
end
Vector3.unpack = Vector3.split

function Vector3.lerp(v1,v2,a)
    return Vector3(v1.x + (v2.x - v1.x) * a,v1.y + (v2.y - v1.y) * a)
end

local function clamp(x, min, max)
    -- because Mike Pall says math.min and math.max are JIT-optimized
    return math.min(math.max(min, x), max)
end

function Vector3.clamp(v, topleft, bottomright)
    -- clamps a Vector3 to a certain bounding box about the origin
    return Vector3(
            clamp(v.x, topleft.x, bottomright.x),
            clamp(v.y, topleft.y, bottomright.y),
            clamp(v.z, topleft.z, bottomright.z)
    )
end

function Vector3.hadamard(v1, v2) -- also known as "Componentwise multiplication"
    return Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
end

function Vector3.rotated(v, angle)
    local cos = cos(angle)
    local sin = sin(angle)
    return Vector3(v.x * cos - v.y * sin, v.x * sin + v.y * cos)
end
function Vector3.rotate(v, angle)
    local cos = cos(angle)
    local sin = sin(angle)
    local px = v.x
    v.x = px * cos - v.y * sin
    v.y = px * sin + v.y * cos
    return v
end

function Vector3.rotatecs(v, cos, sin)
    local px = v.x
    v.x = px * cos - v.y * sin
    v.y = px * sin + v.y * cos
    return v
end
local iteraxes_lookup = {
    xy = {"x","y"},
    yx = {"y","x"}
}
local function iteraxes(ordertable, i)
    i = i + 1
    if i > 2 then return nil end
    return i, ordertable[i]
end

function Vector3.axes(order)
    return iteraxes, iteraxes_lookup[order or "yx"], 0
end
Vector3.clone = Vector3.getCopy

local function iterpairs(Vector3, k)
    if k == nil then
        k = "x"
    elseif k == "x" then
        k = "y"
    else
        k = nil
    end
    return k, Vector3[k]
end

function Vector3.__pairs(v)
    return iterpairs, v, nil
end

function Vector3.fromAngle(ang)
    return Vector3(cos(ang), sin(ang))
end
function Vector3.fromPolygon(sides,t)
    local ft = (sides*t)-int(sides*t)
    local a1 = (pi2/int(sides))*int(t*sides)
    local a2 = (pi2/int(sides))*int(t*sides+1)
    return Vector3(
            lerp(math_cos(a1),math_cos(a2),ft),
            lerp(math_sin(a1),math_sin(a2),ft))
end
function Vector3.fromTable(tb)
    return Vector3(tb.x,tb.y,tb.z)
end
function Vector3.fromVelocity(tb)
    return Vector3(tb.vx,tb.vy,tb.vz)
end
--Clockwise
function Vector3.perpendicularC(v)
    return Vector3(v.y,-v.x)
end
--CounterClockwise
function Vector3.perpendicularCC(v)
    return Vector3(-v.y,v.x)
end
Vector3.perpendicular = Vector3.perpendicularC
function Vector3.list_lerp(arr, t)
    local src = arr[LoopTableK(arr,int(t))] --get the first value for lerp
    --local did = int(t + 1) > #arr and int(t + 1 - #arr) or int(t + 1)-- loops through the array
    local did = LoopTableK(arr,int(t+1))
    local dest = arr[did] --get the second index for lerp
    local _t = t - int(t)
    return Vector3.lerp(src,dest,_t)
end

if ffi then
    function Vector3.isVector(arg)
        return ffi.istype("brinevector3",arg)
    end
else
    function Vector3.isVector(arg)
        return type(arg) == VECTORTYPE and arg.x and arg.y
    end
end

function Vector3.isVectorLoose(arg)
    if not Vector3.isVector(arg) and type(arg) ~= "table" then
        return false
    end
    return arg.x and arg.y
end

function Vector3.toTable(v)
    return {x = v.x, y = v.y}
end

function Vector3.__add(v1, v2)
    return Vector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z or 0)
end

function Vector3.__sub(v1, v2)
    return Vector3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z or 0)
end

function Vector3.__mul(v1, op)
    -- acts as a hadamard multiplication if op is a Vector3
    -- if op is a scalar then works as usual
    if type(v1) == "number" then
        return Vector3(op.x * v1, op.y * v1, op.z * v1)
    end
    if type(op) == VECTORTYPE then
        return Vector3(v1.x * op.x, v1.y * op.y, v1.z * op.z)
    else
        return Vector3(v1.x * op, v1.y * op, v1.z * op)
    end
end

function Vector3.__div(v1, op)
    if type(op) == "number" then
        if op == 0 then error("Vector3 NaN occured", 2) end
        return Vector3(v1.x / op, v1.y / op, v1.z / op)
    elseif type(op) == VECTORTYPE then
        if op.x * op.y == 0 then error("Vector3 NaN occured", 2) end
        return Vector3(v1.x / op.x, v1.y / op.y, v1.z / op.z)
    end
end

function Vector3.__unm(v)
    return Vector3(-v.x, -v.y, -v.z)
end

function Vector3.__eq(v1,v2)
    if (not Vector3.isVector(v1)) or (not Vector3.isVector(v2)) then return false end
    return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z
end

function Vector3.__mod(v1,v2)  -- ran out of symbols, so i chose % for the dot product
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

function Vector3.__tostring(t)
    return string.format("Vector3{%.4f, %.4f, %.4f}",t.x,t.y,t.z)
end

function Vector3.__concat(str, v)
    return tostring(str) .. tostring(v)
end

function Vector3.__len(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

if ffi then
    function Vector3.__call(t,x,y,z)
        return ffi.new("brinevector3",x or 0,y or 0,z or 0)
    end
else
    function Vector3.__call(t,x,y,z)
        return setmetatable({x = x or 0, y = y or 0, z = z or 0}, Vector3)
    end
end

local dirs = {
    up = Vector3(0,-1,0),
    down = Vector3(0,1,0),
    left = Vector3(-1,0,0),
    right = Vector3(1,0,0),
    top = Vector3(0,-1,0),
    bottom = Vector3(0,1,0),
    forward = Vector3(0,0,1),
    back = Vector3(0,0,-1),
}

function Vector3.dir(dir)
    return dirs[dir] and dirs[dir].copy or Vector3()
end


if ffi then
    ffi.metatype("brinevector3",Vector3)
end


Vector3.zero = Vector3(0,0)
return Vector3