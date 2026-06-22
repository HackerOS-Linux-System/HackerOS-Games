settings = {
    difficulty = 'normal',
    fullscreen = false,
    resolution = {width = 800, height = 600},
    keyBindings = {jump = "space", hack = "h", left = "left", right = "right"},
    graphicsQuality = 'medium',
    theme = 'dark', -- Nowa opcja
    playerShape = 'square' -- Nowa opcja customizacji
}
settingsOptions = {
    {name = "Difficulty", values = {"Very Easy", "Easy", "Normal", "Hard", "Insane"}, selected = 3}, -- Więcej poziomów trudności
    {name = "Fullscreen", values = {"Off", "On"}, selected = 1},
    {name = "Resolution", values = {"800x600", "1024x768", "1280x720", "1920x1080", "2560x1440"}, selected = 1}, -- Więcej rozdzielczości
    {name = "Graphics Quality", values = {"Low", "Medium", "High", "Ultra"}, selected = 2}, -- Dodane ultra
    {name = "Player Shape", values = {"Square", "Circle", "Triangle"}, selected = 1}, -- Customizacja gracza
    {name = "Rebind Jump", values = {"Current: space"}, selected = 1},
    {name = "Rebind Hack", values = {"Current: h"}, selected = 1},
    {name = "Rebind Left", values = {"Current: left"}, selected = 1},
    {name = "Rebind Right", values = {"Current: right"}, selected = 1}
}
selectedSetting = 1
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
                    love.window.setMode(settings.resolution.width, settings.resolution.height)
                    -- Apply theme (np. zmiana kolorów w draw functions, ale dla prostoty pominięte)
                    player.shape = string.lower(settingsOptions[5].values[settingsOptions[5].selected])
                    end
                    function drawSettings()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print("Settings", 300, 100, 0, 2, 2)
                    for i, setting in ipairs(settingsOptions) do
                        if i == selectedSetting then
                            love.graphics.setColor(1, 1, 0)
                            else
                                love.graphics.setColor(1, 1, 1)
                                end
                                local value = setting.values[setting.selected]
                                love.graphics.print(setting.name .. ": " .. value, 250, 200 + (i-1)*40)
                                end
                                love.graphics.setColor(1, 1, 1)
                                love.graphics.print("Left/Right to change, Enter to rebind, Esc to Back", 250, 500)
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
