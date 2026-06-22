settings = {
    difficulty = 'normal',
    fullscreen = false,
    resolution = {width = 800, height = 600},
    keyBindings = {jump = "space", hack = "h", left = "left", right = "right"},
    graphicsQuality = 'medium',
    theme = 'dark',
    playerShape = 'square'
}

settingsOptions = {
    {name = "Difficulty",       values = {"Very Easy", "Easy", "Normal", "Hard", "Insane"}, selected = 3},
    {name = "Fullscreen",       values = {"Off", "On"}, selected = 1},
    {name = "Resolution",       values = {"800x600", "1024x768", "1280x720", "1920x1080", "2560x1440"}, selected = 1},
    {name = "Graphics Quality", values = {"Low", "Medium", "High", "Ultra"}, selected = 2},
    {name = "Player Shape",     values = {"Square", "Circle", "Triangle"}, selected = 1},
    {name = "Rebind Jump",      values = {"Current: space"}, selected = 1},
    {name = "Rebind Hack",      values = {"Current: h"}, selected = 1},
    {name = "Rebind Left",      values = {"Current: left"}, selected = 1},
    {name = "Rebind Right",     values = {"Current: right"}, selected = 1}
}
selectedSetting = 1

-- Motywy kolorystyczne wykorzystywane przy rysowaniu poziomu i menu
themes = {
    dark  = {bg = {0.05, 0.05, 0.1},  grid1 = {0.1, 0.1, 0.3},  grid2 = {0.15, 0.15, 0.35}, text = {1, 1, 1}},
    light = {bg = {0.85, 0.85, 0.9},  grid1 = {0.7, 0.7, 0.8},  grid2 = {0.75, 0.75, 0.85}, text = {0, 0, 0}},
    neon  = {bg = {0.02, 0.0, 0.05},  grid1 = {0.8, 0.0, 1.0},  grid2 = {0.0, 1.0, 0.8},   text = {0, 1, 1}},
    retro = {bg = {0.1, 0.07, 0.02},  grid1 = {0.6, 0.4, 0.1},  grid2 = {0.4, 0.25, 0.05}, text = {1, 0.8, 0.4}}
}

function getCurrentTheme()
return themes[settings.theme] or themes.dark
end

function applySettings()
if settings.difficulty == 'very easy' then
    player.autoSpeed = 100
    gravity = 600
    elseif settings.difficulty == 'easy' then
        player.autoSpeed = 150
        gravity = 800
        elseif settings.difficulty == 'normal' then
            player.autoSpeed = 200
            gravity = 1000
            elseif settings.difficulty == 'hard' then
                player.autoSpeed = 250
                gravity = 1200
                elseif settings.difficulty == 'insane' then
                    player.autoSpeed = 300
                    gravity = 1500
                    end

                    love.window.setFullscreen(settings.fullscreen)
                    love.window.setMode(settings.resolution.width, settings.resolution.height, {resizable = true})

                    player.shape = string.lower(settingsOptions[5].values[settingsOptions[5].selected])
                    settings.playerShape = player.shape
                    end

                    function drawSettings()
                    local theme = getCurrentTheme()
                    love.graphics.setColor(theme.text)
                    love.graphics.print("Settings", 300, 80, 0, 2, 2)
                    for i, setting in ipairs(settingsOptions) do
                        if i == selectedSetting then
                            love.graphics.setColor(1, 1, 0)
                            else
                                love.graphics.setColor(theme.text)
                                end
                                local value = setting.values[setting.selected]
                                love.graphics.print(setting.name .. ": " .. value, 220, 150 + (i - 1) * 36)
                                end
                                love.graphics.setColor(theme.text)
                                love.graphics.print("Left/Right - zmiana, Enter - rebind, Esc - powrót", 200, 500)
                                end

                                function updateSettings(isRight)
                                local setting = settingsOptions[selectedSetting]
                                if isRight then
                                    setting.selected = setting.selected + 1
                                    if setting.selected > #setting.values then setting.selected = 1 end
                                        else
                                            setting.selected = setting.selected - 1
                                            if setting.selected < 1 then setting.selected = #setting.values end
                                                end

                                                if setting.name == "Difficulty" then
                                                    settings.difficulty = string.lower(setting.values[setting.selected])
                                                    elseif setting.name == "Fullscreen" then
                                                        settings.fullscreen = (setting.selected == 2)
                                                        elseif setting.name == "Resolution" then
                                                            local res = setting.values[setting.selected]
                                                            local w, h = res:match("(%d+)x(%d+)")
                                                            settings.resolution = {width = tonumber(w), height = tonumber(h)}
                                                            elseif setting.name == "Graphics Quality" then
                                                                settings.graphicsQuality = string.lower(setting.values[setting.selected])
                                                                elseif setting.name == "Player Shape" then
                                                                    settings.playerShape = string.lower(setting.values[setting.selected])
                                                                    elseif setting.name:match("^Rebind") then
                                                                        local key = setting.name:match("Rebind (%w+)")
                                                                        setting.values = {"Current: " .. settings.keyBindings[key:lower()]}
                                                                        end
                                                                        applySettings()
                                                                        end
