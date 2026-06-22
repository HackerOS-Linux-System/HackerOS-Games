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
    shape = 'square' -- Dodane dla customizacji w stylu GD
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
end
function updatePlayer(dt)
if player.hackTimer > 0 then player.hackTimer = player.hackTimer - dt end
    if player.invincibleTimer > 0 then player.invincibleTimer = player.invincibleTimer - dt end
        if player.speedBoostTimer > 0 then player.speedBoostTimer = player.speedBoostTimer - dt end
            -- Automatyczny bieg jak w GD
            local currentSpeed = (player.speedBoostTimer > 0 and player.autoSpeed * 1.5 or player.autoSpeed) + (gameMode == 'endless' and timeElapsed * 0.1 or 0) -- Zwiększanie prędkości w endless
            player.x = player.x + currentSpeed * dt
            if love.keyboard.isDown(settings.keyBindings.right) then
                player.x = player.x + player.speed * dt
                end
                if love.keyboard.isDown(settings.keyBindings.left) then
                    player.x = player.x - (player.speed / 2) * dt
                    end
                    -- Skok i double jump
                    if love.keyboard.isDown(settings.keyBindings.jump) and not player.isJumping then
                        player.velocityY = player.jumpPower
                        player.isJumping = true
                        createParticles(player.x + player.width / 2, player.y + player.height, 10, {0, 1, 0})
                        elseif love.keyboard.isDown(settings.keyBindings.jump) and player.doubleJumpAvailable and player.velocityY > 0 then
                            player.velocityY = player.jumpPower * 0.8
                            player.doubleJumpAvailable = false
                            createParticles(player.x + player.width / 2, player.y + player.height, 15, {0, 1, 0.5})
                            end
                            -- Hacking
                            if love.keyboard.isDown(settings.keyBindings.hack) and player.hackTimer <= 0 then
                                player.hackTimer = 10
                                for _, enemy in ipairs(enemies) do
                                    if math.abs(enemy.x - player.x) < 300 then
                                        enemy.disabled = true
                                        end
                                        end
                                        createParticles(player.x + player.width / 2, player.y + player.height / 2, 20, {0, 1, 1})
                                        unlockAchievement("hacker")
                                        end
                                        -- Grawitacja
                                        player.velocityY = player.velocityY + gravity * dt
                                        player.y = player.y + player.velocityY * dt
                                        -- Kolizje z platformami
                                        playerOnGround = false
                                        for _, platform in ipairs(platforms) do
                                            if checkCollision(player, platform) then
                                                if player.velocityY > 0 then
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
                                                        -- Kolizje z kolcami/wrogami
                                                        if not player.invincible then
                                                            for _, spike in ipairs(spikes) do
                                                                if checkCollision(player, spike) then
                                                                    if player.shield then
                                                                        player.shield = false
                                                                        createParticles(player.x + player.width / 2, player.y + player.height / 2, 20, {1, 1, 1})
                                                                        else
                                                                            loseLife()
                                                                            end
                                                                            end
                                                                            end
                                                                            for _, enemy in ipairs(enemies) do
                                                                                if not enemy.disabled and checkCircleCollision(player, enemy) then
                                                                                    if player.shield then
                                                                                        player.shield = false
                                                                                        createParticles(player.x + player.width / 2, player.y + player.height / 2, 20, {1, 1, 1})
                                                                                        else
                                                                                            loseLife()
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
                                                                                                                                            -- Timery
                                                                                                                                            if player.invincibleTimer <= 0 then player.invincible = false end
                                                                                                                                                if comboTimer > 0 then
                                                                                                                                                    comboTimer = comboTimer - dt
                                                                                                                                                    if comboTimer <= 0 then multiplier = 1 end
                                                                                                                                                        end
                                                                                                                                                        -- Update particles
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
                                                                                                                                                                function drawPlayer()
                                                                                                                                                                local playerColor = {0, 1, 1}
                                                                                                                                                                if player.invincible then
                                                                                                                                                                    love.graphics.setColor(1, 1, 1, 0.5 + 0.5 * math.sin(love.timer.getTime() * 10)) -- Migotanie
                                                                                                                                                                    love.graphics.rectangle("fill", player.x - 10, player.y - 10, player.width + 20, player.height + 20)
                                                                                                                                                                    end
                                                                                                                                                                    if player.speedBoostTimer > 0 then
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
                                                                                                                                                                                            love.graphics.polygon("fill", player.x, player.y + player.height, player.x + player.width / 2, player.y, player.x + player.width, player.y + player.height)
                                                                                                                                                                                            end
                                                                                                                                                                                            for _, p in ipairs(player.particles) do
                                                                                                                                                                                                love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life / 0.5)
                                                                                                                                                                                                love.graphics.circle("fill", p.x, p.y, 3)
                                                                                                                                                                                                end
                                                                                                                                                                                                end
                                                                                                                                                                                                function loseLife()
                                                                                                                                                                                                lives = lives - 1
                                                                                                                                                                                                if lives <= 0 then
                                                                                                                                                                                                    gameOver = true
                                                                                                                                                                                                    else
                                                                                                                                                                                                        resetPlayer()
                                                                                                                                                                                                        player.x = 50
                                                                                                                                                                                                        player.y = 500
                                                                                                                                                                                                        camera.x = 0
                                                                                                                                                                                                        end
                                                                                                                                                                                                        end
