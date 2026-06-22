function checkCollision(a, b)
return a.x < b.x + b.width and
a.x + a.width > b.x and
a.y < b.y + b.height and
a.y + a.height > b.y
end

function checkCircleCollision(a, circle)
-- a = prostokąt {x, y, width, height}, circle = {x, y, radius}
local closestX = math.max(a.x, math.min(circle.x, a.x + a.width))
local closestY = math.max(a.y, math.min(circle.y, a.y + a.height))
local dx = closestX - circle.x
local dy = closestY - circle.y
return (dx * dx + dy * dy) < (circle.radius ^ 2)
end

function checkCircleCircleCollision(a, b)
-- a, b = {x, y, radius}
local dx = a.x - b.x
local dy = a.y - b.y
local r = (a.radius or 0) + (b.radius or 0)
return (dx * dx + dy * dy) < (r * r)
end

function createParticles(x, y, count, color)
for i = 1, count do
    table.insert(player.particles, {
        x = x,
        y = y,
        vx = math.random(-200, 200),
                 vy = math.random(-200, 200),
                 life = math.random(30, 70) / 100,
                 maxLife = 0.7,
                 color = color
    })
    end
    end

    -- Proste "screen shake" wykorzystywane przy trafieniach/śmierci
    screenShake = {timer = 0, intensity = 0}
    function triggerScreenShake(intensity, duration)
    screenShake.timer = duration or 0.2
    screenShake.intensity = intensity or 6
    end

    function updateScreenShake(dt)
    if screenShake.timer > 0 then
        screenShake.timer = screenShake.timer - dt
        if screenShake.timer < 0 then screenShake.timer = 0 end
            end
            end

            function getScreenShakeOffset()
            if screenShake.timer > 0 then
                local i = screenShake.intensity
                return math.random(-i, i), math.random(-i, i)
                end
                return 0, 0
                end

                -- Zapis / odczyt wyniku
                function saveHighScore(score)
                love.filesystem.write("highscore.txt", tostring(score))
                end

                function loadHighScore()
                local data = love.filesystem.read("highscore.txt")
                return data and tonumber(data) or 0
                end

                function saveHighestLevel(level)
                love.filesystem.write("highestlevel.txt", tostring(level))
                end

                function loadHighestLevel()
                local data = love.filesystem.read("highestlevel.txt")
                return data and tonumber(data) or 1
                end

                -- Osiągnięcia
                achievementList = {
                    "hacker", "data_collector", "endless_runner", "game_winner",
                    "perfect_run", "speed_demon", "boss_slayer", "no_hit_level", "completionist"
                }

                function saveAchievements()
                local data = ""
                for k, v in pairs(achievements) do
                    data = data .. k .. "=" .. tostring(v) .. "\n"
                    end
                    love.filesystem.write("achievements.txt", data)
                    end

                    function loadAchievements()
                    local ach = {}
                    for _, name in ipairs(achievementList) do
                        ach[name] = false
                        end
                        local data = love.filesystem.read("achievements.txt")
                        if data then
                            for line in data:gmatch("[^\r\n]+") do
                                local k, v = line:match("(%w+)=(%w+)")
                                if k and v then
                                    ach[k] = (v == "true")
                                    end
                                    end
                                    end
                                    return ach
                                    end

                                    achievementNotifQueue = {}
                                    function unlockAchievement(name)
                                    if achievements[name] == false then
                                        achievements[name] = true
                                        saveAchievements()
                                        table.insert(achievementNotifQueue, {text = "Osiągnięcie: " .. name, timer = 3})
                                        end
                                        end

                                        function updateAchievementNotifications(dt)
                                        for i = #achievementNotifQueue, 1, -1 do
                                            achievementNotifQueue[i].timer = achievementNotifQueue[i].timer - dt
                                            if achievementNotifQueue[i].timer <= 0 then
                                                table.remove(achievementNotifQueue, i)
                                                end
                                                end
                                                end

                                                function drawAchievementNotifications()
                                                love.graphics.setColor(1, 1, 0, 0.9)
                                                for i, notif in ipairs(achievementNotifQueue) do
                                                    love.graphics.print(notif.text, 10, 230 + (i - 1) * 20)
                                                    end
                                                    end
