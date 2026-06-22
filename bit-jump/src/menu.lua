menuOptions = {"Start Game", "Level Select", "Game Modes", "Settings", "Achievements", "Themes", "Credits", "Exit"} -- Rozbudowane menu
selectedMenu = 1
pauseOptions = {"Resume", "Settings", "Main Menu"}
selectedPause = 1
modeOptions = {"Normal", "Time Attack", "Endless", "Practice"} -- Dodany practice mode
selectedMode = 1
selectedLevel = 1
selectedAchievement = 1
creditsText = "Bit Jump - Inspired by Geometry Dash\nDeveloped by [Your Name]\nArt: Open Source\nThanks for playing!"
selectedCredit = 1
themeOptions = {"Dark", "Light", "Neon", "Retro"} -- Nowe opcje themes
selectedTheme = 1
function drawMenu()
love.graphics.setColor(1, 1, 1)
if logo then -- Only draw logo if it exists
    love.graphics.draw(logo, 300, 50, 0, 0.5, 0.5)
    else
        love.graphics.print("Bit Jump", 300, 50, 0, 2, 2) -- Fallback text
        end
        for i, option in ipairs(menuOptions) do
            if i == selectedMenu then
                love.graphics.setColor(1, 1, 0)
                love.graphics.print(option, 300, 200 + (i-1)*40, 0, 1.2, 1.2) -- Lekka animacja wielkości
                else
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(option, 300, 200 + (i-1)*40)
                    end
                    end
                    end
                    function drawLevelSelect()
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print("Level Select", 300, 100, 0, 2, 2)
                    for i = 1, #levels do
                        if i == selectedLevel then
                            love.graphics.setColor(1, 1, 0)
                            else
                                love.graphics.setColor(1, 1, 1)
                                end
                                local status = (i <= highestLevel) and "Unlocked" or "Locked"
                                love.graphics.print("Level " .. i .. " (" .. status .. ")", 300, 200 + (i-1)*40)
                                end
                                love.graphics.setColor(1, 1, 1)
                                love.graphics.print("Esc to Back", 300, 500)
                                end
                                function drawGameModes()
                                love.graphics.setColor(1, 1, 1)
                                love.graphics.print("Game Modes", 300, 100, 0, 2, 2)
                                for i, mode in ipairs(modeOptions) do
                                    if i == selectedMode then
                                        love.graphics.setColor(1, 1, 0)
                                        else
                                            love.graphics.setColor(1, 1, 1)
                                            end
                                            love.graphics.print(mode, 300, 200 + (i-1)*40)
                                            end
                                            love.graphics.setColor(1, 1, 1)
                                            love.graphics.print("Esc to Back", 300, 500)
                                            end
                                            function drawPause()
                                            love.graphics.setColor(1, 1, 1)
                                            love.graphics.print("Paused", 300, 100, 0, 2, 2)
                                            for i, option in ipairs(pauseOptions) do
                                                if i == selectedPause then
                                                    love.graphics.setColor(1, 1, 0)
                                                    else
                                                        love.graphics.setColor(1, 1, 1)
                                                        end
                                                        love.graphics.print(option, 300, 200 + (i-1)*40)
                                                        end
                                                        end
                                                        function drawAchievements()
                                                        love.graphics.setColor(1, 1, 1)
                                                        love.graphics.print("Achievements", 300, 100, 0, 2, 2)
                                                        local achList = {"hacker", "data_collector", "endless_runner", "game_winner", "perfect_run", "speed_demon"} -- Dodane nowe osiągnięcia
                                                        for i, ach in ipairs(achList) do
                                                            if i == selectedAchievement then
                                                                love.graphics.setColor(1, 1, 0)
                                                                else
                                                                    love.graphics.setColor(1, 1, 1)
                                                                    end
                                                                    local status = achievements[ach] and "Unlocked" or "Locked"
                                                                    love.graphics.print(ach .. ": " .. status, 300, 200 + (i-1)*40)
                                                                    end
                                                                    love.graphics.setColor(1, 1, 1)
                                                                    love.graphics.print("Esc to Back", 300, 500)
                                                                    end
                                                                    function drawCredits()
                                                                    love.graphics.setColor(1, 1, 1)
                                                                    love.graphics.print("Credits", 300, 100, 0, 2, 2)
                                                                    love.graphics.print(creditsText, 200, 200)
                                                                    love.graphics.print("Esc to Back", 300, 500)
                                                                    end
                                                                    function drawThemes()
                                                                    love.graphics.setColor(1, 1, 1)
                                                                    love.graphics.print("Themes", 300, 100, 0, 2, 2)
                                                                    for i, theme in ipairs(themeOptions) do
                                                                        if i == selectedTheme then
                                                                            love.graphics.setColor(1, 1, 0)
                                                                            else
                                                                                love.graphics.setColor(1, 1, 1)
                                                                                end
                                                                                love.graphics.print(theme, 300, 200 + (i-1)*40)
                                                                                end
                                                                                love.graphics.setColor(1, 1, 1)
                                                                                love.graphics.print("Esc to Back", 300, 500)
                                                                                end
                                                                                function handleKeyPressed(key)
                                                                                if state == 'game' then
                                                                                    if key == "r" and (gameOver or gameWon) then
                                                                                        lives = 3
                                                                                        loadLevel(currentLevel)
                                                                                        score = 0
                                                                                        gameOver = false
                                                                                        gameWon = false
                                                                                        elseif key == "escape" or key == "p" and not (gameOver or gameWon) then
                                                                                            state = 'pause'
                                                                                            selectedPause = 1
                                                                                            end
                                                                                            elseif state == 'menu' then
                                                                                                if key == "up" then
                                                                                                    selectedMenu = selectedMenu - 1
                                                                                                    if selectedMenu < 1 then selectedMenu = #menuOptions end
                                                                                                        elseif key == "down" then
                                                                                                            selectedMenu = selectedMenu + 1
                                                                                                            if selectedMenu > #menuOptions then selectedMenu = 1 end
                                                                                                                elseif key == "return" or key == "space" then
                                                                                                                    if selectedMenu == 1 then
                                                                                                                        state = 'game'
                                                                                                                        currentLevel = 1
                                                                                                                        lives = 3
                                                                                                                        loadLevel(currentLevel)
                                                                                                                        score = 0
                                                                                                                        gameOver = false
                                                                                                                        gameWon = false
                                                                                                                        elseif selectedMenu == 2 then
                                                                                                                            state = 'level_select'
                                                                                                                            selectedLevel = 1
                                                                                                                            elseif selectedMenu == 3 then
                                                                                                                                state = 'game_modes'
                                                                                                                                selectedMode = 1
                                                                                                                                elseif selectedMenu == 4 then
                                                                                                                                    state = 'settings'
                                                                                                                                    selectedSetting = 1
                                                                                                                                    elseif selectedMenu == 5 then
                                                                                                                                        state = 'achievements'
                                                                                                                                        selectedAchievement = 1
                                                                                                                                        elseif selectedMenu == 6 then
                                                                                                                                            state = 'themes'
                                                                                                                                            selectedTheme = 1
                                                                                                                                            elseif selectedMenu == 7 then
                                                                                                                                                state = 'credits'
                                                                                                                                                elseif selectedMenu == 8 then
                                                                                                                                                    love.event.quit()
                                                                                                                                                    end
                                                                                                                                                    end
                                                                                                                                                    elseif state == 'level_select' then
                                                                                                                                                        if key == "up" then
                                                                                                                                                            selectedLevel = selectedLevel - 1
                                                                                                                                                            if selectedLevel < 1 then selectedLevel = #levels end
                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                    selectedLevel = selectedLevel + 1
                                                                                                                                                                    if selectedLevel > #levels then selectedLevel = 1 end
                                                                                                                                                                        elseif key == "return" or key == "space" then
                                                                                                                                                                            if selectedLevel <= highestLevel then
                                                                                                                                                                                state = 'game'
                                                                                                                                                                                currentLevel = selectedLevel
                                                                                                                                                                                lives = 3
                                                                                                                                                                                loadLevel(currentLevel)
                                                                                                                                                                                score = 0
                                                                                                                                                                                gameOver = false
                                                                                                                                                                                gameWon = false
                                                                                                                                                                                end
                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                    state = 'menu'
                                                                                                                                                                                    selectedMenu = 1
                                                                                                                                                                                    end
                                                                                                                                                                                    elseif state == 'game_modes' then
                                                                                                                                                                                        if key == "up" then
                                                                                                                                                                                            selectedMode = selectedMode - 1
                                                                                                                                                                                            if selectedMode < 1 then selectedMode = #modeOptions end
                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                    selectedMode = selectedMode + 1
                                                                                                                                                                                                    if selectedMode > #modeOptions then selectedMode = 1 end
                                                                                                                                                                                                        elseif key == "return" or key == "space" then
                                                                                                                                                                                                            gameMode = string.lower(modeOptions[selectedMode])
                                                                                                                                                                                                            state = 'game'
                                                                                                                                                                                                            currentLevel = 1
                                                                                                                                                                                                            lives = (gameMode == 'practice') and math.huge or 3 -- Nieskończone życia w practice
                                                                                                                                                                                                            loadLevel(currentLevel)
                                                                                                                                                                                                            score = 0
                                                                                                                                                                                                            gameOver = false
                                                                                                                                                                                                            gameWon = false
                                                                                                                                                                                                            elseif key == "escape" then
                                                                                                                                                                                                                state = 'menu'
                                                                                                                                                                                                                selectedMenu = 1
                                                                                                                                                                                                                end
                                                                                                                                                                                                                elseif state == 'settings' then
                                                                                                                                                                                                                    if key == "up" then
                                                                                                                                                                                                                        selectedSetting = selectedSetting - 1
                                                                                                                                                                                                                        if selectedSetting < 1 then selectedSetting = #settingsOptions end
                                                                                                                                                                                                                            elseif key == "down" then
                                                                                                                                                                                                                                selectedSetting = selectedSetting + 1
                                                                                                                                                                                                                                if selectedSetting > #settingsOptions then selectedSetting = 1 end
                                                                                                                                                                                                                                    elseif key == "left" or key == "right" then
                                                                                                                                                                                                                                        updateSettings(key == "right")
                                                                                                                                                                                                                                        elseif key == "return" or key == "space" then
                                                                                                                                                                                                                                            if settingsOptions[selectedSetting].name:match("^Rebind") then
                                                                                                                                                                                                                                                state = 'rebind'
                                                                                                                                                                                                                                                rebindKey = settingsOptions[selectedSetting].name:match("Rebind (%w+)")
                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                                                                                    state = 'menu'
                                                                                                                                                                                                                                                    selectedMenu = 1
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    elseif state == 'rebind' then
                                                                                                                                                                                                                                                        if key ~= "escape" then
                                                                                                                                                                                                                                                            settings.keyBindings[rebindKey:lower()] = key
                                                                                                                                                                                                                                                            for _, opt in ipairs(settingsOptions) do
                                                                                                                                                                                                                                                                if opt.name == "Rebind " .. rebindKey then
                                                                                                                                                                                                                                                                opt.values = {"Current: " .. key}
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                applySettings()
                                                                                                                                                                                                                                                                state = 'settings'
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif state == 'achievements' then
                                                                                                                                                                                                                                                                if key == "up" then
                                                                                                                                                                                                                                                                selectedAchievement = selectedAchievement - 1
                                                                                                                                                                                                                                                                if selectedAchievement < 1 then selectedAchievement = 6 end
                                                                                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                                                                                selectedAchievement = selectedAchievement + 1
                                                                                                                                                                                                                                                                if selectedAchievement > 6 then selectedAchievement = 1 end
                                                                                                                                                                                                                                                                elseif key == "escape" then
                                                                                                                                                                                                                                                                state = 'menu'
                                                                                                                                                                                                                                                                selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif state == 'pause' then
                                                                                                                                                                                                                                                                if key == "up" then
                                                                                                                                                                                                                                                                selectedPause = selectedPause - 1
                                                                                                                                                                                                                                                                if selectedPause < 1 then selectedPause = #pauseOptions end
                                                                                                                                                                                                                                                                elseif key == "down" then
                                                                                                                                                                                                                                                                selectedPause = selectedPause + 1
                                                                                                                                                                                                                                                                if selectedPause > #pauseOptions then selectedPause = 1 end
                                                                                                                                                                                                                                                                elseif key == "return" or key == "space" then
                                                                                                                                                                                                                                                                if selectedPause == 1 then
                                                                                                                                                                                                                                                                state = 'game'
                                                                                                                                                                                                                                                                elseif selectedPause == 2 then
                                                                                                                                                                                                                                                                state = 'settings'
                                                                                                                                                                                                                                                                selectedSetting = 1
                                                                                                                                                                                                                                                                elseif selectedPause == 3 then
                                                                                                                                                                                                                                                                state = 'menu'
                                                                                                                                                                                                                                                                selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif key == "escape" or key == "p" then
                                                                                                                                                                                                                                                                state = 'game'
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif state == 'credits' then
                                                                                                                                                                                                                                                                if key == "escape" then
                                                                                                                                                                                                                                                                state = 'menu'
                                                                                                                                                                                                                                                                selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                elseif state == 'themes' then
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
                                                                                                                                                                                                                                                                state = 'menu'
                                                                                                                                                                                                                                                                selectedMenu = 1
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
