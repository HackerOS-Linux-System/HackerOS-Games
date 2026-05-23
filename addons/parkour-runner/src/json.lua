local json = {}

-- ─── ENCODE ──────────────────────────────────────────────────────────────────
local function escape(s)
    return s:gsub('\\', '\\\\')
             :gsub('"',  '\\"')
             :gsub('\n', '\\n')
             :gsub('\r', '\\r')
             :gsub('\t', '\\t')
end

local encode  -- forward ref

local function encodeValue(v)
    local t = type(v)
    if t == "nil"     then return "null"
    elseif t == "boolean" then return tostring(v)
    elseif t == "number"  then
        if v ~= v then return "null" end  -- NaN
        return tostring(v)
    elseif t == "string"  then return '"' .. escape(v) .. '"'
    elseif t == "table"   then return encode(v)
    else return '"[unsupported]"'
    end
end

-- Detect array vs object
local function isArray(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    for i = 1, n do if t[i] == nil then return false end end
    return n > 0 or next(t) == nil
end

encode = function(t)
    if isArray(t) then
        local parts = {}
        for _, v in ipairs(t) do
            parts[#parts+1] = encodeValue(v)
        end
        return "[" .. table.concat(parts, ",") .. "]"
    else
        local parts = {}
        for k, v in pairs(t) do
            parts[#parts+1] = '"' .. escape(tostring(k)) .. '":' .. encodeValue(v)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
end

function json.encode(v)
    return encodeValue(v)
end

-- ─── DECODE ──────────────────────────────────────────────────────────────────
local function skipWS(s, i)
    while i <= #s and s:sub(i,i):match("%s") do i = i + 1 end
    return i
end

local decode_value  -- forward ref

local function decode_string(s, i)
    -- i points at opening "
    i = i + 1
    local result = {}
    while i <= #s do
        local c = s:sub(i,i)
        if c == '"' then
            return table.concat(result), i + 1
        elseif c == '\\' then
            local e = s:sub(i+1,i+1)
            if     e == '"'  then result[#result+1] = '"'
            elseif e == '\\' then result[#result+1] = '\\'
            elseif e == '/'  then result[#result+1] = '/'
            elseif e == 'n'  then result[#result+1] = '\n'
            elseif e == 'r'  then result[#result+1] = '\r'
            elseif e == 't'  then result[#result+1] = '\t'
            else result[#result+1] = e
            end
            i = i + 2
        else
            result[#result+1] = c
            i = i + 1
        end
    end
    error("Unterminated string")
end

local function decode_array(s, i)
    local arr = {}
    i = i + 1  -- skip [
    i = skipWS(s, i)
    if s:sub(i,i) == ']' then return arr, i + 1 end
    while true do
        local v
        v, i = decode_value(s, i)
        arr[#arr+1] = v
        i = skipWS(s, i)
        local c = s:sub(i,i)
        if c == ']' then return arr, i + 1
        elseif c == ',' then i = i + 1; i = skipWS(s, i)
        else error("Expected , or ] in array")
        end
    end
end

local function decode_object(s, i)
    local obj = {}
    i = i + 1  -- skip {
    i = skipWS(s, i)
    if s:sub(i,i) == '}' then return obj, i + 1 end
    while true do
        local k
        k, i = decode_string(s, i)
        i = skipWS(s, i)
        assert(s:sub(i,i) == ':', "Expected :")
        i = i + 1
        i = skipWS(s, i)
        local v
        v, i = decode_value(s, i)
        obj[k] = v
        i = skipWS(s, i)
        local c = s:sub(i,i)
        if c == '}' then return obj, i + 1
        elseif c == ',' then i = i + 1; i = skipWS(s, i)
        else error("Expected , or } in object")
        end
    end
end

decode_value = function(s, i)
    i = skipWS(s, i)
    local c = s:sub(i,i)
    if c == '"' then
        return decode_string(s, i)
    elseif c == '[' then
        return decode_array(s, i)
    elseif c == '{' then
        return decode_object(s, i)
    elseif s:sub(i, i+3) == 'true'  then return true,  i + 4
    elseif s:sub(i, i+4) == 'false' then return false, i + 5
    elseif s:sub(i, i+3) == 'null'  then return nil,   i + 4
    else
        -- number
        local num = s:match("^-?%d+%.?%d*[eE]?[+-]?%d*", i)
        if num then return tonumber(num), i + #num end
        error("Unknown token at position " .. i .. ": " .. s:sub(i, i+10))
    end
end

function json.decode(s)
    local ok, val = pcall(function()
        local v, _ = decode_value(s, 1)
        return v
    end)
    if ok then return val else return nil end
end

return json
