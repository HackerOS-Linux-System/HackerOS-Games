menuOptions     = {"Start Game", "Level Select", "Game Modes", "Settings", "Achievements", "Themes", "Credits", "Exit"}
selectedMenu    = 1

pauseOptions    = {"Wznów", "Ustawienia", "Menu Główne"}
selectedPause   = 1

modeOptions     = {"Normal", "Time Attack", "Endless", "Practice"}
selectedMode    = 1

selectedLevel   = 1
selectedAchievement = 1

themeOptions    = {"Dark", "Light", "Neon", "Retro"}
selectedTheme   = 1

creditsText = {
    "Bit Jump – inspirowany Geometry Dash",
    "Kod: [Twoje Imię]",
    "Silnik: LÖVE2D (love2d.org)",
    "Wersja: 2.0 – 14 poziomów, 3 bossy",
    "",
    "Sterowanie:",
    "  Strzałki / Space – ruch i skok",
    "  H – hakowanie wrogów",
    "  P / Esc – pauza",
    "",
    "Dziękuję za grę!"
}

-- ============================================================
-- Pomocnicze – tło z animowanym gradientem dla menu
-- ============================================================
local menuTime = 0
function updateMenu(dt)
menuTime = menuTime + dt
end

local function drawMenuBackground()
local W = love.graphics.getWidth()
local H = love.graphics.getHeight()
local theme = getCurrentTheme()
love.graphics.setBackgroundColor(theme.bg[1], theme.bg[2], theme.bg[3])
love.graphics.setColor(theme.grid1[1], theme.grid1[2], theme.grid1[3], 0.3)
for x = menuTime * 15 % 80, W + 80, 80 do
    love.graphics.line(x, 0, x, H)
    end
    for y = menuTime * 10 % 60, H + 60, 60 do
        love.graphics.line(0, y, W, y)
        end
        end

        local function drawTitle(yPos)
        if logo then
            love.graphics.setColor(1, 1, 1)
            local iw, ih = logo:getDimensions()
            local scale = math.min(300 / iw, 80 / ih)
            love.graphics.draw(logo, love.graphics.getWidth() / 2 - iw * scale / 2, yPos, 0, scale, scale)
            else
                local pulse = 0.9 + 0.1 * math.sin(menuTime * 2)
                love.graphics.setColor(0, pulse, pulse)
                love.graphics.print("BIT JUMP", love.graphics.getWidth() / 2 - 80, yPos, 0, 2.2, 2.2)
                end
                end

                -- ============================================================
                -- drawMenu
                -- ============================================================
                function drawMenu()
                drawMenuBackground()
                drawTitle(50)
                local theme = getCurrentTheme()
                local cx = love.graphics.getWidth() / 2 - 80

                for i, option in ipairs(menuOptions) do
                    local scale = (i == selectedMenu) and 1.25 or 1.0
                    if i == selectedMenu then
                        love.graphics.setColor(1, 1, 0)
                        else
                            love.graphics.setColor(theme.text)
                            end
                            love.graphics.print(option, cx, 170 + (i - 1) * 42, 0, scale, scale)
                            end
                            end

                            -- ============================================================
                            -- drawLevelSelect
                            -- ============================================================
                            function drawLevelSelect()
                            drawMenuBackground()
                            local theme = getCurrentTheme()
                            local W = love.graphics.getWidth()

                            love.graphics.setColor(theme.text)
                            love.graphics.print("Wybór Poziomu", W / 2 - 100, 60, 0, 1.8, 1.8)

                            local cx = W / 2 - 100
                            for i = 1, #levels do
                                if i == selectedLevel then
                                    love.graphics.setColor(1, 1, 0)
                                    else
                                        love.graphics.setColor(theme.text)
                                        end
                                        local locked = (i > highestLevel)
                                        local label = string.format("Poziom %2d  %s", i, locked and "[ZABLOKOWANY]" or "[ODBLOKOWANY]")
                                        love.graphics.print(label, cx, 120 + (i - 1) * 32, 0, (i == selectedLevel) and 1.1 or 1.0)
                                        end
                                        love.graphics.setColor(theme.text)
                                        love.graphics.print("Esc – powrót", cx, 120 + #levels * 32 + 16)
                                        end

                                        -- ============================================================
                                        -- drawGameModes
                                        -- ============================================================
                                        function drawGameModes()
                                        drawMenuBackground()
                                        local theme = getCurrentTheme()
                                        local W = love.graphics.getWidth()
                                        local cx = W / 2 - 100

                                        love.graphics.setColor(theme.text)
                                        love.graphics.print("Tryby Gry", W / 2 - 70, 80, 0, 1.8, 1.8)

                                        local descs = {
                                            "Normal     – klasyczna gra, 3 życia",
                                            "Time Attack – ścig z czasem na każdym poziomie",
                                            "Endless    – nieskończona pętla, rosnąca prędkość",
                                            "Practice   – nieskończone życia, idealne do nauki"
                                        }
                                        for i, option in ipairs(modeOptions) do
                                            if i == selectedMode then
                                                love.graphics.setColor(1, 1, 0)
                                                else
                                                    love.graphics.setColor(theme.text)
                                                    end
                                                    love.graphics.print(descs[i], cx, 180 + (i - 1) * 55)
                                                    end
                                                    love.graphics.setColor(theme.text)
                                                    love.graphics.print("Esc – powrót", cx, 420)
                                                    end

                                                    -- ============================================================
                                                    -- drawPause
                                                    -- ============================================================
                                                    function drawPause()
                                                    local W = love.graphics.getWidth()
                                                    local H = love.graphics.getHeight()
                                                    love.graphics.setColor(0, 0, 0, 0.55)
                                                    love.graphics.rectangle("fill", 0, 0, W, H)
                                                    local theme = getCurrentTheme()
                                                    love.graphics.setColor(theme.text)
                                                    love.graphics.print("PAUZA", W / 2 - 40, 120, 0, 2, 2)
                                                    local cx = W / 2 - 60
                                                    for i, option in ipairs(pauseOptions) do
                                                        if i == selectedPause then
                                                            love.graphics.setColor(1, 1, 0)
                                                            else
                                                                love.graphics.setColor(theme.text)
                                                                end
                                                                love.graphics.print(option, cx, 220 + (i - 1) * 50)
                                                                end
                                                                end

                                                                -- ============================================================
                                                                -- drawAchievements
                                                                -- ============================================================
                                                                local achDescriptions = {
                                                                    hacker         = "Zhakuj 1 wroga (H w pobliżu)",
                                                                    data_collector = "Zbierz wszystkie dane na poziomie",
                                                                    endless_runner = "Ukończ pętlę w trybie Endless",
                                                                    game_winner    = "Ukończ wszystkie 14 poziomów",
                                                                    perfect_run    = "Osiągnij mnożnik x5",
                                                                    speed_demon    = "Zbierz power-up szybkości",
                                                                    boss_slayer    = "Pokonaj bossa skacząc na niego",
                                                                    no_hit_level   = "Przejdź poziom bez obrażeń",
                                                                    completionist  = "Odblokuj wszystkie osiągnięcia"
                                                                }

                                                                function drawAchievements()
                                                                drawMenuBackground()
                                                                local theme = getCurrentTheme()
                                                                local W = love.graphics.getWidth()
                                                                local cx = W / 2 - 160

                                                                love.graphics.setColor(theme.text)
                                                                love.graphics.print("Osiągnięcia", W / 2 - 80, 60, 0, 1.8, 1.8)

                                                                for i, name in ipairs(achievementList) do
                                                                    local unlocked = achievements[name]
                                                                    if i == selectedAchievement then
                                                                        love.graphics.setColor(1, 1, 0)
                                                                        elseif unlocked then
                                                                            love.graphics.setColor(0.3, 1, 0.5)
                                                                            else
                                                                                love.graphics.setColor(0.5, 0.5, 0.5)
                                                                                end
                                                                                local desc = achDescriptions[name] or name
                                                                                local status = unlocked and "✓" or "✗"
                                                                                love.graphics.print(status .. "  " .. desc, cx, 120 + (i - 1) * 36)
                                                                                end
                                                                                love.graphics.setColor(theme.text)
                                                                                love.graphics.print("Esc – powrót", cx, 120 + #achievementList * 36 + 16)
                                                                                end

                                                                                -- ============================================================
                                                                                -- drawCredits
                                                                                -- ============================================================
                                                                                function drawCredits()
                                                                                drawMenuBackground()
                                                                                local theme = getCurrentTheme()
                                                                                local W = love.graphics.getWidth()
                                                                                love.graphics.setColor(theme.text)
                                                                                love.graphics.print("Kredyty", W / 2 - 50, 60, 0, 1.8, 1.8)
                                                                                for i, line in ipairs(creditsText) do
                                                                                    love.graphics.setColor(theme.text)
                                                                                    love.graphics.print(line, W / 2 - 180, 130 + (i - 1) * 26)
                                                                                    end
                                                                                    love.graphics.setColor(theme.text)
                                                                                    love.graphics.print("Esc – powrót", W / 2 - 60, 130 + #creditsText * 26 + 16)
                                                                                    end

                                                                                    -- ============================================================
                                                                                    -- drawThemes
                                                                                    -- ============================================================
                                                                                    function drawThemes()
                                                                                    drawMenuBackground()
                                                                                    local theme = getCurrentTheme()
                                                                                    local W = love.graphics.getWidth()
                                                                                    local cx = W / 2 - 80

                                                                                    love.graphics.setColor(theme.text)
                                                                                    love.graphics.print("Motywy", W / 2 - 50, 80, 0, 1.8, 1.8)

                                                                                    for i, t in ipairs(themeOptions) do
                                                                                        if i == selectedTheme then
                                                                                            love.graphics.setColor(1, 1, 0)
                                                                                            else
                                                                                                love.graphics.setColor(theme.text)
                                                                                                end
                                                                                                love.graphics.print(t, cx, 180 + (i - 1) * 50)
                                                                                                end
                                                                                                love.graphics.setColor(theme.text)
                                                                                                love.graphics.print("Esc – powrót", cx, 440)
                                                                                                end

                                                                                                -- ============================================================
                                                                                                -- handleKeyPressed – centralna obsługa klawiszy dla wszystkich stanów
                                                                                                -- ============================================================
                                                                                                function handleKeyPressed(key)
                                                                                                -- Gra
                                                                                                if state == 'game' then
                                                                                                    if key == "r" and (gameOver or gameWon) then
                                                                                                        lives = (gameMode == 'practice') and math.huge or 3
                                                                                                        loadLevel(currentLevel)
                                                                                                        score    = 0
                                                                                                        gameOver = false
                                                                                                        gameWon  = false
                                                                                                        elseif (key == "escape" or key == "p") and not gameOver and not gameWon then
                                                                                                            state = 'pause'
                                                                                                            selectedPause = 1
                                                                                                            end
                                                                                                            return
                                                                                                            end

                                                                                                            -- Menu
                                                                                                            if state == 'menu' then
                                                                                                                if key == "up" then
                                                                                                                    selectedMenu = selectedMenu - 1
                                                                                                                    if selectedMenu < 1 then selectedMenu = #menuOptions end
                                                                                                                        elseif key == "down" then
                                                                                                                            selectedMenu = selectedMenu + 1
                                                                                                                            if selectedMenu > #menuOptions then selectedMenu = 1 end
                                                                                                                                elseif key == "return" or key == "space" then
                                                                                                                                    if     selectedMenu == 1 then startGame(1)
                                                                                                                                        elseif selectedMenu == 2 then state = 'level_select'; selectedLevel = 1
                                                                                                                                            elseif selectedMenu == 3 then state = 'game_modes';   selectedMode  = 1
                                                                                                                                                elseif selectedMenu == 4 then state = 'settings';     selectedSetting = 1
                                                                                                                                                    elseif selectedMenu == 5 then state = 'achievements'; selectedAchievement = 1
                                                                                                                                                        elseif selectedMenu == 6 then state = 'themes';       selectedTheme = 1
                                                                                                                                                            elseif selectedMenu == 7 then state = 'credits'
                                                                                                                                                                elseif selectedMenu == 8 then love.event.quit()
                                                                                                                                                                    end
                                                                                                                                                                    end
                                                                                                                                                                    return
                                                                                                                                                                    end

                                                                                                                                                                    -- Level Select
                                                                                                                                                                    if state == 'level_select' then
                                                                                                                                                                        if key == "up" then
                                                                                                                                                                            selectedLevel = selectedLevel - 1
                                                                                                                                                                            if selectedLevel < 1 then selectedLevel = #levels end
                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                    selectedLevel = selectedLevel + 1
                                                                                                                                                                                    if selectedLevel > #levels then selectedLevel = 1 end
                                                                                                                                                                                        elseif key == "return" or key == "space" then
                                                                                                                                                                                            if selectedLevel <= highestLevel then
                                                                                                                                                                                                startGame(selectedLevel)
                                                                                                                                                                                                end
                                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                                    state = 'menu'; selectedMenu = 1
                                                                                                                                                                                                    end
                                                                                                                                                                                                    return
                                                                                                                                                                                                    end

                                                                                                                                                                                                    -- Game Modes
                                                                                                                                                                                                    if state == 'game_modes' then
                                                                                                                                                                                                        if key == "up" then
                                                                                                                                                                                                            selectedMode = selectedMode - 1
                                                                                                                                                                                                            if selectedMode < 1 then selectedMode = #modeOptions end
                                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                                    selectedMode = selectedMode + 1
                                                                                                                                                                                                                    if selectedMode > #modeOptions then selectedMode = 1 end
                                                                                                                                                                                                                        elseif key == "return" or key == "space" then
                                                                                                                                                                                                                            gameMode = string.lower(modeOptions[selectedMode]):gsub(" ", "_")
                                                                                                                                                                                                                            startGame(1)
                                                                                                                                                                                                                            elseif key == "escape" then
                                                                                                                                                                                                                                state = 'menu'; selectedMenu = 1
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                -- Settings
                                                                                                                                                                                                                                if state == 'settings' then
                                                                                                                                                                                                                                    if key == "up" then
                                                                                                                                                                                                                                        selectedSetting = selectedSetting - 1
                                                                                                                                                                                                                                        if selectedSetting < 1 then selectedSetting = #settingsOptions end
                                                                                                                                                                                                                                            elseif key == "down" then
                                                                                                                                                                                                                                                selectedSetting = selectedSetting + 1
                                                                                                                                                                                                                                                if selectedSetting > #settingsOptions then selectedSetting = 1 end
                                                                                                                                                                                                                                                    elseif key == "left" then
                                                                                                                                                                                                                                                        updateSettings(false)
                                                                                                                                                                                                                                                        elseif key == "right" then
                                                                                                                                                                                                                                                            updateSettings(true)
                                                                                                                                                                                                                                                            elseif key == "return" or key == "space" then
                                                                                                                                                                                                                                                                if settingsOptions[selectedSetting].name:match("^Rebind") then
                                                                                                                                                                                                                                                                state = 'rebind'
                                                                                                                                                                                                                                                                rebindKey = settingsOptions[selectedSetting].name:match("Rebind (%w+)")
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                                                                                                state = 'menu'; selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Rebind
                                                                                                                                                                                                                                                                if state == 'rebind' then
                                                                                                                                                                                                                                                                if key ~= "escape" then
                                                                                                                                                                                                                                                                settings.keyBindings[rebindKey:lower()] = key
                                                                                                                                                                                                                                                                for _, opt in ipairs(settingsOptions) do
                                                                                                                                                                                                                                                                if opt.name == "Rebind " .. rebindKey then
                                                                                                                                                                                                                                                                opt.values = {"Current: " .. key}
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                applySettings()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                state = 'settings'
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Achievements
                                                                                                                                                                                                                                                                if state == 'achievements' then
                                                                                                                                                                                                                                                                if key == "up" then
                                                                                                                                                                                                                                                                selectedAchievement = selectedAchievement - 1
                                                                                                                                                                                                                                                                if selectedAchievement < 1 then selectedAchievement = #achievementList end
                                                                                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                                                                                selectedAchievement = selectedAchievement + 1
                                                                                                                                                                                                                                                                if selectedAchievement > #achievementList then selectedAchievement = 1 end
                                                                                                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                                                                                                state = 'menu'; selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Pause
                                                                                                                                                                                                                                                                if state == 'pause' then
                                                                                                                                                                                                                                                                if key == "up" then
                                                                                                                                                                                                                                                                selectedPause = selectedPause - 1
                                                                                                                                                                                                                                                                if selectedPause < 1 then selectedPause = #pauseOptions end
                                                                                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                                                                                selectedPause = selectedPause + 1
                                                                                                                                                                                                                                                                if selectedPause > #pauseOptions then selectedPause = 1 end
                                                                                                                                                                                                                                                                elseif key == "return" or key == "space" then
                                                                                                                                                                                                                                                                if     selectedPause == 1 then state = 'game'
                                                                                                                                                                                                                                                                elseif selectedPause == 2 then state = 'settings'; selectedSetting = 1
                                                                                                                                                                                                                                                                elseif selectedPause == 3 then state = 'menu';     selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif key == "escape" or key == "p" then
                                                                                                                                                                                                                                                                state = 'game'
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Credits
                                                                                                                                                                                                                                                                if state == 'credits' then
                                                                                                                                                                                                                                                                if key == "escape" then state = 'menu'; selectedMenu = 1 end
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Themes
                                                                                                                                                                                                                                                                if state == 'themes' then
                                                                                                                                                                                                                                                                if key == "up" then
                                                                                                                                                                                                                                                                selectedTheme = selectedTheme - 1
                                                                                                                                                                                                                                                                if selectedTheme < 1 then selectedTheme = #themeOptions end
                                                                                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                                                                                selectedTheme = selectedTheme + 1
                                                                                                                                                                                                                                                                if selectedTheme > #themeOptions then selectedTheme = 1 end
                                                                                                                                                                                                                                                                elseif key == "return" or key == "space" then
                                                                                                                                                                                                                                                                settings.theme = string.lower(themeOptions[selectedTheme])
                                                                                                                                                                                                                                                                applySettings()
                                                                                                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                                                                                                state = 'menu'; selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                                                                -- Pomocnicze: startGame
                                                                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                                                                function startGame(level)
                                                                                                                                                                                                                                                                state        = 'game'
                                                                                                                                                                                                                                                                currentLevel = level
                                                                                                                                                                                                                                                                lives        = (gameMode == 'practice') and math.huge or 3
                                                                                                                                                                                                                                                                score        = 0
                                                                                                                                                                                                                                                                gameOver     = false
                                                                                                                                                                                                                                                                gameWon      = false
                                                                                                                                                                                                                                                                loadLevel(currentLevel)
                                                                                                                                                                                                                                                                end
