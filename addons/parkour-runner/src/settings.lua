local json = require("src.json")

local Settings = {}

local CONFIG_DIR  = os.getenv("HOME") .. "/.config/HackerOS/parkour-runner/"
local CONFIG_FILE = CONFIG_DIR .. "settings.json"

Settings.defaults = {
    fullscreen      = false,
    masterVolume    = 0.8,
    musicVolume     = 0.7,
    sfxVolume       = 1.0,
    showFPS         = false,
    difficulty      = "normal",   -- easy / normal / hard
    keybinds = {
        left    = "a",
        right   = "d",
        jump    = "space",
        slide   = "lshift",
        pause   = "escape",
    },
    playerName      = "Runner",
    highscores = {
        time_attack  = {},
        endless      = {},
    }
}

Settings.data = {}

local function deepcopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do copy[k] = deepcopy(v) end
    return copy
end

local function merge(base, override)
    for k, v in pairs(override) do
        if type(v) == "table" and type(base[k]) == "table" then
            merge(base[k], v)
        else
            base[k] = v
        end
    end
end

function Settings.load()
    Settings.data = deepcopy(Settings.defaults)

    -- Try reading saved file
    local ok, content = pcall(function()
        local f = io.open(CONFIG_FILE, "r")
        if not f then return nil end
        local s = f:read("*a")
        f:close()
        return s
    end)

    if ok and content and content ~= "" then
        local parsed = json.decode(content)
        if parsed then
            merge(Settings.data, parsed)
        end
    end
end

function Settings.save()
    -- Ensure directory exists
    os.execute('mkdir -p "' .. CONFIG_DIR .. '"')

    local ok = pcall(function()
        local f = assert(io.open(CONFIG_FILE, "w"))
        f:write(json.encode(Settings.data))
        f:close()
    end)

    if not ok then
        print("[Settings] Failed to save settings to " .. CONFIG_FILE)
    end
end

function Settings.addHighscore(mode, entry)
    -- entry = { name=string, score=number, date=string }
    local list = Settings.data.highscores[mode] or {}
    table.insert(list, entry)
    -- Sort descending for endless (higher = better), ascending for time_attack (lower = better)
    if mode == "time_attack" then
        table.sort(list, function(a, b) return a.score < b.score end)
    else
        table.sort(list, function(a, b) return a.score > b.score end)
    end
    -- Keep top 10
    while #list > 10 do table.remove(list) end
    Settings.data.highscores[mode] = list
    Settings.save()
end

return Settings
