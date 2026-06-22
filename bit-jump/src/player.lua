player = {
    x = 50,
    y = 500,
    width = 40,
    height = 40,
    speed = 300,
    autoSpeed = 200,
    jumpPower = -500,
    velocityY = 0,
    isJumping = false,
    doubleJumpAvailable = false,
    invincible = false,
    invincibleTimer = 0,
    hackTimer = 0,
    speedBoostTimer = 0,
    shield = false,
    particles = {},
    shape = 'square',
    hitFlashTimer = 0
}

gravity = 1000

function resetPlayer()
player.x = 50
player.y = 500
player.velocityY = 0
player.isJumping = false
player.doubleJumpAvailable = false
player.invincible = false
player.invincibleTimer = 0
player.hackTimer = 0
player.speedBoostTimer = 0
player.shield = false
player.particles = {}
player.hitFlashTimer = 0
end

-- Śledzenie poprzedniego stanu klawisza skoku, aby uniknąć ciągłego skakania
local jumpKeyWasDown = false
local hackKeyWasDown = false

function updatePlayer(dt)
if player.hackTimer > 0 then player.hackTimer = player.hackTimer - dt end
    if player.invincibleTimer > 0 then player.invincibleTimer = player.invincibleTimer - dt end
        if player.speedBoostTimer > 0 then player.speedBoostTimer = player.speedBoostTimer - dt end
            if player.hitFlashTimer > 0 then player.hitFlashTimer = player.hitFlashTimer - dt end

                -- Automatyczny bieg w stylu Geometry Dash
                local endlessBoost = (gameMode == 'endless') and (timeElapsed * 0.1) or 0
                local currentSpeed = (player.speedBoostTimer > 0 and player.autoSpeed * 1.5 or player.autoSpeed) + endlessBoost
                player.x = player.x + currentSpeed * dt

                if love.keyboard.isDown(settings.keyBindings.right) then
                    player.x = player.x + player.speed * dt
                    end
                    if love.keyboard.isDown(settings.keyBindings.left) then
                        player.x = player.x - (player.speed / 2) * dt
                        if player.x < camera.x then player.x = camera.x end
                            end

                            -- Skok i double jump z wykrywaniem zbocza (zapobiega ciągłemu skakaniu przy trzymaniu klawisza)
                            local jumpKeyDown = love.keyboard.isDown(settings.keyBindings.jump)
                            local jumpPressed = jumpKeyDown and not jumpKeyWasDown
                            jumpKeyWasDown = jumpKeyDown

                            if jumpPressed then
                                if not player.isJumping then
                                    player.velocityY = player.jumpPower
                                    player.isJumping = true
                                    createParticles(player.x + player.width / 2, player.y + player.height, 10, {0, 1, 0})
                                    elseif player.doubleJumpAvailable then
                                        player.velocityY = player.jumpPower * 0.8
                                        player.doubleJumpAvailable = false
                                        createParticles(player.x + player.width / 2, player.y + player.height, 15, {0, 1, 0.5})
                                        end
                                        end

                                        -- Hakowanie (wyłącza pobliskich wrogów na chwilę)
                                        local hackKeyDown = love.keyboard.isDown(settings.keyBindings.hack)
                                        local hackPressed = hackKeyDown and not hackKeyWasDown
                                        hackKeyWasDown = hackKeyDown

                                        if hackPressed and player.hackTimer <= 0 then
                                            player.hackTimer = 10
                                            for _, enemy in ipairs(enemies) do
                                                if math.abs(enemy.x - player.x) < 300 and enemy.type ~= 'boss' then
                                                    enemy.disabled = true
                                                    enemy.disabledTimer = 4
                                                    end
                                                    end
                                                    createParticles(player.x + player.width / 2, player.y + player.height / 2, 20, {0, 1, 1})
                                                    unlockAchievement("hacker")
                                                    end

                                                    -- Grawitacja
                                                    player.velocityY = player.velocityY + gravity * dt
                                                    player.y = player.y + player.velocityY * dt

                                                    -- Kolizje z platformami
                                                    local playerOnGround = false
                                                    for _, platform in ipairs(platforms) do
                                                        if checkCollision(player, platform) then
                                                            if player.velocityY > 0 and (player.y + player.height - player.velocityY * dt) <= platform.y + 1 then
                                                                player.y = platform.y - player.height
                                                                player.velocityY = 0
                                                                player.isJumping = false
                                                                player.doubleJumpAvailable = true
                                                                playerOnGround = true
                                                                end
                                                                end
                                                                end
                                                                if not playerOnGround then
                                                                    player.isJumping = true
                                                                    end

                                                                    -- Kolizje z kolcami
                                                                    if not player.invincible then
                                                                        for _, spike in ipairs(spikes) do
                                                                            if checkCollision(player, spike) then
                                                                                damagePlayer()
                                                                                break
                                                                                end
                                                                                end

                                                                                -- Kolizje z wrogami
                                                                                for _, enemy in ipairs(enemies) do
                                                                                    if not enemy.disabled and enemy.type ~= 'boss' and
                                                                                        checkCircleCollision(player, enemy) then
                                                                                        damagePlayer()
                                                                                        break
                                                                                        end
                                                                                        end

                                                                                        -- Kolizje z bossem (ciało) i jego pociskami
                                                                                        for _, enemy in ipairs(enemies) do
                                                                                            if enemy.type == 'boss' and not enemy.disabled then
                                                                                                if checkCircleCollision(player, enemy) then
                                                                                                    damagePlayer()
                                                                                                    end
                                                                                                    if enemy.projectiles then
                                                                                                        for pi = #enemy.projectiles, 1, -1 do
                                                                                                            local proj = enemy.projectiles[pi]
                                                                                                            if checkCircleCollision(player, proj) then
                                                                                                                damagePlayer()
                                                                                                                table.remove(enemy.projectiles, pi)
                                                                                                                end
                                                                                                                end
                                                                                                                end
                                                                                                                end
                                                                                                                end
                                                                                                                end

                                                                                                                -- Zbieranie danych
                                                                                                                for _, d in ipairs(data) do
                                                                                                                    if not d.collected and checkCircleCollision(player, {x = d.x + 10, y = d.y + 10, radius = 10}) then
                                                                                                                        d.collected = true
                                                                                                                        comboTimer = 3
                                                                                                                        multiplier = math.min(multiplier + 0.5, 5)
                                                                                                                        score = score + 10 * multiplier
                                                                                                                        createParticles(d.x, d.y, 15, {1, 1, 0})

                                                                                                                        local collectedCount = 0
                                                                                                                        for _, item in ipairs(data) do
                                                                                                                            if item.collected then collectedCount = collectedCount + 1 end
                                                                                                                                end
                                                                                                                                if collectedCount == #data then
                                                                                                                                    unlockAchievement("data_collector")
                                                                                                                                    end
                                                                                                                                    if multiplier >= 5 then
                                                                                                                                        unlockAchievement("perfect_run")
                                                                                                                                        end
                                                                                                                                        end
                                                                                                                                        end

                                                                                                                                        -- Zbieranie power-upów
                                                                                                                                        for _, p in ipairs(powerups) do
                                                                                                                                            if not p.collected and checkCircleCollision(player, {x = p.x + 10, y = p.y + 10, radius = 10}) then
                                                                                                                                                p.collected = true
                                                                                                                                                if p.type == 'invincibility' then
                                                                                                                                                    player.invincible = true
                                                                                                                                                    player.invincibleTimer = 5
                                                                                                                                                    createParticles(p.x, p.y, 20, {0, 0, 1})
                                                                                                                                                    elseif p.type == 'speed' then
                                                                                                                                                        player.speedBoostTimer = 5
                                                                                                                                                        createParticles(p.x, p.y, 20, {1, 0, 1})
                                                                                                                                                        unlockAchievement("speed_demon")
                                                                                                                                                        elseif p.type == 'double_jump' then
                                                                                                                                                            player.doubleJumpAvailable = true
                                                                                                                                                            createParticles(p.x, p.y, 20, {0, 1, 0.5})
                                                                                                                                                            elseif p.type == 'shield' then
                                                                                                                                                                player.shield = true
                                                                                                                                                                createParticles(p.x, p.y, 20, {1, 1, 1})
                                                                                                                                                                end
                                                                                                                                                                end
                                                                                                                                                                end

                                                                                                                                                                if player.invincibleTimer <= 0 then player.invincible = false end

                                                                                                                                                                    if comboTimer > 0 then
                                                                                                                                                                        comboTimer = comboTimer - dt
                                                                                                                                                                        if comboTimer <= 0 then multiplier = 1 end
                                                                                                                                                                            end

                                                                                                                                                                            -- Aktualizacja cząsteczek
                                                                                                                                                                            for i = #player.particles, 1, -1 do
                                                                                                                                                                                local p = player.particles[i]
                                                                                                                                                                                p.x = p.x + p.vx * dt
                                                                                                                                                                                p.y = p.y + p.vy * dt
                                                                                                                                                                                p.life = p.life - dt
                                                                                                                                                                                if p.life <= 0 then
                                                                                                                                                                                    table.remove(player.particles, i)
                                                                                                                                                                                    end
                                                                                                                                                                                    end
                                                                                                                                                                                    end

                                                                                                                                                                                    function damagePlayer()
                                                                                                                                                                                    if player.shield then
                                                                                                                                                                                        player.shield = false
                                                                                                                                                                                        createParticles(player.x + player.width / 2, player.y + player.height / 2, 20, {1, 1, 1})
                                                                                                                                                                                        triggerScreenShake(4, 0.15)
                                                                                                                                                                                        else
                                                                                                                                                                                            triggerScreenShake(8, 0.25)
                                                                                                                                                                                            player.hitFlashTimer = 0.3
                                                                                                                                                                                            loseLife()
                                                                                                                                                                                            end
                                                                                                                                                                                            end

                                                                                                                                                                                            function drawPlayer()
                                                                                                                                                                                            local playerColor = {0, 1, 1}

                                                                                                                                                                                            if player.invincible then
                                                                                                                                                                                                love.graphics.setColor(1, 1, 1, 0.5 + 0.5 * math.sin(love.timer.getTime() * 10))
                                                                                                                                                                                                love.graphics.rectangle("fill", player.x - 10, player.y - 10, player.width + 20, player.height + 20)
                                                                                                                                                                                                end

                                                                                                                                                                                                if player.hitFlashTimer > 0 then
                                                                                                                                                                                                    playerColor = {1, 0.2, 0.2}
                                                                                                                                                                                                    elseif player.speedBoostTimer > 0 then
                                                                                                                                                                                                        playerColor = {1, 0, 1}
                                                                                                                                                                                                        elseif player.doubleJumpAvailable then
                                                                                                                                                                                                            playerColor = {0, 1, 0.5}
                                                                                                                                                                                                            elseif player.shield then
                                                                                                                                                                                                                playerColor = {1, 1, 1}
                                                                                                                                                                                                                end

                                                                                                                                                                                                                love.graphics.setColor(playerColor)
                                                                                                                                                                                                                if player.shape == 'square' then
                                                                                                                                                                                                                    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
                                                                                                                                                                                                                    elseif player.shape == 'circle' then
                                                                                                                                                                                                                        love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, player.width / 2)
                                                                                                                                                                                                                        elseif player.shape == 'triangle' then
                                                                                                                                                                                                                            love.graphics.polygon("fill",
                                                                                                                                                                                                                                                  player.x, player.y + player.height,
                                                                                                                                                                                                                                                  player.x + player.width / 2, player.y,
                                                                                                                                                                                                                                                  player.x + player.width, player.y + player.height)
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            if player.shield then
                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1, 0.4)
                                                                                                                                                                                                                                love.graphics.circle("line", player.x + player.width / 2, player.y + player.height / 2, player.width * 0.8)
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                for _, p in ipairs(player.particles) do
                                                                                                                                                                                                                                    love.graphics.setColor(p.color[1], p.color[2], p.color[3], math.max(p.life / p.maxLife, 0))
                                                                                                                                                                                                                                    love.graphics.circle("fill", p.x, p.y, 3)
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    function loseLife()
                                                                                                                                                                                                                                    lives = lives - 1
                                                                                                                                                                                                                                    if lives <= 0 then
                                                                                                                                                                                                                                        gameOver = true
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            local keepX = player.x
                                                                                                                                                                                                                                            resetPlayer()
                                                                                                                                                                                                                                            player.x = 50
                                                                                                                                                                                                                                            player.y = 500
                                                                                                                                                                                                                                            camera.x = 0
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            end
