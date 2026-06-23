function updateLevel(dt)
-- Platformy ruchome i rotujące
for _, p in ipairs(platforms) do
    if p.moving then
        if p.axis == 'y' then
            p.y = p.y + p.speed * dt
            if math.abs(p.y - p.baseY) > p.range / 2 then
                p.speed = -p.speed
                end
                else
                    p.x = p.x + p.speed * dt
                    if math.abs(p.x - p.baseX) > p.range / 2 then
                        p.speed = -p.speed
                        end
                        end
                        end
                        if p.rotating then
                            local angle = love.timer.getTime() * p.speed
                            p.x = p.centerX + math.cos(angle) * p.radius
                            p.y = p.centerY + math.sin(angle) * p.radius
                            end
                            end

                            -- Opadające kolce
                            local screenH = love.graphics.getHeight()
                            for _, fs in ipairs(fallingSpikes) do
                                fs.y = fs.y + fs.speed * dt
                                if fs.y > screenH + 60 then
                                    fs.y = math.random(-900, -40)
                                    end
                                    if not player.invincible then
                                        if checkCollision(player,
                                        {x = fs.x, y = fs.y, width = fs.width, height = fs.height}) then
                                        damagePlayer()
                                        end
                                        end
                                        end

                                        -- Wrogowie
                                        for _, e in ipairs(enemies) do
                                            if e.disabled then
                                                if e.disabledTimer > 0 then
                                                    e.disabledTimer = e.disabledTimer - dt
                                                    if e.disabledTimer <= 0 then e.disabled = false end
                                                        end
                                                        else
                                                            if     e.type == 'drone'  then updateDrone(e, dt)
                                                                elseif e.type == 'patrol' then updatePatrol(e, dt)
                                                                    elseif e.type == 'boss'   then updateBoss(e, dt, 1)
                                                                        elseif e.type == 'boss2'  then updateBoss(e, dt, 2)
                                                                            elseif e.type == 'archon' then updateBoss(e, dt, 3)
                                                                                end
                                                                                end
                                                                                end
                                                                                end

                                                                                function updateDrone(e, dt)
                                                                                e.y = e.y + e.speed * e.dir * dt
                                                                                if math.abs(e.y - e.baseY) > e.range / 2 then
                                                                                    e.dir = -e.dir
                                                                                    end
                                                                                    end

                                                                                    function updatePatrol(e, dt)
                                                                                    e.x = e.x + e.speed * e.dir * dt
                                                                                    if math.abs(e.x - e.baseX) > e.range / 2 then
                                                                                        e.dir = -e.dir
                                                                                        end
                                                                                        end

                                                                                        -- ============================================================
                                                                                        -- updateBoss (tier 1/2/3)
                                                                                        -- ============================================================
                                                                                        function updateBoss(e, dt, tier)
                                                                                        -- Ruch bossa
                                                                                        e.x = e.x + e.speed * e.dir * dt
                                                                                        if math.abs(e.x - e.baseX) > e.range / 2 then e.dir = -e.dir end

                                                                                            -- Fazy (tier 2+)
                                                                                            if tier >= 2 then
                                                                                                local r = e.health / e.maxHealth
                                                                                                if r <= 0.5 and e.phase == 1 then
                                                                                                    e.phase         = 2
                                                                                                    e.speed         = e.speed * 1.4
                                                                                                    e.shootInterval = e.shootInterval * 0.65
                                                                                                    end
                                                                                                    if tier == 3 and r <= 0.25 and e.phase == 2 then
                                                                                                        e.phase         = 3
                                                                                                        e.speed         = e.speed * 1.3
                                                                                                        e.shootInterval = e.shootInterval * 0.7
                                                                                                        end
                                                                                                        end

                                                                                                        -- Strzał
                                                                                                        e.shootTimer = e.shootTimer - dt
                                                                                                        if e.shootTimer <= 0 then
                                                                                                            e.shootTimer = e.shootInterval
                                                                                                            local shots = 1
                                                                                                            if tier == 2 then
                                                                                                                shots = (e.phase == 2) and 3 or 2
                                                                                                                elseif tier == 3 then
                                                                                                                    shots = (e.phase == 3) and 5 or (e.phase == 2 and 3 or 2)
                                                                                                                    end

                                                                                                                    for i = 1, shots do
                                                                                                                        local angle = math.atan2(player.y - e.y, player.x - e.x)
                                                                                                                        + (i - (shots + 1) / 2) * 0.28
                                                                                                                        local spd   = 260 + tier * 40
                                                                                                                        table.insert(e.projectiles, {
                                                                                                                            x = e.x, y = e.y,
                                                                                                                            vx = math.cos(angle) * spd,
                                                                                                                                     vy = math.sin(angle) * spd,
                                                                                                                                     radius = 8, life = 4.5
                                                                                                                        })
                                                                                                                        end
                                                                                                                        createParticles(e.x, e.y, 10, {1, 0.2, 0.2})
                                                                                                                        end

                                                                                                                        -- Pociski
                                                                                                                        for i = #e.projectiles, 1, -1 do
                                                                                                                            local pr = e.projectiles[i]
                                                                                                                            pr.x    = pr.x + pr.vx * dt
                                                                                                                            pr.y    = pr.y + pr.vy * dt
                                                                                                                            pr.life = pr.life - dt
                                                                                                                            if pr.life <= 0 then table.remove(e.projectiles, i) end
                                                                                                                                end
                                                                                                                                end

                                                                                                                                -- ============================================================
                                                                                                                                -- tryDamageBoss – gracz skacze na bossa
                                                                                                                                -- ============================================================
                                                                                                                                function tryDamageBoss(boss)
                                                                                                                                if player.velocityY > 0
                                                                                                                                    and (player.y + player.height) <= (boss.y + 12)
                                                                                                                                    and checkCircleCollision(player, boss) then
                                                                                                                                    boss.health      = boss.health - 1
                                                                                                                                    player.velocityY = player.jumpPower * 0.6
                                                                                                                                    createParticles(boss.x, boss.y, 28, {1, 0.55, 0})
                                                                                                                                    triggerScreenShake(12, 0.35)
                                                                                                                                    if boss.health <= 0 then
                                                                                                                                        boss.disabled = true
                                                                                                                                        score = score + 500 * multiplier
                                                                                                                                        createParticles(boss.x, boss.y, 80, {1, 1, 0})
                                                                                                                                        unlockAchievement("boss_slayer")
                                                                                                                                        end
                                                                                                                                        return true
                                                                                                                                        end
                                                                                                                                        return false
                                                                                                                                        end

                                                                                                                                        -- ============================================================
                                                                                                                                        -- drawLevel
                                                                                                                                        -- ============================================================
                                                                                                                                        function drawLevel()
                                                                                                                                        local W   = love.graphics.getWidth()
                                                                                                                                        local H   = love.graphics.getHeight()
                                                                                                                                        local col = getCurrentColor()
                                                                                                                                        local t   = love.timer.getTime()

                                                                                                                                        -- Tło
                                                                                                                                        love.graphics.setBackgroundColor(col.bg[1], col.bg[2], col.bg[3])

                                                                                                                                        -- Siatka parallax – dwie warstwy
                                                                                                                                        love.graphics.setColor(col.grid1[1], col.grid1[2], col.grid1[3], 0.45)
                                                                                                                                        for x = (-camera.x * 0.25) % 120, W + 120, 120 do
                                                                                                                                            love.graphics.line(x, 0, x, H)
                                                                                                                                            end
                                                                                                                                            for y = 0, H, 80 do love.graphics.line(0, y, W, y) end

                                                                                                                                                love.graphics.setColor(col.grid2[1], col.grid2[2], col.grid2[3], 0.3)
                                                                                                                                                for x = (-camera.x * 0.55) % 60, W + 60, 60 do
                                                                                                                                                    love.graphics.line(x, 0, x, H)
                                                                                                                                                    end
                                                                                                                                                    for y = 0, H, 40 do love.graphics.line(0, y, W, y) end

                                                                                                                                                        -- Platformy
                                                                                                                                                        for _, p in ipairs(platforms) do
                                                                                                                                                            local br = p.rotating and 0.6 or (p.moving and 0.8 or 0.5)
                                                                                                                                                            love.graphics.setColor(
                                                                                                                                                                col.accent[1] * br, col.accent[2] * br, col.accent[3] * br)
                                                                                                                                                            love.graphics.rectangle("fill", p.x, p.y, p.width, p.height)
                                                                                                                                                            love.graphics.setColor(col.accent[1], col.accent[2], col.accent[3], 0.9)
                                                                                                                                                            love.graphics.rectangle("line", p.x, p.y, p.width, p.height)
                                                                                                                                                            -- Świecąca krawędź górna
                                                                                                                                                            love.graphics.setColor(col.accent[1], col.accent[2], col.accent[3], 0.55)
                                                                                                                                                            love.graphics.line(p.x + 1, p.y, p.x + p.width - 1, p.y)
                                                                                                                                                            end

                                                                                                                                                            -- Kolce statyczne (trójkąty skierowane w górę)
                                                                                                                                                            love.graphics.setColor(1, 0.15, 0.15)
                                                                                                                                                            for _, s in ipairs(spikes) do
                                                                                                                                                                love.graphics.polygon("fill",
                                                                                                                                                                                      s.x,            s.y + s.height,
                                                                                                                                                                                      s.x + s.width/2, s.y,
                                                                                                                                                                                      s.x + s.width,  s.y + s.height)
                                                                                                                                                                love.graphics.setColor(1, 0.5, 0.5, 0.5)
                                                                                                                                                                love.graphics.polygon("line",
                                                                                                                                                                                      s.x,            s.y + s.height,
                                                                                                                                                                                      s.x + s.width/2, s.y,
                                                                                                                                                                                      s.x + s.width,  s.y + s.height)
                                                                                                                                                                love.graphics.setColor(1, 0.15, 0.15)
                                                                                                                                                                end

                                                                                                                                                                -- Opadające kolce (skierowane w dół)
                                                                                                                                                                love.graphics.setColor(1, 0.45, 0.1)
                                                                                                                                                                for _, fs in ipairs(fallingSpikes) do
                                                                                                                                                                    love.graphics.polygon("fill",
                                                                                                                                                                                          fs.x,             fs.y,
                                                                                                                                                                                          fs.x + fs.width/2, fs.y + fs.height,
                                                                                                                                                                                          fs.x + fs.width,  fs.y)
                                                                                                                                                                    love.graphics.setColor(1, 0.75, 0.4, 0.5)
                                                                                                                                                                    love.graphics.polygon("line",
                                                                                                                                                                                          fs.x,             fs.y,
                                                                                                                                                                                          fs.x + fs.width/2, fs.y + fs.height,
                                                                                                                                                                                          fs.x + fs.width,  fs.y)
                                                                                                                                                                    love.graphics.setColor(1, 0.45, 0.1)
                                                                                                                                                                    end

                                                                                                                                                                    -- Dane do zebrania
                                                                                                                                                                    for _, d in ipairs(data) do
                                                                                                                                                                        if not d.collected then
                                                                                                                                                                            local pulse = 0.75 + 0.25 * math.sin(t * 3 + d.x * 0.01)
                                                                                                                                                                            love.graphics.setColor(1, 1, 0, pulse)
                                                                                                                                                                            love.graphics.circle("fill", d.x + 10, d.y + 10, 10)
                                                                                                                                                                            love.graphics.setColor(1, 1, 0.5, pulse * 0.5)
                                                                                                                                                                            love.graphics.circle("fill", d.x + 10, d.y + 10, 5)
                                                                                                                                                                            love.graphics.setColor(1, 1, 1, 0.3)
                                                                                                                                                                            love.graphics.circle("line", d.x + 10, d.y + 10, 14)
                                                                                                                                                                            end
                                                                                                                                                                            end

                                                                                                                                                                            -- Power-upy
                                                                                                                                                                            local pwrC = {
                                                                                                                                                                                invincibility = {0.3, 0.6, 1},
                                                                                                                                                                                speed         = {1,   0.2, 1},
                                                                                                                                                                                double_jump   = {0.2, 1,   0.5},
                                                                                                                                                                                shield        = {0.9, 0.9, 0.9},
                                                                                                                                                                            }
                                                                                                                                                                            local pwrL = {invincibility="I", speed="S", double_jump="J", shield="H"}
                                                                                                                                                                            for _, p in ipairs(powerups) do
                                                                                                                                                                                if not p.collected then
                                                                                                                                                                                    local bob = math.sin(t * 4 + p.x * 0.02) * 5
                                                                                                                                                                                    local c   = pwrC[p.type] or {1, 1, 1}
                                                                                                                                                                                    love.graphics.setColor(c[1], c[2], c[3], 0.9)
                                                                                                                                                                                    love.graphics.rectangle("fill", p.x, p.y + bob, 22, 22, 4, 4)
                                                                                                                                                                                    love.graphics.setColor(1, 1, 1, 0.55)
                                                                                                                                                                                    love.graphics.rectangle("line", p.x, p.y + bob, 22, 22, 4, 4)
                                                                                                                                                                                    love.graphics.setColor(0, 0, 0)
                                                                                                                                                                                    love.graphics.print(pwrL[p.type] or "?", p.x + 6, p.y + 4 + bob)
                                                                                                                                                                                    end
                                                                                                                                                                                    end

                                                                                                                                                                                    -- Wrogowie
                                                                                                                                                                                    for _, e in ipairs(enemies) do
                                                                                                                                                                                        drawEnemy(e, t)
                                                                                                                                                                                        end

                                                                                                                                                                                        -- Cel
                                                                                                                                                                                        local gp = 0.6 + 0.4 * math.sin(t * 3)
                                                                                                                                                                                        love.graphics.setColor(0, gp, 0)
                                                                                                                                                                                        love.graphics.rectangle("fill", goal.x, goal.y, goal.width, goal.height)
                                                                                                                                                                                        love.graphics.setColor(col.accent[1], col.accent[2], col.accent[3], 0.8)
                                                                                                                                                                                        love.graphics.rectangle("line", goal.x, goal.y, goal.width, goal.height)
                                                                                                                                                                                        love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                        love.graphics.print("CEL", goal.x + 6, goal.y + 16)
                                                                                                                                                                                        end

                                                                                                                                                                                        -- ============================================================
                                                                                                                                                                                        -- drawEnemy
                                                                                                                                                                                        -- ============================================================
                                                                                                                                                                                        function drawEnemy(e, t)
                                                                                                                                                                                        if e.disabled then
                                                                                                                                                                                            love.graphics.setColor(0.3, 0.3, 0.3)
                                                                                                                                                                                            love.graphics.circle("fill", e.x, e.y, e.radius)
                                                                                                                                                                                            return
                                                                                                                                                                                            end

                                                                                                                                                                                            if e.type == 'drone' then
                                                                                                                                                                                                local g = 0.7 + 0.3 * math.sin(t * 5 + e.x)
                                                                                                                                                                                                love.graphics.setColor(1, 0.5 * g, 0.1)
                                                                                                                                                                                                love.graphics.circle("fill", e.x, e.y, e.radius)
                                                                                                                                                                                                love.graphics.setColor(1, 0.8, 0.5, 0.3)
                                                                                                                                                                                                love.graphics.circle("fill", e.x, e.y, e.radius + 6)
                                                                                                                                                                                                love.graphics.setColor(0, 0, 0)
                                                                                                                                                                                                love.graphics.line(e.x - 7, e.y - 3, e.x + 7, e.y - 3)

                                                                                                                                                                                                elseif e.type == 'patrol' then
                                                                                                                                                                                                    love.graphics.setColor(1, 0.1, 0.1)
                                                                                                                                                                                                    love.graphics.circle("fill", e.x, e.y, e.radius)
                                                                                                                                                                                                    love.graphics.setColor(1, 0.4, 0.4, 0.25)
                                                                                                                                                                                                    love.graphics.circle("fill", e.x, e.y, e.radius + 4)

                                                                                                                                                                                                    elseif e.type == 'boss' or e.type == 'boss2' or e.type == 'archon' then
                                                                                                                                                                                                        drawBoss(e, t)
                                                                                                                                                                                                        end
                                                                                                                                                                                                        end

                                                                                                                                                                                                        -- ============================================================
                                                                                                                                                                                                        -- drawBoss
                                                                                                                                                                                                        -- ============================================================
                                                                                                                                                                                                        function drawBoss(e, t)
                                                                                                                                                                                                        local r   = e.health / e.maxHealth
                                                                                                                                                                                                        local glow = 0.55 + 0.45 * math.sin(t * 4)
                                                                                                                                                                                                        local bc
                                                                                                                                                                                                        if     e.type == 'archon' then bc = {1, r*0.15, 0.9}
                                                                                                                                                                                                        elseif e.type == 'boss2'  then bc = {1, r*0.3,  0.4}
                                                                                                                                                                                                        else                           bc = {1, r*0.4,  0.2}
                                                                                                                                                                                                        end

                                                                                                                                                                                                        -- Aura zewnętrzna
                                                                                                                                                                                                        love.graphics.setColor(bc[1], bc[2], bc[3], 0.18 * glow)
                                                                                                                                                                                                        love.graphics.circle("fill", e.x, e.y, e.radius + 22)

                                                                                                                                                                                                        -- Ciało
                                                                                                                                                                                                        love.graphics.setColor(bc[1], bc[2], bc[3])
                                                                                                                                                                                                        love.graphics.circle("fill", e.x, e.y, e.radius)
                                                                                                                                                                                                        love.graphics.setColor(1, 1, 1, 0.65)
                                                                                                                                                                                                        love.graphics.circle("line", e.x, e.y, e.radius)

                                                                                                                                                                                                        -- Pasek HP
                                                                                                                                                                                                        local bw = e.radius * 2 + 30
                                                                                                                                                                                                        local bx = e.x - bw / 2
                                                                                                                                                                                                        local by = e.y - e.radius - 26
                                                                                                                                                                                                        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
                                                                                                                                                                                                        love.graphics.rectangle("fill", bx, by, bw, 10)
                                                                                                                                                                                                        love.graphics.setColor(bc[1] * 0.9, 0.1, 0.1)
                                                                                                                                                                                                        love.graphics.rectangle("fill", bx, by, bw * r, 10)
                                                                                                                                                                                                        love.graphics.setColor(bc[1], bc[2], bc[3])
                                                                                                                                                                                                        love.graphics.rectangle("fill", bx, by, bw * r, 4)  -- jasny pas u góry
                                                                                                                                                                                                        love.graphics.setColor(1, 1, 1, 0.8)
                                                                                                                                                                                                        love.graphics.rectangle("line", bx, by, bw, 10)

                                                                                                                                                                                                        -- Nazwa i HP
                                                                                                                                                                                                        local name = (e.type == 'archon') and "ARCHON"
                                                                                                                                                                                                        or (e.type == 'boss2')  and "CYBER-TYTAN"
                                                                                                                                                                                                        or "STRAZNIK"
                                                                                                                                                                                                        love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                        love.graphics.print(name .. "  " .. e.health .. "/" .. e.maxHealth,
                                                                                                                                                                                                                            bx, by - 17)

                                                                                                                                                                                                        -- Faza
                                                                                                                                                                                                        if e.phase and e.phase > 1 then
                                                                                                                                                                                                            love.graphics.setColor(1, 0.8, 0)
                                                                                                                                                                                                            love.graphics.print("FAZA " .. e.phase, e.x - 22, e.y - e.radius - 44)
                                                                                                                                                                                                            end

                                                                                                                                                                                                            -- Pociski
                                                                                                                                                                                                            for _, pr in ipairs(e.projectiles) do
                                                                                                                                                                                                                love.graphics.setColor(1, 0.2, 0.2)
                                                                                                                                                                                                                love.graphics.circle("fill", pr.x, pr.y, pr.radius)
                                                                                                                                                                                                                love.graphics.setColor(1, 0.7, 0.7, 0.35)
                                                                                                                                                                                                                love.graphics.circle("fill", pr.x, pr.y, pr.radius + 5)
                                                                                                                                                                                                                end
                                                                                                                                                                                                                end

                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                -- updateGame
                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                function updateGame(dt)
                                                                                                                                                                                                                if gameOver or gameWon then return end

                                                                                                                                                                                                                    timeElapsed = timeElapsed + dt
                                                                                                                                                                                                                    if gameMode == 'time_attack' and timeElapsed > timeLimit then
                                                                                                                                                                                                                        gameOver = true
                                                                                                                                                                                                                        return
                                                                                                                                                                                                                        end

                                                                                                                                                                                                                        updatePlayer(dt)
                                                                                                                                                                                                                        updateLevel(dt)
                                                                                                                                                                                                                        updateScreenShake(dt)
                                                                                                                                                                                                                        updateAchievementNotifications(dt)

                                                                                                                                                                                                                        -- Boss: obrażenia przez skakanie
                                                                                                                                                                                                                        for _, e in ipairs(enemies) do
                                                                                                                                                                                                                            if (e.type == 'boss' or e.type == 'boss2' or e.type == 'archon')
                                                                                                                                                                                                                                and not e.disabled then
                                                                                                                                                                                                                                tryDamageBoss(e)
                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                -- Kamera z płynnym wyprzedzeniem
                                                                                                                                                                                                                                local targetX = player.x - love.graphics.getWidth() / 2 + 130
                                                                                                                                                                                                                                camera.x = camera.x + (targetX - camera.x) * 0.15 * dt * 60
                                                                                                                                                                                                                                if camera.x < 0 then camera.x = 0 end

                                                                                                                                                                                                                                    -- Kolizja z celem
                                                                                                                                                                                                                                    if checkCollision(player, goal) then
                                                                                                                                                                                                                                        if gameMode == 'endless' then
                                                                                                                                                                                                                                            currentLevel = (currentLevel % #levels) + 1
                                                                                                                                                                                                                                            loadLevel(currentLevel)
                                                                                                                                                                                                                                            player.autoSpeed = player.autoSpeed + 20
                                                                                                                                                                                                                                            unlockAchievement("endless_runner")
                                                                                                                                                                                                                                            elseif currentLevel < #levels then
                                                                                                                                                                                                                                                currentLevel = currentLevel + 1
                                                                                                                                                                                                                                                if currentLevel > highestLevel then
                                                                                                                                                                                                                                                    highestLevel = currentLevel
                                                                                                                                                                                                                                                    saveHighestLevel(highestLevel)
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    loadLevel(currentLevel)
                                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                                        gameWon = true
                                                                                                                                                                                                                                                        unlockAchievement("game_winner")
                                                                                                                                                                                                                                                        unlockAchievement("completionist")
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                        if score > highScore then
                                                                                                                                                                                                                                                            highScore = score
                                                                                                                                                                                                                                                            saveHighScore(highScore)
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            if player.y > love.graphics.getHeight() + 150 then
                                                                                                                                                                                                                                                                damagePlayer()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                                                                -- drawGame
                                                                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                                                                function drawGame()
                                                                                                                                                                                                                                                                local W   = love.graphics.getWidth()
                                                                                                                                                                                                                                                                local H   = love.graphics.getHeight()
                                                                                                                                                                                                                                                                local col = getCurrentColor()

                                                                                                                                                                                                                                                                local sx, sy = getScreenShakeOffset()
                                                                                                                                                                                                                                                                love.graphics.translate(-camera.x + sx, sy)
                                                                                                                                                                                                                                                                drawLevel()
                                                                                                                                                                                                                                                                drawPlayer()
                                                                                                                                                                                                                                                                love.graphics.translate(camera.x - sx, -sy)

                                                                                                                                                                                                                                                                -- HUD: panel tła
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.45)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 4, 4, 190, 220, 4, 4)

                                                                                                                                                                                                                                                                love.graphics.setColor(col.accent)
                                                                                                                                                                                                                                                                love.graphics.print("Score:  "  .. math.floor(score),    10, 10)
                                                                                                                                                                                                                                                                love.graphics.print("Best:   "  .. math.floor(highScore),10, 27)
                                                                                                                                                                                                                                                                love.graphics.print("Level:  "  .. currentLevel .. " / " .. #levels, 10, 44)
                                                                                                                                                                                                                                                                local livesStr = (lives == math.huge) and "∞" or tostring(math.floor(lives))
                                                                                                                                                                                                                                                                love.graphics.print("Lives:  "  .. livesStr,             10, 61)
                                                                                                                                                                                                                                                                love.graphics.print("Mult:  x"  .. string.format("%.1f", multiplier), 10, 78)

                                                                                                                                                                                                                                                                local yo = 97
                                                                                                                                                                                                                                                                if player.invincible then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.5, 0.7, 1)
                                                                                                                                                                                                                                                                love.graphics.print(string.format("INVINCIBLE %.1fs", player.invincibleTimer), 10, yo)
                                                                                                                                                                                                                                                                yo = yo + 17
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.hackTimer > 0 then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print("HACK CD " .. math.ceil(player.hackTimer) .. "s", 10, yo)
                                                                                                                                                                                                                                                                yo = yo + 17
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.speedBoostTimer > 0 then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 1)
                                                                                                                                                                                                                                                                love.graphics.print(string.format("SPEED %.1fs", player.speedBoostTimer), 10, yo)
                                                                                                                                                                                                                                                                yo = yo + 17
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.doubleJumpAvailable then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.2, 1, 0.6)
                                                                                                                                                                                                                                                                love.graphics.print("DBL JUMP!", 10, yo)
                                                                                                                                                                                                                                                                yo = yo + 17
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.shield then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.95, 0.95, 0.95)
                                                                                                                                                                                                                                                                love.graphics.print("TARCZA", 10, yo)
                                                                                                                                                                                                                                                                yo = yo + 17
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if gameMode == 'time_attack' then
                                                                                                                                                                                                                                                                local left = math.ceil(timeLimit - timeElapsed)
                                                                                                                                                                                                                                                                love.graphics.setColor(left < 10 and {1, 0.2, 0.2} or col.accent)
                                                                                                                                                                                                                                                                love.graphics.print("CZAS: " .. left .. "s", 10, yo)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Pasek postępu
                                                                                                                                                                                                                                                                local progress = math.min(math.max(player.x / (goal.x + goal.width), 0), 1)
                                                                                                                                                                                                                                                                love.graphics.setColor(0.08, 0.08, 0.08, 0.8)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 10, H - 26, 200, 14, 3, 3)
                                                                                                                                                                                                                                                                love.graphics.setColor(col.accent)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 10, H - 26, 200 * progress, 14, 3, 3)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1, 0.55)
                                                                                                                                                                                                                                                                love.graphics.rectangle("line", 10, H - 26, 200, 14, 3, 3)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print(math.floor(progress * 100) .. "%", 216, H - 28)

                                                                                                                                                                                                                                                                -- Powiadomienia osiągnięć
                                                                                                                                                                                                                                                                drawAchievementNotifications()

                                                                                                                                                                                                                                                                -- Nakładka koniec gry
                                                                                                                                                                                                                                                                if gameOver or gameWon then
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.68)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, W, H)
                                                                                                                                                                                                                                                                if gameOver then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.15, 0.15)
                                                                                                                                                                                                                                                                love.graphics.print("GAME OVER", W/2 - 95, H/2 - 50, 0, 2.3, 2.3)
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                love.graphics.setColor(0.15, 1, 0.4)
                                                                                                                                                                                                                                                                love.graphics.print("WYGRALES!", W/2 - 95, H/2 - 55, 0, 2.3, 2.3)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 0)
                                                                                                                                                                                                                                                                love.graphics.print("Rekord: " .. math.floor(highScore),
                                                                                                                                                                                                                                                                W/2 - 80, H/2 + 10, 0, 1.4, 1.4)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print("R – restart      Esc – menu", W/2 - 115, H/2 + 52)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
