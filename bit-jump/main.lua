require("src/utils")
require("src/settings")
require("src/player")
require("src/levels")
require("src/menu")

function love.load()
love.window.setTitle("Bit Jump")

-- Globalne zmienne stanu
state        = 'menu'
gameOver     = false
gameWon      = false
currentLevel = 1
score        = 0
lives        = 3
highScore    = loadHighScore()
highestLevel = loadHighestLevel()
gameMode     = 'normal'
timeElapsed  = 0
timeLimit    = 0
multiplier   = 1
comboTimer   = 0
hitThisLevel = true
achievements = loadAchievements()
rebindKey    = nil

-- Inicjalizacja ustawień (ustawia player.shape, grawitację itd.)
applySettings()

-- Logo (opcjonalne – umieść images/bit-jump.png)
logo = nil
if love.filesystem.getInfo("images/bit-jump.png") then
    local ok, img = pcall(love.graphics.newImage, "images/bit-jump.png")
    if ok then logo = img end
        end

        loadLevel(currentLevel)
        end

        function love.update(dt)
        -- Ogranicz dt żeby uniknąć "teleportacji" po pauzach systemowych
        dt = math.min(dt, 0.05)

        if state == 'game' then
            updateGame(dt)
            elseif state == 'menu' or state == 'level_select' or
                state == 'game_modes' or state == 'themes' or
                state == 'achievements' or state == 'credits' or
                state == 'settings' then
                updateMenu(dt)
                end
                end

                function love.draw()
                if     state == 'game'         then drawGame()
                    elseif state == 'menu'         then drawMenu()
                        elseif state == 'level_select' then drawLevelSelect()
                            elseif state == 'game_modes'   then drawGameModes()
                                elseif state == 'settings'     then drawSettings()
                                    elseif state == 'pause'        then drawGame(); drawPause()
                                        elseif state == 'achievements' then drawAchievements()
                                            elseif state == 'credits'      then drawCredits()
                                                elseif state == 'themes'       then drawThemes()
                                                    end
                                                    end

                                                    function love.keypressed(key)
                                                    handleKeyPressed(key)
                                                    end

                                                    function love.resize(w, h)
                                                    -- Obsługa zmiany rozmiaru okna
                                                    end
