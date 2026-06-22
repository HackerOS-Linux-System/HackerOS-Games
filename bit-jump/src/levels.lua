camera = {x = 0}

levels = {
    -- Poziom 1
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 300, y = 400, width = 200, height = 20},
            {x = 600, y = 300, width = 150, height = 20, moving = true, speed = 100, range = 200, baseX = 600},
            {x = 900, y = 450, width = 200, height = 20},
            {x = 1200, y = 350, width = 150, height = 20},
            {x = 1500, y = 450, width = 200, height = 20, moving = true, speed = 120, range = 150, baseY = 450, axis = 'y'},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200, height = 20},
            {x = 2700, y = 300, width = 150, height = 20},
            {x = 3100, y = 550, width = 1000, height = 50}
        },
        spikes = {
            {x = 400, y = 530, width = 20, height = 20},
            {x = 700, y = 280, width = 20, height = 20},
            {x = 1000, y = 430, width = 20, height = 20},
            {x = 1300, y = 330, width = 20, height = 20},
            {x = 1600, y = 430, width = 20, height = 20},
            {x = 2000, y = 530, width = 20, height = 20},
            {x = 2500, y = 380, width = 20, height = 20},
            {x = 2900, y = 280, width = 20, height = 20}
        },
        data = {
            {x = 350, y = 350, collected = false},
            {x = 650, y = 250, collected = false},
            {x = 950, y = 400, collected = false},
            {x = 1250, y = 300, collected = false},
            {x = 1550, y = 400, collected = false},
            {x = 1950, y = 350, collected = false},
            {x = 2450, y = 350, collected = false}
        },
        enemies = {
            {x = 500, y = 500, radius = 20, speed = 100, dir = 1, range = 200, baseX = 500, disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 120, dir = -1, range = 150, baseY = 400, disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 150, dir = 1, range = 250, baseX = 2000, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 800, y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'}
        },
        goal = {x = 3800, y = 500, width = 50, height = 50}
    },
    -- Poziom 2
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 300, y = 400, width = 200, height = 20, moving = true, speed = 100, range = 200, baseX = 300},
            {x = 600, y = 300, width = 150, height = 20, moving = true, speed = 120, range = 150, baseY = 300, axis = 'y'},
            {x = 900, y = 450, width = 200, height = 20},
            {x = 1200, y = 350, width = 150, height = 20},
            {x = 1500, y = 450, width = 200, height = 20, moving = true, speed = 100, range = 200, baseX = 1500},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200, height = 20},
            {x = 2700, y = 300, width = 150, height = 20, moving = true, speed = 130, range = 100, baseY = 300, axis = 'y'},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 400, width = 200, height = 20}
        },
        spikes = {
            {x = 400, y = 530, width = 20, height = 20},
            {x = 700, y = 280, width = 20, height = 20},
            {x = 1000, y = 430, width = 20, height = 20},
            {x = 1300, y = 330, width = 20, height = 20},
            {x = 1600, y = 430, width = 20, height = 20},
            {x = 2000, y = 530, width = 20, height = 20},
            {x = 2500, y = 380, width = 20, height = 20},
            {x = 2900, y = 280, width = 20, height = 20},
            {x = 3300, y = 530, width = 20, height = 20}
        },
        data = {
            {x = 350, y = 350, collected = false},
            {x = 650, y = 250, collected = false},
            {x = 950, y = 400, collected = false},
            {x = 1250, y = 300, collected = false},
            {x = 1550, y = 400, collected = false},
            {x = 1950, y = 350, collected = false},
            {x = 2450, y = 350, collected = false},
            {x = 2950, y = 250, collected = false}
        },
        enemies = {
            {x = 500, y = 500, radius = 20, speed = 120, dir = 1, range = 250, baseX = 500, disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 140, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 160, dir = 1, range = 300, baseX = 2000, disabled = false, type = 'patrol'},
            {x = 2600, y = 400, radius = 20, speed = 130, dir = -1, range = 150, baseY = 400, disabled = false, type = 'drone'}
        },
        powerups = {
            {x = 800, y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'},
            {x = 2800, y = 250, collected = false, type = 'speed'}
        },
        goal = {x = 4000, y = 500, width = 50, height = 50}
    },
    -- Poziom 3
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 300, y = 400, width = 200, height = 20, moving = true, speed = 100, range = 200, baseX = 300},
            {x = 600, y = 300, width = 150, height = 20, moving = true, speed = 120, range = 150, baseY = 300, axis = 'y'},
            {x = 900, y = 450, width = 200, height = 20},
            {x = 1200, y = 350, width = 150, height = 20},
            {x = 1500, y = 450, width = 200, height = 20, moving = true, speed = 100, range = 200, baseX = 1500},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200, height = 20, moving = true, speed = 130, range = 100, baseY = 400, axis = 'y'},
            {x = 2700, y = 300, width = 150, height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 400, width = 200, height = 20},
            {x = 3900, y = 300, width = 150, height = 20}
        },
        spikes = {
            {x = 400, y = 530, width = 20, height = 20},
            {x = 700, y = 280, width = 20, height = 20},
            {x = 1000, y = 430, width = 20, height = 20},
            {x = 1300, y = 330, width = 20, height = 20},
            {x = 1600, y = 430, width = 20, height = 20},
            {x = 2000, y = 530, width = 20, height = 20},
            {x = 2500, y = 380, width = 20, height = 20},
            {x = 2900, y = 280, width = 20, height = 20},
            {x = 3300, y = 530, width = 20, height = 20},
            {x = 3700, y = 380, width = 20, height = 20}
        },
        data = {
            {x = 350, y = 350, collected = false},
            {x = 650, y = 250, collected = false},
            {x = 950, y = 400, collected = false},
            {x = 1250, y = 300, collected = false},
            {x = 1550, y = 400, collected = false},
            {x = 1950, y = 350, collected = false},
            {x = 2450, y = 350, collected = false},
            {x = 2950, y = 250, collected = false},
            {x = 3350, y = 500, collected = false}
        },
        enemies = {
            {x = 500, y = 500, radius = 20, speed = 130, dir = 1, range = 250, baseX = 500, disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 150, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 170, dir = 1, range = 300, baseX = 2000, disabled = false, type = 'patrol'},
            {x = 2600, y = 400, radius = 20, speed = 140, dir = -1, range = 150, baseY = 400, disabled = false, type = 'drone'},
            {x = 3200, y = 500, radius = 20, speed = 160, dir = 1, range = 250, baseX = 3200, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 800, y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'},
            {x = 2800, y = 250, collected = false, type = 'speed'},
            {x = 3400, y = 350, collected = false, type = 'double_jump'}
        },
        goal = {x = 4200, y = 500, width = 50, height = 50}
    },
    -- Poziom 4
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 300, y = 400, width = 200, height = 20, moving = true, speed = 110, range = 200, baseX = 300},
            {x = 600, y = 300, width = 150, height = 20, moving = true, speed = 130, range = 150, baseY = 300, axis = 'y'},
            {x = 900, y = 450, width = 200, height = 20},
            {x = 1200, y = 350, width = 150, height = 20, moving = true, speed = 100, range = 200, baseX = 1200},
            {x = 1500, y = 450, width = 200, height = 20},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200, height = 20, moving = true, speed = 140, range = 100, baseY = 400, axis = 'y'},
            {x = 2700, y = 300, width = 150, height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 400, width = 200, height = 20},
            {x = 3900, y = 300, width = 150, height = 20, moving = true, speed = 120, range = 150, baseX = 3900}
        },
        spikes = {
            {x = 400, y = 530, width = 20, height = 20},
            {x = 700, y = 280, width = 20, height = 20},
            {x = 1000, y = 430, width = 20, height = 20},
            {x = 1300, y = 330, width = 20, height = 20},
            {x = 1600, y = 430, width = 20, height = 20},
            {x = 2000, y = 530, width = 20, height = 20},
            {x = 2500, y = 380, width = 20, height = 20},
            {x = 2900, y = 280, width = 20, height = 20},
            {x = 3300, y = 530, width = 20, height = 20},
            {x = 3700, y = 280, width = 20, height = 20},
            {x = 4000, y = 530, width = 20, height = 20}
        },
        data = {
            {x = 350, y = 350, collected = false},
            {x = 650, y = 250, collected = false},
            {x = 950, y = 400, collected = false},
            {x = 1250, y = 300, collected = false},
            {x = 1550, y = 400, collected = false},
            {x = 1950, y = 350, collected = false},
            {x = 2450, y = 350, collected = false},
            {x = 2950, y = 250, collected = false},
            {x = 3350, y = 500, collected = false},
            {x = 3750, y = 350, collected = false}
        },
        enemies = {
            {x = 500, y = 500, radius = 20, speed = 140, dir = 1, range = 250, baseX = 500, disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 160, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 180, dir = 1, range = 300, baseX = 2000, disabled = false, type = 'patrol'},
            {x = 2600, y = 400, radius = 20, speed = 150, dir = -1, range = 150, baseY = 400, disabled = false, type = 'drone'},
            {x = 3200, y = 500, radius = 20, speed = 170, dir = 1, range = 250, baseX = 3200, disabled = false, type = 'patrol'},
            {x = 3600, y = 400, radius = 20, speed = 140, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'}
        },
        powerups = {
            {x = 800, y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'},
            {x = 2800, y = 250, collected = false, type = 'speed'},
            {x = 3400, y = 350, collected = false, type = 'double_jump'},
            {x = 3800, y = 250, collected = false, type = 'shield'}
        },
        goal = {x = 4500, y = 500, width = 50, height = 50}
    },
    -- Poziom 5
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 300, y = 400, width = 200, height = 20, moving = true, speed = 120, range = 200, baseX = 300},
            {x = 600, y = 300, width = 150, height = 20, moving = true, speed = 140, range = 150, baseY = 300, axis = 'y'},
            {x = 900, y = 450, width = 200, height = 20},
            {x = 1200, y = 350, width = 150, height = 20, moving = true, speed = 110, range = 200, baseX = 1200},
            {x = 1500, y = 450, width = 200, height = 20},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200, height = 20, moving = true, speed = 150, range = 100, baseY = 400, axis = 'y'},
            {x = 2700, y = 300, width = 150, height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 400, width = 200, height = 20, moving = true, speed = 130, range = 150, baseX = 3500},
            {x = 3900, y = 300, width = 150, height = 20},
            {x = 4300, y = 550, width = 1000, height = 50}
        },
        spikes = {
            {x = 400, y = 530, width = 20, height = 20},
            {x = 700, y = 280, width = 20, height = 20},
            {x = 1000, y = 430, width = 20, height = 20},
            {x = 1300, y = 330, width = 20, height = 20},
            {x = 1600, y = 430, width = 20, height = 20},
            {x = 2000, y = 530, width = 20, height = 20},
            {x = 2500, y = 380, width = 20, height = 20},
            {x = 2900, y = 280, width = 20, height = 20},
            {x = 3300, y = 530, width = 20, height = 20},
            {x = 3700, y = 280, width = 20, height = 20},
            {x = 4100, y = 530, width = 20, height = 20},
            {x = 4400, y = 280, width = 20, height = 20}
        },
        data = {
            {x = 350, y = 350, collected = false},
            {x = 650, y = 250, collected = false},
            {x = 950, y = 400, collected = false},
            {x = 1250, y = 300, collected = false},
            {x = 1550, y = 400, collected = false},
            {x = 1950, y = 350, collected = false},
            {x = 2450, y = 350, collected = false},
            {x = 2950, y = 250, collected = false},
            {x = 3350, y = 500, collected = false},
            {x = 3750, y = 350, collected = false},
            {x = 4150, y = 250, collected = false}
        },
        enemies = {
            {x = 500, y = 500, radius = 20, speed = 150, dir = 1, range = 250, baseX = 500, disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 170, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 190, dir = 1, range = 300, baseX = 2000, disabled = false, type = 'patrol'},
            {x = 2600, y = 400, radius = 20, speed = 160, dir = -1, range = 150, baseY = 400, disabled = false, type = 'drone'},
            {x = 3200, y = 500, radius = 20, speed = 180, dir = 1, range = 250, baseX = 3200, disabled = false, type = 'patrol'},
            {x = 3600, y = 400, radius = 20, speed = 150, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 4000, y = 500, radius = 20, speed = 170, dir = 1, range = 300, baseX = 4000, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 800, y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'},
            {x = 2800, y = 250, collected = false, type = 'speed'},
            {x = 3400, y = 350, collected = false, type = 'double_jump'},
            {x = 3800, y = 250, collected = false, type = 'shield'},
            {x = 4200, y = 350, collected = false, type = 'invincibility'}
        },
        goal = {x = 4800, y = 500, width = 50, height = 50}
    },
    -- Poziom 6: Boss level 1 – Strażnik Sieci
    {
        platforms = {
            {x = 0,    y = 550, width = 1000, height = 50},
            {x = 300,  y = 400, width = 200,  height = 20, moving = true, speed = 130, range = 200, baseX = 300},
            {x = 600,  y = 300, width = 150,  height = 20, moving = true, speed = 150, range = 150, baseY = 300, axis = 'y'},
            {x = 900,  y = 450, width = 200,  height = 20},
            {x = 1200, y = 350, width = 150,  height = 20, moving = true, speed = 120, range = 200, baseX = 1200},
            {x = 1500, y = 450, width = 200,  height = 20},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200,  height = 20, moving = true, speed = 160, range = 100, baseY = 400, axis = 'y'},
            {x = 2700, y = 300, width = 150,  height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 400, width = 200,  height = 20, moving = true, speed = 140, range = 150, baseX = 3500},
            {x = 3900, y = 300, width = 150,  height = 20},
            {x = 4300, y = 550, width = 1000, height = 50},
            {x = 4700, y = 400, width = 200,  height = 20},
            {x = 5100, y = 550, width = 1000, height = 50}
        },
        spikes = {
            {x = 400,  y = 530, width = 20, height = 20},
            {x = 700,  y = 280, width = 20, height = 20},
            {x = 1000, y = 430, width = 20, height = 20},
            {x = 1300, y = 330, width = 20, height = 20},
            {x = 1600, y = 430, width = 20, height = 20},
            {x = 2000, y = 530, width = 20, height = 20},
            {x = 2500, y = 380, width = 20, height = 20},
            {x = 2900, y = 280, width = 20, height = 20},
            {x = 3300, y = 530, width = 20, height = 20},
            {x = 3700, y = 280, width = 20, height = 20},
            {x = 4100, y = 530, width = 20, height = 20},
            {x = 4400, y = 280, width = 20, height = 20},
            {x = 4800, y = 530, width = 20, height = 20}
        },
        data = {
            {x = 350,  y = 350, collected = false},
            {x = 650,  y = 250, collected = false},
            {x = 950,  y = 400, collected = false},
            {x = 1250, y = 300, collected = false},
            {x = 1550, y = 400, collected = false},
            {x = 1950, y = 350, collected = false},
            {x = 2450, y = 350, collected = false},
            {x = 2950, y = 250, collected = false},
            {x = 3350, y = 500, collected = false},
            {x = 3750, y = 350, collected = false},
            {x = 4150, y = 250, collected = false},
            {x = 4550, y = 500, collected = false}
        },
        enemies = {
            {x = 500,  y = 500, radius = 20, speed = 160, dir = 1,  range = 250, baseX = 500,  disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 180, dir = -1, range = 200, baseY = 400,  disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 200, dir = 1,  range = 300, baseX = 2000, disabled = false, type = 'patrol'},
            {x = 2600, y = 400, radius = 20, speed = 170, dir = -1, range = 150, baseY = 400,  disabled = false, type = 'drone'},
            {x = 3200, y = 500, radius = 20, speed = 190, dir = 1,  range = 250, baseX = 3200, disabled = false, type = 'patrol'},
            {x = 3600, y = 400, radius = 20, speed = 160, dir = -1, range = 200, baseY = 400,  disabled = false, type = 'drone'},
            {x = 4000, y = 500, radius = 20, speed = 180, dir = 1,  range = 300, baseX = 4000, disabled = false, type = 'patrol'},
            -- Boss
            {x = 5300, y = 490, radius = 50, speed = 100, dir = 1, range = 200, baseX = 5300,
                disabled = false, type = 'boss', health = 3, maxHealth = 3,
                shootTimer = 2, shootInterval = 2, projectiles = {}}
        },
        powerups = {
            {x = 800,  y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'},
            {x = 2800, y = 250, collected = false, type = 'speed'},
            {x = 3400, y = 350, collected = false, type = 'double_jump'},
            {x = 3800, y = 250, collected = false, type = 'shield'},
            {x = 4200, y = 350, collected = false, type = 'invincibility'},
            {x = 4600, y = 250, collected = false, type = 'speed'}
        },
        goal = {x = 5700, y = 500, width = 50, height = 50}
    },
    -- Poziom 7: Rotujące platformy i szybkie drony
    {
        platforms = {
            {x = 0,    y = 550, width = 1000, height = 50},
            {x = 400,  y = 450, width = 150,  height = 20, moving = true, speed = 150, range = 250, baseX = 400},
            {x = 700,  y = 350, width = 200,  height = 20, moving = true, speed = 140, range = 200, baseY = 350, axis = 'y'},
            {x = 1100, y = 500, width = 150,  height = 20},
            {x = 1400, y = 400, width = 200,  height = 20, rotating = true, speed = 2, centerX = 1500, centerY = 380, radius = 100},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 300, width = 150,  height = 20, moving = true, speed = 160, range = 150, baseX = 2300},
            {x = 2700, y = 200, width = 200,  height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 450, width = 150,  height = 20},
            {x = 3900, y = 350, width = 200,  height = 20, rotating = true, speed = 2.5, centerX = 4000, centerY = 330, radius = 110},
            {x = 4300, y = 550, width = 1000, height = 50}
        },
        spikes = {
            {x = 500,  y = 430, width = 20, height = 20},
            {x = 800,  y = 330, width = 20, height = 20},
            {x = 1200, y = 480, width = 20, height = 20},
            {x = 1500, y = 380, width = 20, height = 20},
            {x = 1900, y = 530, width = 20, height = 20},
            {x = 2400, y = 280, width = 20, height = 20},
            {x = 2800, y = 180, width = 20, height = 20},
            {x = 3200, y = 530, width = 20, height = 20},
            {x = 3600, y = 430, width = 20, height = 20},
            {x = 4000, y = 330, width = 20, height = 20}
        },
        data = {
            {x = 450,  y = 400, collected = false},
            {x = 750,  y = 300, collected = false},
            {x = 1150, y = 450, collected = false},
            {x = 1450, y = 350, collected = false},
            {x = 1850, y = 500, collected = false},
            {x = 2350, y = 250, collected = false},
            {x = 2750, y = 150, collected = false},
            {x = 3150, y = 500, collected = false},
            {x = 3550, y = 400, collected = false},
            {x = 3950, y = 300, collected = false}
        },
        enemies = {
            {x = 600,  y = 500, radius = 25, speed = 170, dir = 1,  range = 300, baseX = 600,  disabled = false, type = 'patrol'},
            {x = 1300, y = 450, radius = 25, speed = 180, dir = -1, range = 250, baseY = 450,  disabled = false, type = 'drone'},
            {x = 2100, y = 500, radius = 25, speed = 190, dir = 1,  range = 350, baseX = 2100, disabled = false, type = 'patrol'},
            {x = 2800, y = 400, radius = 25, speed = 170, dir = -1, range = 200, baseY = 400,  disabled = false, type = 'drone'},
            {x = 3400, y = 500, radius = 25, speed = 200, dir = 1,  range = 300, baseX = 3400, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 900,  y = 450, collected = false, type = 'invincibility'},
            {x = 1600, y = 350, collected = false, type = 'double_jump'},
            {x = 2500, y = 300, collected = false, type = 'shield'},
            {x = 3000, y = 200, collected = false, type = 'speed'},
            {x = 3700, y = 400, collected = false, type = 'double_jump'}
        },
        goal = {x = 4800, y = 500, width = 50, height = 50}
    },
    -- Poziom 8: Szybkie rotacje i wyższe platformy
    {
        platforms = {
            {x = 0,    y = 550, width = 1000, height = 50},
            {x = 500,  y = 450, width = 200,  height = 20, rotating = true, speed = 3, centerX = 600, centerY = 420, radius = 130},
            {x = 900,  y = 350, width = 150,  height = 20, moving = true, speed = 180, range = 250, baseY = 350, axis = 'y'},
            {x = 1300, y = 500, width = 200,  height = 20},
            {x = 1700, y = 400, width = 150,  height = 20, moving = true, speed = 160, range = 200, baseX = 1700},
            {x = 2100, y = 550, width = 1000, height = 50},
            {x = 2600, y = 300, width = 200,  height = 20},
            {x = 3000, y = 200, width = 150,  height = 20, rotating = true, speed = 2.5, centerX = 3100, centerY = 180, radius = 120},
            {x = 3400, y = 550, width = 1000, height = 50},
            {x = 3900, y = 450, width = 200,  height = 20},
            {x = 4300, y = 350, width = 150,  height = 20, moving = true, speed = 190, range = 300, baseX = 4300}
        },
        spikes = {
            {x = 600,  y = 430, width = 20, height = 20},
            {x = 1000, y = 330, width = 20, height = 20},
            {x = 1400, y = 480, width = 20, height = 20},
            {x = 1800, y = 380, width = 20, height = 20},
            {x = 2200, y = 530, width = 20, height = 20},
            {x = 2700, y = 280, width = 20, height = 20},
            {x = 3100, y = 180, width = 20, height = 20},
            {x = 3500, y = 530, width = 20, height = 20},
            {x = 4000, y = 430, width = 20, height = 20},
            {x = 4400, y = 330, width = 20, height = 20}
        },
        data = {
            {x = 550,  y = 400, collected = false},
            {x = 950,  y = 300, collected = false},
            {x = 1350, y = 450, collected = false},
            {x = 1750, y = 350, collected = false},
            {x = 2150, y = 500, collected = false},
            {x = 2650, y = 250, collected = false},
            {x = 3050, y = 150, collected = false},
            {x = 3450, y = 500, collected = false},
            {x = 3950, y = 400, collected = false},
            {x = 4350, y = 300, collected = false}
        },
        enemies = {
            {x = 700,  y = 500, radius = 30, speed = 180, dir = 1,  range = 350, baseX = 700,  disabled = false, type = 'patrol'},
            {x = 1500, y = 450, radius = 30, speed = 190, dir = -1, range = 300, baseY = 450,  disabled = false, type = 'drone'},
            {x = 2300, y = 500, radius = 30, speed = 200, dir = 1,  range = 400, baseX = 2300, disabled = false, type = 'patrol'},
            {x = 3200, y = 400, radius = 30, speed = 180, dir = -1, range = 250, baseY = 400,  disabled = false, type = 'drone'},
            {x = 3800, y = 500, radius = 30, speed = 210, dir = 1,  range = 350, baseX = 3800, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 1100, y = 450, collected = false, type = 'invincibility'},
            {x = 1900, y = 350, collected = false, type = 'double_jump'},
            {x = 2800, y = 300, collected = false, type = 'shield'},
            {x = 3300, y = 200, collected = false, type = 'speed'},
            {x = 4100, y = 400, collected = false, type = 'double_jump'},
            {x = 4500, y = 300, collected = false, type = 'invincibility'}
        },
        goal = {x = 5000, y = 500, width = 50, height = 50}
    },
    -- Poziom 9: Ekstremalne prędkości
    {
        platforms = {
            {x = 0,    y = 550, width = 800,  height = 50},
            {x = 250,  y = 430, width = 130,  height = 20, moving = true, speed = 200, range = 220, baseX = 250},
            {x = 550,  y = 330, width = 130,  height = 20, moving = true, speed = 210, range = 180, baseY = 330, axis = 'y'},
            {x = 850,  y = 480, width = 130,  height = 20},
            {x = 1150, y = 380, width = 130,  height = 20, moving = true, speed = 190, range = 200, baseX = 1150},
            {x = 1450, y = 480, width = 130,  height = 20, moving = true, speed = 220, range = 100, baseY = 480, axis = 'y'},
            {x = 1750, y = 550, width = 800,  height = 50},
            {x = 2150, y = 420, width = 130,  height = 20, rotating = true, speed = 3.5, centerX = 2220, centerY = 400, radius = 100},
            {x = 2550, y = 320, width = 130,  height = 20, moving = true, speed = 230, range = 180, baseX = 2550},
            {x = 2900, y = 550, width = 800,  height = 50},
            {x = 3250, y = 430, width = 130,  height = 20, moving = true, speed = 200, range = 200, baseY = 430, axis = 'y'},
            {x = 3600, y = 330, width = 130,  height = 20, rotating = true, speed = 4, centerX = 3670, centerY = 310, radius = 90},
            {x = 3950, y = 550, width = 800,  height = 50}
        },
        spikes = {
            {x = 350,  y = 410, width = 20, height = 20},
            {x = 650,  y = 310, width = 20, height = 20},
            {x = 950,  y = 460, width = 20, height = 20},
            {x = 1250, y = 360, width = 20, height = 20},
            {x = 1550, y = 460, width = 20, height = 20},
            {x = 1850, y = 530, width = 20, height = 20},
            {x = 2250, y = 390, width = 20, height = 20},
            {x = 2650, y = 300, width = 20, height = 20},
            {x = 3000, y = 530, width = 20, height = 20},
            {x = 3350, y = 410, width = 20, height = 20},
            {x = 3700, y = 290, width = 20, height = 20},
            {x = 4050, y = 530, width = 20, height = 20}
        },
        data = {
            {x = 300,  y = 380, collected = false},
            {x = 600,  y = 280, collected = false},
            {x = 900,  y = 430, collected = false},
            {x = 1200, y = 330, collected = false},
            {x = 1500, y = 430, collected = false},
            {x = 1900, y = 480, collected = false},
            {x = 2300, y = 340, collected = false},
            {x = 2700, y = 270, collected = false},
            {x = 3050, y = 480, collected = false},
            {x = 3400, y = 380, collected = false},
            {x = 3750, y = 260, collected = false}
        },
        enemies = {
            {x = 450,  y = 500, radius = 22, speed = 220, dir = 1,  range = 280, baseX = 450,  disabled = false, type = 'patrol'},
            {x = 1050, y = 420, radius = 22, speed = 230, dir = -1, range = 220, baseY = 420,  disabled = false, type = 'drone'},
            {x = 1950, y = 500, radius = 22, speed = 240, dir = 1,  range = 330, baseX = 1950, disabled = false, type = 'patrol'},
            {x = 2750, y = 350, radius = 22, speed = 220, dir = -1, range = 180, baseY = 350,  disabled = false, type = 'drone'},
            {x = 3150, y = 500, radius = 22, speed = 250, dir = 1,  range = 280, baseX = 3150, disabled = false, type = 'patrol'},
            {x = 3700, y = 350, radius = 22, speed = 230, dir = -1, range = 200, baseY = 350,  disabled = false, type = 'drone'}
        },
        powerups = {
            {x = 700,  y = 380, collected = false, type = 'invincibility'},
            {x = 1300, y = 330, collected = false, type = 'double_jump'},
            {x = 2100, y = 430, collected = false, type = 'shield'},
            {x = 2900, y = 360, collected = false, type = 'speed'},
            {x = 3550, y = 280, collected = false, type = 'invincibility'}
        },
        goal = {x = 4600, y = 500, width = 50, height = 50}
    },
    -- ===== NOWE POZIOMY =====
    -- Poziom 10: Labirynt Dronów – gęste drony pionowe, wąskie przejścia
    {
        platforms = {
            {x = 0,    y = 550, width = 700,  height = 50},
            {x = 200,  y = 430, width = 120,  height = 15, moving = true, speed = 90,  range = 180, baseX = 200},
            {x = 450,  y = 340, width = 120,  height = 15, moving = true, speed = 110, range = 150, baseY = 340, axis = 'y'},
            {x = 700,  y = 500, width = 120,  height = 15},
            {x = 950,  y = 400, width = 120,  height = 15, moving = true, speed = 130, range = 170, baseX = 950},
            {x = 1200, y = 300, width = 120,  height = 15},
            {x = 1450, y = 420, width = 120,  height = 15, moving = true, speed = 115, range = 130, baseY = 420, axis = 'y'},
            {x = 1700, y = 550, width = 700,  height = 50},
            {x = 2050, y = 430, width = 120,  height = 15, moving = true, speed = 140, range = 200, baseX = 2050},
            {x = 2300, y = 330, width = 120,  height = 15},
            {x = 2550, y = 450, width = 120,  height = 15, moving = true, speed = 120, range = 160, baseY = 450, axis = 'y'},
            {x = 2800, y = 350, width = 120,  height = 15},
            {x = 3050, y = 470, width = 120,  height = 15, moving = true, speed = 150, range = 130, baseX = 3050},
            {x = 3300, y = 550, width = 700,  height = 50}
        },
        spikes = {
            {x = 300,  y = 410, width = 16, height = 16},
            {x = 550,  y = 320, width = 16, height = 16},
            {x = 800,  y = 480, width = 16, height = 16},
            {x = 1050, y = 380, width = 16, height = 16},
            {x = 1300, y = 280, width = 16, height = 16},
            {x = 1550, y = 400, width = 16, height = 16},
            {x = 1800, y = 530, width = 16, height = 16},
            {x = 2150, y = 410, width = 16, height = 16},
            {x = 2400, y = 310, width = 16, height = 16},
            {x = 2650, y = 430, width = 16, height = 16},
            {x = 2900, y = 330, width = 16, height = 16},
            {x = 3150, y = 450, width = 16, height = 16}
        },
        data = {
            {x = 250,  y = 380, collected = false},
            {x = 500,  y = 290, collected = false},
            {x = 750,  y = 450, collected = false},
            {x = 1000, y = 350, collected = false},
            {x = 1250, y = 250, collected = false},
            {x = 1500, y = 370, collected = false},
            {x = 1750, y = 500, collected = false},
            {x = 2100, y = 380, collected = false},
            {x = 2350, y = 280, collected = false},
            {x = 2600, y = 400, collected = false},
            {x = 2850, y = 300, collected = false},
            {x = 3100, y = 420, collected = false}
        },
        enemies = {
            -- Gęste drony pionowe
            {x = 380,  y = 420, radius = 18, speed = 200, dir = 1,  range = 200, baseY = 420, disabled = false, type = 'drone'},
            {x = 630,  y = 340, radius = 18, speed = 210, dir = -1, range = 220, baseY = 340, disabled = false, type = 'drone'},
            {x = 880,  y = 460, radius = 18, speed = 190, dir = 1,  range = 180, baseY = 460, disabled = false, type = 'drone'},
            {x = 1130, y = 360, radius = 18, speed = 220, dir = -1, range = 200, baseY = 360, disabled = false, type = 'drone'},
            {x = 1380, y = 400, radius = 18, speed = 200, dir = 1,  range = 190, baseY = 400, disabled = false, type = 'drone'},
            {x = 2100, y = 420, radius = 18, speed = 230, dir = -1, range = 210, baseY = 420, disabled = false, type = 'drone'},
            {x = 2380, y = 330, radius = 18, speed = 215, dir = 1,  range = 200, baseY = 330, disabled = false, type = 'drone'},
            {x = 2630, y = 440, radius = 18, speed = 225, dir = -1, range = 180, baseY = 440, disabled = false, type = 'drone'},
            {x = 2880, y = 350, radius = 18, speed = 210, dir = 1,  range = 195, baseY = 350, disabled = false, type = 'drone'},
            {x = 3130, y = 460, radius = 18, speed = 235, dir = -1, range = 200, baseY = 460, disabled = false, type = 'drone'}
        },
        powerups = {
            {x = 650,  y = 290, collected = false, type = 'invincibility'},
            {x = 1150, y = 260, collected = false, type = 'shield'},
            {x = 1750, y = 500, collected = false, type = 'double_jump'},
            {x = 2450, y = 270, collected = false, type = 'speed'},
            {x = 3050, y = 420, collected = false, type = 'shield'}
        },
        goal = {x = 3800, y = 500, width = 50, height = 50}
    },
    -- Poziom 11: Wulkan – opadające kolce (spike-rain), szybkie patrole
    {
        platforms = {
            {x = 0,    y = 550, width = 900,  height = 50},
            {x = 280,  y = 430, width = 140,  height = 18},
            {x = 560,  y = 350, width = 140,  height = 18, moving = true, speed = 160, range = 200, baseX = 560},
            {x = 840,  y = 470, width = 140,  height = 18},
            {x = 1120, y = 370, width = 140,  height = 18, moving = true, speed = 170, range = 150, baseY = 370, axis = 'y'},
            {x = 1400, y = 490, width = 140,  height = 18},
            {x = 1680, y = 550, width = 900,  height = 50},
            {x = 2050, y = 420, width = 140,  height = 18, moving = true, speed = 180, range = 180, baseX = 2050},
            {x = 2330, y = 320, width = 140,  height = 18},
            {x = 2610, y = 440, width = 140,  height = 18, moving = true, speed = 165, range = 160, baseY = 440, axis = 'y'},
            {x = 2890, y = 340, width = 140,  height = 18},
            {x = 3170, y = 460, width = 140,  height = 18, moving = true, speed = 190, range = 170, baseX = 3170},
            {x = 3450, y = 550, width = 900,  height = 50},
            {x = 3800, y = 410, width = 140,  height = 18, moving = true, speed = 175, range = 180, baseX = 3800},
            {x = 4100, y = 320, width = 140,  height = 18},
            {x = 4400, y = 550, width = 900,  height = 50}
        },
        spikes = {
            {x = 380,  y = 410, width = 20, height = 20},
            {x = 660,  y = 330, width = 20, height = 20},
            {x = 940,  y = 450, width = 20, height = 20},
            {x = 1220, y = 350, width = 20, height = 20},
            {x = 1500, y = 470, width = 20, height = 20},
            {x = 1780, y = 530, width = 20, height = 20},
            {x = 2150, y = 400, width = 20, height = 20},
            {x = 2430, y = 300, width = 20, height = 20},
            {x = 2710, y = 420, width = 20, height = 20},
            {x = 2990, y = 320, width = 20, height = 20},
            {x = 3270, y = 440, width = 20, height = 20},
            {x = 3550, y = 530, width = 20, height = 20},
            {x = 3900, y = 390, width = 20, height = 20},
            {x = 4200, y = 300, width = 20, height = 20}
        },
        -- Opadające kolce: specjalny typ – ruszają się w dół z baseY
        fallingSpikes = {
            {x = 450,  y = 0, width = 18, height = 18, speed = 180, baseY = 0, active = true},
            {x = 750,  y = 0, width = 18, height = 18, speed = 200, baseY = 0, active = true},
            {x = 1050, y = 0, width = 18, height = 18, speed = 160, baseY = 0, active = true},
            {x = 1350, y = 0, width = 18, height = 18, speed = 190, baseY = 0, active = true},
            {x = 1650, y = 0, width = 18, height = 18, speed = 210, baseY = 0, active = true},
            {x = 2200, y = 0, width = 18, height = 18, speed = 175, baseY = 0, active = true},
            {x = 2500, y = 0, width = 18, height = 18, speed = 195, baseY = 0, active = true},
            {x = 2800, y = 0, width = 18, height = 18, speed = 185, baseY = 0, active = true},
            {x = 3100, y = 0, width = 18, height = 18, speed = 215, baseY = 0, active = true},
            {x = 3650, y = 0, width = 18, height = 18, speed = 200, baseY = 0, active = true},
            {x = 3950, y = 0, width = 18, height = 18, speed = 180, baseY = 0, active = true}
        },
        data = {
            {x = 330,  y = 380, collected = false},
            {x = 610,  y = 300, collected = false},
            {x = 890,  y = 420, collected = false},
            {x = 1170, y = 320, collected = false},
            {x = 1450, y = 440, collected = false},
            {x = 1730, y = 500, collected = false},
            {x = 2100, y = 370, collected = false},
            {x = 2380, y = 270, collected = false},
            {x = 2660, y = 390, collected = false},
            {x = 2940, y = 290, collected = false},
            {x = 3220, y = 410, collected = false},
            {x = 3500, y = 500, collected = false},
            {x = 3850, y = 360, collected = false}
        },
        enemies = {
            {x = 500,  y = 500, radius = 22, speed = 230, dir = 1,  range = 300, baseX = 500,  disabled = false, type = 'patrol'},
            {x = 1000, y = 420, radius = 22, speed = 240, dir = -1, range = 180, baseY = 420,  disabled = false, type = 'drone'},
            {x = 1800, y = 500, radius = 22, speed = 250, dir = 1,  range = 320, baseX = 1800, disabled = false, type = 'patrol'},
            {x = 2500, y = 380, radius = 22, speed = 235, dir = -1, range = 200, baseY = 380,  disabled = false, type = 'drone'},
            {x = 3100, y = 500, radius = 22, speed = 260, dir = 1,  range = 280, baseX = 3100, disabled = false, type = 'patrol'},
            {x = 3700, y = 380, radius = 22, speed = 245, dir = -1, range = 210, baseY = 380,  disabled = false, type = 'drone'},
            {x = 4100, y = 500, radius = 22, speed = 270, dir = 1,  range = 260, baseX = 4100, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 700,  y = 310, collected = false, type = 'invincibility'},
            {x = 1250, y = 330, collected = false, type = 'shield'},
            {x = 1950, y = 470, collected = false, type = 'double_jump'},
            {x = 2700, y = 360, collected = false, type = 'speed'},
            {x = 3300, y = 410, collected = false, type = 'invincibility'},
            {x = 4000, y = 280, collected = false, type = 'shield'}
        },
        goal = {x = 5000, y = 500, width = 50, height = 50}
    },
    -- Poziom 12: Mgła Danych – bez pauzy, rozbudowane rotacje
    {
        platforms = {
            {x = 0,    y = 550, width = 800,  height = 50},
            {x = 300,  y = 450, width = 150,  height = 18, rotating = true, speed = 3,   centerX = 380,  centerY = 420, radius = 110},
            {x = 650,  y = 360, width = 150,  height = 18, moving = true, speed = 170, range = 200, baseY = 360, axis = 'y'},
            {x = 1000, y = 490, width = 150,  height = 18},
            {x = 1300, y = 390, width = 150,  height = 18, rotating = true, speed = 3.5, centerX = 1380, centerY = 360, radius = 120},
            {x = 1650, y = 490, width = 150,  height = 18, moving = true, speed = 180, range = 170, baseX = 1650},
            {x = 1950, y = 550, width = 800,  height = 50},
            {x = 2300, y = 420, width = 150,  height = 18, rotating = true, speed = 4,   centerX = 2380, centerY = 390, radius = 130},
            {x = 2700, y = 330, width = 150,  height = 18, moving = true, speed = 190, range = 200, baseX = 2700},
            {x = 3050, y = 450, width = 150,  height = 18},
            {x = 3350, y = 350, width = 150,  height = 18, rotating = true, speed = 4.5, centerX = 3430, centerY = 320, radius = 115},
            {x = 3700, y = 550, width = 800,  height = 50},
            {x = 4050, y = 430, width = 150,  height = 18, moving = true, speed = 200, range = 190, baseY = 430, axis = 'y'},
            {x = 4400, y = 340, width = 150,  height = 18}
        },
        spikes = {
            {x = 400,  y = 430, width = 18, height = 18},
            {x = 750,  y = 340, width = 18, height = 18},
            {x = 1100, y = 470, width = 18, height = 18},
            {x = 1400, y = 370, width = 18, height = 18},
            {x = 1750, y = 470, width = 18, height = 18},
            {x = 2050, y = 530, width = 18, height = 18},
            {x = 2400, y = 400, width = 18, height = 18},
            {x = 2800, y = 310, width = 18, height = 18},
            {x = 3150, y = 430, width = 18, height = 18},
            {x = 3450, y = 330, width = 18, height = 18},
            {x = 3800, y = 530, width = 18, height = 18},
            {x = 4150, y = 410, width = 18, height = 18},
            {x = 4500, y = 320, width = 18, height = 18}
        },
        data = {
            {x = 350,  y = 400, collected = false},
            {x = 700,  y = 310, collected = false},
            {x = 1050, y = 440, collected = false},
            {x = 1350, y = 340, collected = false},
            {x = 1700, y = 440, collected = false},
            {x = 2000, y = 500, collected = false},
            {x = 2350, y = 370, collected = false},
            {x = 2750, y = 280, collected = false},
            {x = 3100, y = 400, collected = false},
            {x = 3400, y = 300, collected = false},
            {x = 3750, y = 500, collected = false},
            {x = 4100, y = 380, collected = false},
            {x = 4450, y = 290, collected = false}
        },
        enemies = {
            {x = 500,  y = 500, radius = 25, speed = 230, dir = 1,  range = 280, baseX = 500,  disabled = false, type = 'patrol'},
            {x = 900,  y = 400, radius = 25, speed = 245, dir = -1, range = 220, baseY = 400,  disabled = false, type = 'drone'},
            {x = 1600, y = 500, radius = 25, speed = 260, dir = 1,  range = 300, baseX = 1600, disabled = false, type = 'patrol'},
            {x = 2100, y = 430, radius = 25, speed = 240, dir = -1, range = 200, baseY = 430,  disabled = false, type = 'drone'},
            {x = 2600, y = 500, radius = 25, speed = 270, dir = 1,  range = 270, baseX = 2600, disabled = false, type = 'patrol'},
            {x = 3200, y = 380, radius = 25, speed = 255, dir = -1, range = 210, baseY = 380,  disabled = false, type = 'drone'},
            {x = 3750, y = 500, radius = 25, speed = 280, dir = 1,  range = 290, baseX = 3750, disabled = false, type = 'patrol'},
            {x = 4200, y = 400, radius = 25, speed = 265, dir = -1, range = 220, baseY = 400,  disabled = false, type = 'drone'}
        },
        powerups = {
            {x = 750,  y = 310, collected = false, type = 'invincibility'},
            {x = 1400, y = 360, collected = false, type = 'double_jump'},
            {x = 2200, y = 480, collected = false, type = 'shield'},
            {x = 2950, y = 280, collected = false, type = 'speed'},
            {x = 3600, y = 480, collected = false, type = 'invincibility'},
            {x = 4300, y = 350, collected = false, type = 'shield'}
        },
        goal = {x = 5000, y = 500, width = 50, height = 50}
    },
    -- Poziom 13: Boss 2 – Cyber-Tytan (2 fazy: faza 2 szybsza i więcej pocisków)
    {
        platforms = {
            {x = 0,    y = 550, width = 900,  height = 50},
            {x = 280,  y = 420, width = 140,  height = 18, moving = true, speed = 160, range = 200, baseX = 280},
            {x = 580,  y = 330, width = 140,  height = 18, moving = true, speed = 175, range = 170, baseY = 330, axis = 'y'},
            {x = 880,  y = 460, width = 140,  height = 18},
            {x = 1180, y = 360, width = 140,  height = 18, moving = true, speed = 150, range = 190, baseX = 1180},
            {x = 1480, y = 460, width = 140,  height = 18},
            {x = 1780, y = 550, width = 900,  height = 50},
            {x = 2100, y = 410, width = 140,  height = 18, rotating = true, speed = 3,   centerX = 2180, centerY = 380, radius = 110},
            {x = 2500, y = 310, width = 140,  height = 18, moving = true, speed = 185, range = 200, baseX = 2500},
            {x = 2850, y = 440, width = 140,  height = 18},
            {x = 3150, y = 340, width = 140,  height = 18, moving = true, speed = 195, range = 180, baseY = 340, axis = 'y'},
            {x = 3450, y = 550, width = 900,  height = 50},
            {x = 3800, y = 430, width = 140,  height = 18, rotating = true, speed = 3.5, centerX = 3880, centerY = 400, radius = 120},
            {x = 4200, y = 340, width = 140,  height = 18},
            {x = 4500, y = 550, width = 900,  height = 50},
            {x = 4900, y = 420, width = 140,  height = 18, moving = true, speed = 160, range = 160, baseX = 4900},
            {x = 5250, y = 550, width = 1200, height = 50} -- arena bossa
        },
        spikes = {
            {x = 380,  y = 400, width = 20, height = 20},
            {x = 680,  y = 310, width = 20, height = 20},
            {x = 980,  y = 440, width = 20, height = 20},
            {x = 1280, y = 340, width = 20, height = 20},
            {x = 1580, y = 440, width = 20, height = 20},
            {x = 1880, y = 530, width = 20, height = 20},
            {x = 2200, y = 390, width = 20, height = 20},
            {x = 2600, y = 290, width = 20, height = 20},
            {x = 2950, y = 420, width = 20, height = 20},
            {x = 3250, y = 320, width = 20, height = 20},
            {x = 3550, y = 530, width = 20, height = 20},
            {x = 3900, y = 410, width = 20, height = 20},
            {x = 4300, y = 320, width = 20, height = 20},
            {x = 4600, y = 530, width = 20, height = 20},
            {x = 5000, y = 400, width = 20, height = 20}
        },
        data = {
            {x = 330,  y = 370, collected = false},
            {x = 630,  y = 280, collected = false},
            {x = 930,  y = 410, collected = false},
            {x = 1230, y = 310, collected = false},
            {x = 1530, y = 410, collected = false},
            {x = 1830, y = 500, collected = false},
            {x = 2150, y = 360, collected = false},
            {x = 2550, y = 260, collected = false},
            {x = 2900, y = 390, collected = false},
            {x = 3200, y = 290, collected = false},
            {x = 3500, y = 500, collected = false},
            {x = 3850, y = 380, collected = false},
            {x = 4250, y = 290, collected = false},
            {x = 4650, y = 500, collected = false}
        },
        enemies = {
            {x = 450,  y = 500, radius = 22, speed = 200, dir = 1,  range = 280, baseX = 450,  disabled = false, type = 'patrol'},
            {x = 1050, y = 380, radius = 22, speed = 215, dir = -1, range = 200, baseY = 380,  disabled = false, type = 'drone'},
            {x = 1900, y = 500, radius = 22, speed = 230, dir = 1,  range = 300, baseX = 1900, disabled = false, type = 'patrol'},
            {x = 2700, y = 360, radius = 22, speed = 220, dir = -1, range = 190, baseY = 360,  disabled = false, type = 'drone'},
            {x = 3200, y = 500, radius = 22, speed = 245, dir = 1,  range = 270, baseX = 3200, disabled = false, type = 'patrol'},
            {x = 3900, y = 380, radius = 22, speed = 235, dir = -1, range = 210, baseY = 380,  disabled = false, type = 'drone'},
            {x = 4600, y = 500, radius = 22, speed = 260, dir = 1,  range = 290, baseX = 4600, disabled = false, type = 'patrol'},
            -- Boss 2 – Cyber-Tytan (2 fazy, faza 2 przyspiesza po utracie HP)
            {x = 5650, y = 490, radius = 60, speed = 90, dir = 1, range = 250, baseX = 5650,
                disabled = false, type = 'boss2', health = 5, maxHealth = 5,
                shootTimer = 1.5, shootInterval = 1.5, burstCount = 0, projectiles = {},
                phase = 1}
        },
        powerups = {
            {x = 700,  y = 290, collected = false, type = 'invincibility'},
            {x = 1300, y = 320, collected = false, type = 'shield'},
            {x = 2200, y = 470, collected = false, type = 'double_jump'},
            {x = 3000, y = 280, collected = false, type = 'speed'},
            {x = 3650, y = 470, collected = false, type = 'invincibility'},
            {x = 4400, y = 350, collected = false, type = 'shield'},
            {x = 5100, y = 390, collected = false, type = 'double_jump'}
        },
        goal = {x = 6500, y = 500, width = 50, height = 50}
    },
    -- Poziom 14: FINAŁ – Gauntlet (wszystkie mechaniki naraz, ekstremalnie trudny)
    {
        platforms = {
            {x = 0,    y = 550, width = 600,  height = 50},
            {x = 200,  y = 430, width = 110,  height = 15, moving = true, speed = 200, range = 170, baseX = 200},
            {x = 450,  y = 340, width = 110,  height = 15, rotating = true, speed = 5,   centerX = 510, centerY = 315, radius = 95},
            {x = 700,  y = 460, width = 110,  height = 15, moving = true, speed = 220, range = 140, baseY = 460, axis = 'y'},
            {x = 950,  y = 360, width = 110,  height = 15},
            {x = 1200, y = 470, width = 110,  height = 15, rotating = true, speed = 5.5, centerX = 1260, centerY = 445, radius = 100},
            {x = 1450, y = 550, width = 600,  height = 50},
            {x = 1750, y = 420, width = 110,  height = 15, moving = true, speed = 240, range = 200, baseX = 1750},
            {x = 2000, y = 320, width = 110,  height = 15, rotating = true, speed = 6,   centerX = 2060, centerY = 295, radius = 90},
            {x = 2250, y = 450, width = 110,  height = 15, moving = true, speed = 210, range = 160, baseY = 450, axis = 'y'},
            {x = 2500, y = 350, width = 110,  height = 15},
            {x = 2750, y = 550, width = 600,  height = 50},
            {x = 3050, y = 430, width = 110,  height = 15, rotating = true, speed = 6.5, centerX = 3110, centerY = 405, radius = 105},
            {x = 3300, y = 330, width = 110,  height = 15, moving = true, speed = 250, range = 190, baseX = 3300},
            {x = 3550, y = 460, width = 110,  height = 15, moving = true, speed = 230, range = 150, baseY = 460, axis = 'y'},
            {x = 3800, y = 360, width = 110,  height = 15},
            {x = 4050, y = 550, width = 600,  height = 50},
            {x = 4350, y = 420, width = 110,  height = 15, rotating = true, speed = 7,   centerX = 4410, centerY = 395, radius = 110},
            {x = 4600, y = 320, width = 110,  height = 15, moving = true, speed = 260, range = 200, baseX = 4600},
            {x = 4900, y = 550, width = 1500, height = 50} -- arena finałowego bossa
        },
        spikes = {
            {x = 300,  y = 410, width = 18, height = 18},
            {x = 550,  y = 320, width = 18, height = 18},
            {x = 800,  y = 440, width = 18, height = 18},
            {x = 1050, y = 340, width = 18, height = 18},
            {x = 1300, y = 450, width = 18, height = 18},
            {x = 1550, y = 530, width = 18, height = 18},
            {x = 1850, y = 400, width = 18, height = 18},
            {x = 2100, y = 300, width = 18, height = 18},
            {x = 2350, y = 430, width = 18, height = 18},
            {x = 2600, y = 330, width = 18, height = 18},
            {x = 2850, y = 530, width = 18, height = 18},
            {x = 3150, y = 410, width = 18, height = 18},
            {x = 3400, y = 310, width = 18, height = 18},
            {x = 3650, y = 440, width = 18, height = 18},
            {x = 3900, y = 340, width = 18, height = 18},
            {x = 4150, y = 530, width = 18, height = 18},
            {x = 4450, y = 400, width = 18, height = 18},
            {x = 4700, y = 300, width = 18, height = 18}
        },
        fallingSpikes = {
            {x = 400,  y = 0, width = 16, height = 16, speed = 220, baseY = 0, active = true},
            {x = 700,  y = 0, width = 16, height = 16, speed = 240, baseY = 0, active = true},
            {x = 1000, y = 0, width = 16, height = 16, speed = 210, baseY = 0, active = true},
            {x = 1300, y = 0, width = 16, height = 16, speed = 250, baseY = 0, active = true},
            {x = 1900, y = 0, width = 16, height = 16, speed = 235, baseY = 0, active = true},
            {x = 2200, y = 0, width = 16, height = 16, speed = 255, baseY = 0, active = true},
            {x = 2550, y = 0, width = 16, height = 16, speed = 225, baseY = 0, active = true},
            {x = 3100, y = 0, width = 16, height = 16, speed = 260, baseY = 0, active = true},
            {x = 3450, y = 0, width = 16, height = 16, speed = 245, baseY = 0, active = true},
            {x = 3800, y = 0, width = 16, height = 16, speed = 270, baseY = 0, active = true},
            {x = 4200, y = 0, width = 16, height = 16, speed = 280, baseY = 0, active = true},
            {x = 4600, y = 0, width = 16, height = 16, speed = 265, baseY = 0, active = true}
        },
        data = {
            {x = 250,  y = 380, collected = false},
            {x = 500,  y = 290, collected = false},
            {x = 750,  y = 410, collected = false},
            {x = 1000, y = 310, collected = false},
            {x = 1250, y = 420, collected = false},
            {x = 1500, y = 500, collected = false},
            {x = 1800, y = 370, collected = false},
            {x = 2050, y = 270, collected = false},
            {x = 2300, y = 400, collected = false},
            {x = 2550, y = 300, collected = false},
            {x = 2800, y = 500, collected = false},
            {x = 3100, y = 380, collected = false},
            {x = 3350, y = 280, collected = false},
            {x = 3600, y = 410, collected = false},
            {x = 3850, y = 310, collected = false},
            {x = 4100, y = 500, collected = false},
            {x = 4400, y = 370, collected = false},
            {x = 4650, y = 270, collected = false}
        },
        enemies = {
            {x = 350,  y = 500, radius = 22, speed = 240, dir = 1,  range = 250, baseX = 350,  disabled = false, type = 'patrol'},
            {x = 650,  y = 380, radius = 22, speed = 260, dir = -1, range = 200, baseY = 380,  disabled = false, type = 'drone'},
            {x = 950,  y = 420, radius = 22, speed = 250, dir = -1, range = 210, baseY = 420,  disabled = false, type = 'drone'},
            {x = 1600, y = 500, radius = 22, speed = 270, dir = 1,  range = 270, baseX = 1600, disabled = false, type = 'patrol'},
            {x = 1900, y = 360, radius = 22, speed = 255, dir = -1, range = 220, baseY = 360,  disabled = false, type = 'drone'},
            {x = 2150, y = 390, radius = 22, speed = 265, dir = -1, range = 200, baseY = 390,  disabled = false, type = 'drone'},
            {x = 2600, y = 500, radius = 22, speed = 280, dir = 1,  range = 280, baseX = 2600, disabled = false, type = 'patrol'},
            {x = 2900, y = 400, radius = 22, speed = 270, dir = -1, range = 230, baseY = 400,  disabled = false, type = 'drone'},
            {x = 3250, y = 500, radius = 22, speed = 290, dir = 1,  range = 260, baseX = 3250, disabled = false, type = 'patrol'},
            {x = 3550, y = 420, radius = 22, speed = 275, dir = -1, range = 200, baseY = 420,  disabled = false, type = 'drone'},
            {x = 3900, y = 500, radius = 22, speed = 300, dir = 1,  range = 270, baseX = 3900, disabled = false, type = 'patrol'},
            {x = 4200, y = 380, radius = 22, speed = 285, dir = -1, range = 210, baseY = 380,  disabled = false, type = 'drone'},
            -- Finałowy boss – Archon (3 fazy)
            {x = 5400, y = 480, radius = 70, speed = 80, dir = 1, range = 280, baseX = 5400,
                disabled = false, type = 'archon', health = 8, maxHealth = 8,
                shootTimer = 1.0, shootInterval = 1.0, burstCount = 0, projectiles = {},
                phase = 1}
        },
        powerups = {
            {x = 600,  y = 290, collected = false, type = 'invincibility'},
            {x = 1100, y = 330, collected = false, type = 'shield'},
            {x = 1700, y = 470, collected = false, type = 'double_jump'},
            {x = 2350, y = 300, collected = false, type = 'speed'},
            {x = 2950, y = 480, collected = false, type = 'invincibility'},
            {x = 3500, y = 430, collected = false, type = 'shield'},
            {x = 4050, y = 480, collected = false, type = 'double_jump'},
            {x = 4750, y = 380, collected = false, type = 'speed'}
        },
        goal = {x = 6800, y = 500, width = 50, height = 50}
    }
}

-- ============================================================
-- Pomocnicze tabele globalnych hazardów (opadające kolce)
-- ============================================================
fallingSpikes = {}

-- ============================================================
-- loadLevel: inicjalizacja poziomu
-- ============================================================
function loadLevel(level)
if not levels[level] then level = 1 end
    local lvl = levels[level]

    platforms     = {}
    spikes        = {}
    data          = {}
    enemies       = {}
    powerups      = {}
    fallingSpikes = {}

    -- Głęboka kopia tabel poziomu, żeby reset danych działał poprawnie
    for _, p in ipairs(lvl.platforms or {}) do
        local copy = {}
        for k, v in pairs(p) do copy[k] = v end
            table.insert(platforms, copy)
            end
            for _, s in ipairs(lvl.spikes or {}) do
                local copy = {}
                for k, v in pairs(s) do copy[k] = v end
                    table.insert(spikes, copy)
                    end
                    for _, d in ipairs(lvl.data or {}) do
                        local copy = {}
                        for k, v in pairs(d) do copy[k] = v end
                            copy.collected = false
                            table.insert(data, copy)
                            end
                            for _, e in ipairs(lvl.enemies or {}) do
                                local copy = {}
                                for k, v in pairs(e) do copy[k] = v end
                                    copy.disabled = false
                                    copy.disabledTimer = 0
                                    if copy.type == 'boss' or copy.type == 'boss2' or copy.type == 'archon' then
                                        copy.projectiles = {}
                                        copy.health = copy.maxHealth
                                        end
                                        table.insert(enemies, copy)
                                        end
                                        for _, p in ipairs(lvl.powerups or {}) do
                                            local copy = {}
                                            for k, v in pairs(p) do copy[k] = v end
                                                copy.collected = false
                                                table.insert(powerups, copy)
                                                end
                                                for _, fs in ipairs(lvl.fallingSpikes or {}) do
                                                    local copy = {}
                                                    for k, v in pairs(fs) do copy[k] = v end
                                                        copy.y = math.random(-600, -20) -- zacznij losowo powyżej ekranu
                                                        copy.active = true
                                                        table.insert(fallingSpikes, copy)
                                                        end

                                                        goal = {}
                                                        for k, v in pairs(lvl.goal or {x=1000, y=500, width=50, height=50}) do
                                                            goal[k] = v
                                                            end

                                                            resetPlayer()
                                                            camera.x     = 0
                                                            multiplier   = 1
                                                            comboTimer   = 0
                                                            timeElapsed  = 0
                                                            hitThisLevel = true -- reset no-hit tracker; set false on first damage

                                                            if gameMode == 'time_attack' then
                                                                timeLimit = 60 + (level * 15)
                                                                end
                                                                end

                                                                -- ============================================================
                                                                -- updateLevel: ruch platform, wrogów, bossów, opadających kolców
                                                                -- ============================================================
                                                                function updateLevel(dt)
                                                                -- Platformy: ruchome i rotujące (NAPRAWIONY BUG – oddzielne bloki if)
                                                                for _, platform in ipairs(platforms) do
                                                                    if platform.moving then
                                                                        local dir = platform.dir or 1
                                                                        if platform.axis == 'y' then
                                                                            platform.y = platform.y + platform.speed * dt * dir
                                                                            if math.abs(platform.y - platform.baseY) > platform.range / 2 then
                                                                                platform.speed = -platform.speed
                                                                                end
                                                                                else
                                                                                    platform.x = platform.x + platform.speed * dt * dir
                                                                                    if math.abs(platform.x - platform.baseX) > platform.range / 2 then
                                                                                        platform.speed = -platform.speed
                                                                                        end
                                                                                        end
                                                                                        end
                                                                                        if platform.rotating then
                                                                                            local angle = love.timer.getTime() * platform.speed
                                                                                            platform.x = platform.centerX + math.cos(angle) * platform.radius
                                                                                            platform.y = platform.centerY + math.sin(angle) * platform.radius
                                                                                            end
                                                                                            end

                                                                                            -- Opadające kolce
                                                                                            local screenH = love.graphics.getHeight()
                                                                                            for _, fs in ipairs(fallingSpikes) do
                                                                                                if fs.active then
                                                                                                    fs.y = fs.y + fs.speed * dt
                                                                                                    if fs.y > screenH + 40 then
                                                                                                        fs.y = math.random(-800, -30) -- teleport na górę
                                                                                                        end
                                                                                                        -- Kolizja z graczem
                                                                                                        if not player.invincible and checkCollision(player, fs) then
                                                                                                            damagePlayer()
                                                                                                            end
                                                                                                            end
                                                                                                            end

                                                                                                            -- Wrogowie
                                                                                                            for _, enemy in ipairs(enemies) do
                                                                                                                -- Timer wyłączenia przez hack
                                                                                                                if enemy.disabled then
                                                                                                                    if enemy.disabledTimer and enemy.disabledTimer > 0 then
                                                                                                                        enemy.disabledTimer = enemy.disabledTimer - dt
                                                                                                                        if enemy.disabledTimer <= 0 then
                                                                                                                            enemy.disabled = false
                                                                                                                            end
                                                                                                                            end
                                                                                                                            else
                                                                                                                                if enemy.type == 'drone' then
                                                                                                                                    enemy.y = enemy.y + enemy.speed * enemy.dir * dt
                                                                                                                                    if math.abs(enemy.y - enemy.baseY) > enemy.range / 2 then
                                                                                                                                        enemy.dir = -enemy.dir
                                                                                                                                        end

                                                                                                                                        elseif enemy.type == 'patrol' then
                                                                                                                                            enemy.x = enemy.x + enemy.speed * enemy.dir * dt
                                                                                                                                            if math.abs(enemy.x - enemy.baseX) > enemy.range / 2 then
                                                                                                                                                enemy.dir = -enemy.dir
                                                                                                                                                end

                                                                                                                                                elseif enemy.type == 'boss' then
                                                                                                                                                    updateBoss(enemy, dt, 1)

                                                                                                                                                    elseif enemy.type == 'boss2' then
                                                                                                                                                        updateBoss(enemy, dt, 2)

                                                                                                                                                        elseif enemy.type == 'archon' then
                                                                                                                                                            updateBoss(enemy, dt, 3)
                                                                                                                                                            end
                                                                                                                                                            end
                                                                                                                                                            end
                                                                                                                                                            end

                                                                                                                                                            -- ============================================================
                                                                                                                                                            -- updateBoss: wspólna logika dla wszystkich bossów
                                                                                                                                                            -- tier=1 → 1 pocisk/salwę; tier=2 → 2 pociski + faza 2; tier=3 → 3 pociski + fazy
                                                                                                                                                            -- ============================================================
                                                                                                                                                            function updateBoss(enemy, dt, tier)
                                                                                                                                                            -- Ruch poziomy
                                                                                                                                                            enemy.x = enemy.x + enemy.speed * enemy.dir * dt
                                                                                                                                                            if math.abs(enemy.x - enemy.baseX) > enemy.range / 2 then
                                                                                                                                                                enemy.dir = -enemy.dir
                                                                                                                                                                end

                                                                                                                                                                -- Faza 2/3 – przyspieszenie przy połowie HP
                                                                                                                                                                if tier >= 2 then
                                                                                                                                                                    local hpRatio = enemy.health / enemy.maxHealth
                                                                                                                                                                    if hpRatio <= 0.5 and enemy.phase == 1 then
                                                                                                                                                                        enemy.phase = 2
                                                                                                                                                                        enemy.speed = enemy.speed * 1.4
                                                                                                                                                                        enemy.shootInterval = enemy.shootInterval * 0.65
                                                                                                                                                                        end
                                                                                                                                                                        if tier == 3 and hpRatio <= 0.25 and enemy.phase == 2 then
                                                                                                                                                                            enemy.phase = 3
                                                                                                                                                                            enemy.speed = enemy.speed * 1.3
                                                                                                                                                                            enemy.shootInterval = enemy.shootInterval * 0.7
                                                                                                                                                                            end
                                                                                                                                                                            end

                                                                                                                                                                            -- Timer strzału
                                                                                                                                                                            enemy.shootTimer = enemy.shootTimer - dt
                                                                                                                                                                            if enemy.shootTimer <= 0 then
                                                                                                                                                                                enemy.shootTimer = enemy.shootInterval

                                                                                                                                                                                -- Liczba pocisków zależna od fazy
                                                                                                                                                                                local shots = 1
                                                                                                                                                                                if tier == 2 then shots = (enemy.phase == 2) and 3 or 2 end
                                                                                                                                                                                    if tier == 3 then shots = (enemy.phase == 3) and 5 or (enemy.phase == 2 and 3 or 2) end

                                                                                                                                                                                        local spread = 0.25
                                                                                                                                                                                        for i = 1, shots do
                                                                                                                                                                                            local angle = math.atan2(player.y - enemy.y, player.x - enemy.x)
                                                                                                                                                                                            + (i - (shots + 1) / 2) * spread
                                                                                                                                                                                            local speed = 260 + tier * 40
                                                                                                                                                                                            table.insert(enemy.projectiles, {
                                                                                                                                                                                                x = enemy.x, y = enemy.y,
                                                                                                                                                                                                vx = math.cos(angle) * speed,
                                                                                                                                                                                                         vy = math.sin(angle) * speed,
                                                                                                                                                                                                         radius = 8,
                                                                                                                                                                                                         life = 4.0
                                                                                                                                                                                            })
                                                                                                                                                                                            end
                                                                                                                                                                                            createParticles(enemy.x, enemy.y, 12, {1, 0.2, 0.2})
                                                                                                                                                                                            end

                                                                                                                                                                                            -- Aktualizacja pocisków
                                                                                                                                                                                            for i = #enemy.projectiles, 1, -1 do
                                                                                                                                                                                                local proj = enemy.projectiles[i]
                                                                                                                                                                                                proj.x = proj.x + proj.vx * dt
                                                                                                                                                                                                proj.y = proj.y + proj.vy * dt
                                                                                                                                                                                                proj.life = proj.life - dt
                                                                                                                                                                                                if proj.life <= 0 then
                                                                                                                                                                                                    table.remove(enemy.projectiles, i)
                                                                                                                                                                                                    end
                                                                                                                                                                                                    end
                                                                                                                                                                                                    end

                                                                                                                                                                                                    -- ============================================================
                                                                                                                                                                                                    -- bossDamage: trafienie bossa przez gracza (np. lądowanie na boss)
                                                                                                                                                                                                    -- ============================================================
                                                                                                                                                                                                    function tryDamageBoss(boss)
                                                                                                                                                                                                    -- Gracz może trafić bossa skacząc NA niego z góry
                                                                                                                                                                                                    if player.velocityY > 0 and
                                                                                                                                                                                                        player.y + player.height <= boss.y + 10 and
                                                                                                                                                                                                        checkCircleCollision(player, boss) then
                                                                                                                                                                                                        boss.health = boss.health - 1
                                                                                                                                                                                                        player.velocityY = player.jumpPower * 0.6
                                                                                                                                                                                                        createParticles(boss.x, boss.y, 20, {1, 0.5, 0})
                                                                                                                                                                                                        triggerScreenShake(10, 0.3)
                                                                                                                                                                                                        if boss.health <= 0 then
                                                                                                                                                                                                            boss.disabled = true
                                                                                                                                                                                                            score = score + 500 * multiplier
                                                                                                                                                                                                            createParticles(boss.x, boss.y, 60, {1, 1, 0})
                                                                                                                                                                                                            unlockAchievement("boss_slayer")
                                                                                                                                                                                                            end
                                                                                                                                                                                                            return true
                                                                                                                                                                                                            end
                                                                                                                                                                                                            return false
                                                                                                                                                                                                            end

                                                                                                                                                                                                            -- ============================================================
                                                                                                                                                                                                            -- drawLevel: rysowanie wszystkich elementów poziomu
                                                                                                                                                                                                            -- ============================================================
                                                                                                                                                                                                            function drawLevel()
                                                                                                                                                                                                            local theme = getCurrentTheme()
                                                                                                                                                                                                            local W = love.graphics.getWidth()
                                                                                                                                                                                                            local H = love.graphics.getHeight()

                                                                                                                                                                                                            -- Tło z parallax w stylu Geometry Dash
                                                                                                                                                                                                            love.graphics.setBackgroundColor(theme.bg[1], theme.bg[2], theme.bg[3])

                                                                                                                                                                                                            love.graphics.setColor(theme.grid1[1], theme.grid1[2], theme.grid1[3], 0.55)
                                                                                                                                                                                                            for x = (-camera.x * 0.3) % 100, W + 100, 100 do
                                                                                                                                                                                                                love.graphics.line(x, 0, x, H)
                                                                                                                                                                                                                end
                                                                                                                                                                                                                for y = 0, H, 100 do
                                                                                                                                                                                                                    love.graphics.line(0, y, W, y)
                                                                                                                                                                                                                    end

                                                                                                                                                                                                                    love.graphics.setColor(theme.grid2[1], theme.grid2[2], theme.grid2[3], 0.35)
                                                                                                                                                                                                                    for x = (-camera.x * 0.6) % 50, W + 50, 50 do
                                                                                                                                                                                                                        love.graphics.line(x, 0, x, H)
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        for y = 0, H, 50 do
                                                                                                                                                                                                                            love.graphics.line(0, y, W, y)
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            -- Platformy
                                                                                                                                                                                                                            love.graphics.setColor(0, 1, 0)
                                                                                                                                                                                                                            for _, platform in ipairs(platforms) do
                                                                                                                                                                                                                                if platform.rotating then
                                                                                                                                                                                                                                    love.graphics.setColor(0.4, 1, 0.4)
                                                                                                                                                                                                                                    elseif platform.moving then
                                                                                                                                                                                                                                        love.graphics.setColor(0.2, 0.9, 0.2)
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            love.graphics.setColor(0, 1, 0)
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
                                                                                                                                                                                                                                            -- Krawędź
                                                                                                                                                                                                                                            love.graphics.setColor(0, 0.5, 0, 0.8)
                                                                                                                                                                                                                                            love.graphics.rectangle("line", platform.x, platform.y, platform.width, platform.height)
                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                            -- Kolce statyczne
                                                                                                                                                                                                                                            love.graphics.setColor(1, 0.2, 0.2)
                                                                                                                                                                                                                                            for _, spike in ipairs(spikes) do
                                                                                                                                                                                                                                                love.graphics.polygon("fill",
                                                                                                                                                                                                                                                                spike.x, spike.y + spike.height,
                                                                                                                                                                                                                                                                spike.x + spike.width / 2, spike.y,
                                                                                                                                                                                                                                                                spike.x + spike.width, spike.y + spike.height)
                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                -- Opadające kolce
                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.5, 0)
                                                                                                                                                                                                                                                for _, fs in ipairs(fallingSpikes) do
                                                                                                                                                                                                                                                    if fs.active then
                                                                                                                                                                                                                                                        love.graphics.polygon("fill",
                                                                                                                                                                                                                                                                fs.x, fs.y,
                                                                                                                                                                                                                                                                fs.x + fs.width / 2, fs.y + fs.height,
                                                                                                                                                                                                                                                                fs.x + fs.width, fs.y)
                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                                        -- Dane (zbierane)
                                                                                                                                                                                                                                                        for _, d in ipairs(data) do
                                                                                                                                                                                                                                                            if not d.collected then
                                                                                                                                                                                                                                                                local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 3)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 0, pulse)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", d.x + 10, d.y + 10, 10)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1, 0.6)
                                                                                                                                                                                                                                                                love.graphics.circle("line", d.x + 10, d.y + 10, 13)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Power-upy
                                                                                                                                                                                                                                                                for _, p in ipairs(powerups) do
                                                                                                                                                                                                                                                                if not p.collected then
                                                                                                                                                                                                                                                                local t = love.timer.getTime() * 4
                                                                                                                                                                                                                                                                local bob = math.sin(t) * 4
                                                                                                                                                                                                                                                                if p.type == 'invincibility' then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.3, 0.5, 1)
                                                                                                                                                                                                                                                                elseif p.type == 'speed' then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.2, 1)
                                                                                                                                                                                                                                                                elseif p.type == 'double_jump' then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.2, 1, 0.6)
                                                                                                                                                                                                                                                                elseif p.type == 'shield' then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.9, 0.9, 0.9)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", p.x, p.y + bob, 20, 20)
                                                                                                                                                                                                                                                                -- Ikona tekstowa
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0)
                                                                                                                                                                                                                                                                local label = ({invincibility="I", speed="S", double_jump="J", shield="H"})[p.type] or "?"
                                                                                                                                                                                                                                                                love.graphics.print(label, p.x + 4, p.y + 3 + bob)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Wrogowie
                                                                                                                                                                                                                                                                for _, enemy in ipairs(enemies) do
                                                                                                                                                                                                                                                                if enemy.disabled then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.35, 0.35, 0.35)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
                                                                                                                                                                                                                                                                elseif enemy.type == 'drone' then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.55, 0.1)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
                                                                                                                                                                                                                                                                -- Krzyżyk/oczy
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0)
                                                                                                                                                                                                                                                                love.graphics.line(enemy.x - 8, enemy.y - 4, enemy.x + 8, enemy.y - 4)
                                                                                                                                                                                                                                                                elseif enemy.type == 'boss' or enemy.type == 'boss2' or enemy.type == 'archon' then
                                                                                                                                                                                                                                                                -- Kolor zależny od HP
                                                                                                                                                                                                                                                                local hpRatio = enemy.health / enemy.maxHealth
                                                                                                                                                                                                                                                                local r = 1
                                                                                                                                                                                                                                                                local g = hpRatio * 0.4
                                                                                                                                                                                                                                                                local b = (enemy.type == 'archon') and 0.8 or (enemy.type == 'boss2' and 0.5 or 0.2)
                                                                                                                                                                                                                                                                love.graphics.setColor(r, g, b)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
                                                                                                                                                                                                                                                                -- Pasek HP nad bossem
                                                                                                                                                                                                                                                                local barW = enemy.radius * 2 + 20
                                                                                                                                                                                                                                                                local barX = enemy.x - barW / 2
                                                                                                                                                                                                                                                                local barY = enemy.y - enemy.radius - 20
                                                                                                                                                                                                                                                                love.graphics.setColor(0.2, 0.2, 0.2)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", barX, barY, barW, 8)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.2, 0.2)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", barX, barY, barW * hpRatio, 8)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.rectangle("line", barX, barY, barW, 8)
                                                                                                                                                                                                                                                                -- Nazwa
                                                                                                                                                                                                                                                                local bname = (enemy.type == 'archon') and "ARCHON"
                                                                                                                                                                                                                                                                or (enemy.type == 'boss2') and "CYBER-TYTAN" or "BOSS"
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print(bname, enemy.x - 30, barY - 14)

                                                                                                                                                                                                                                                                -- Pociski bossa
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 0.3)
                                                                                                                                                                                                                                                                for _, proj in ipairs(enemy.projectiles) do
                                                                                                                                                                                                                                                                love.graphics.circle("fill", proj.x, proj.y, proj.radius)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.8, 0.8, 0.4)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", proj.x, proj.y, proj.radius + 4)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 0.3)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.1, 0.1)
                                                                                                                                                                                                                                                                love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Cel (Goal)
                                                                                                                                                                                                                                                                local pulse = 0.7 + 0.3 * math.sin(love.timer.getTime() * 3)
                                                                                                                                                                                                                                                                love.graphics.setColor(0, pulse, 0)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", goal.x, goal.y, goal.width, goal.height)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1, 0.8)
                                                                                                                                                                                                                                                                love.graphics.rectangle("line", goal.x, goal.y, goal.width, goal.height)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print("CEL", goal.x + 4, goal.y + 16)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                                                                -- updateGame / drawGame
                                                                                                                                                                                                                                                                -- ============================================================
                                                                                                                                                                                                                                                                function updateGame(dt)
                                                                                                                                                                                                                                                                if gameOver or gameWon then return end

                                                                                                                                                                                                                                                                timeElapsed = timeElapsed + dt

                                                                                                                                                                                                                                                                if gameMode == 'time_attack' and timeElapsed > timeLimit then
                                                                                                                                                                                                                                                                gameOver = true
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                updatePlayer(dt)
                                                                                                                                                                                                                                                                updateLevel(dt)
                                                                                                                                                                                                                                                                updateScreenShake(dt)
                                                                                                                                                                                                                                                                updateAchievementNotifications(dt)

                                                                                                                                                                                                                                                                -- Próba uszkodzenia bossów przez skakanie na nich
                                                                                                                                                                                                                                                                for _, enemy in ipairs(enemies) do
                                                                                                                                                                                                                                                                if (enemy.type == 'boss' or enemy.type == 'boss2' or enemy.type == 'archon')
                                                                                                                                                                                                                                                                and not enemy.disabled then
                                                                                                                                                                                                                                                                tryDamageBoss(enemy)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Płynna kamera z wyprzedzeniem jak w GD
                                                                                                                                                                                                                                                                local targetX = player.x - love.graphics.getWidth() / 2 + 100
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

                                                                                                                                                                                                                                                                if player.y > love.graphics.getHeight() + 100 then
                                                                                                                                                                                                                                                                damagePlayer()
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function drawGame()
                                                                                                                                                                                                                                                                local H = love.graphics.getHeight()
                                                                                                                                                                                                                                                                local W = love.graphics.getWidth()

                                                                                                                                                                                                                                                                local shakeX, shakeY = getScreenShakeOffset()
                                                                                                                                                                                                                                                                love.graphics.translate(-camera.x + shakeX, shakeY)
                                                                                                                                                                                                                                                                drawLevel()
                                                                                                                                                                                                                                                                drawPlayer()
                                                                                                                                                                                                                                                                love.graphics.translate(camera.x - shakeX, -shakeY)

                                                                                                                                                                                                                                                                -- HUD
                                                                                                                                                                                                                                                                local theme = getCurrentTheme()
                                                                                                                                                                                                                                                                love.graphics.setColor(theme.text)
                                                                                                                                                                                                                                                                love.graphics.print("Score: "      .. math.floor(score),     10, 10)
                                                                                                                                                                                                                                                                love.graphics.print("High Score: " .. math.floor(highScore), 10, 28)
                                                                                                                                                                                                                                                                love.graphics.print("Level: "      .. currentLevel .. "/" .. #levels, 10, 46)
                                                                                                                                                                                                                                                                love.graphics.print("Lives: "      .. (lives == math.huge and "∞" or lives), 10, 64)
                                                                                                                                                                                                                                                                love.graphics.print("Multiplier: x".. multiplier,            10, 82)

                                                                                                                                                                                                                                                                -- Aktywne power-upy
                                                                                                                                                                                                                                                                local yOff = 100
                                                                                                                                                                                                                                                                if player.invincible then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.5, 0.7, 1)
                                                                                                                                                                                                                                                                love.graphics.print("Nietykalny: " .. string.format("%.1f", player.invincibleTimer) .. "s", 10, yOff)
                                                                                                                                                                                                                                                                yOff = yOff + 18
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.hackTimer > 0 then
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print("Hack CD: " .. math.ceil(player.hackTimer) .. "s", 10, yOff)
                                                                                                                                                                                                                                                                yOff = yOff + 18
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.speedBoostTimer > 0 then
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.3, 1)
                                                                                                                                                                                                                                                                love.graphics.print("Speed: " .. string.format("%.1f", player.speedBoostTimer) .. "s", 10, yOff)
                                                                                                                                                                                                                                                                yOff = yOff + 18
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.doubleJumpAvailable then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.2, 1, 0.6)
                                                                                                                                                                                                                                                                love.graphics.print("Double Jump: aktywny", 10, yOff)
                                                                                                                                                                                                                                                                yOff = yOff + 18
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if player.shield then
                                                                                                                                                                                                                                                                love.graphics.setColor(0.9, 0.9, 0.9)
                                                                                                                                                                                                                                                                love.graphics.print("Tarcza: aktywna", 10, yOff)
                                                                                                                                                                                                                                                                yOff = yOff + 18
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if gameMode == 'time_attack' then
                                                                                                                                                                                                                                                                local tLeft = math.ceil(timeLimit - timeElapsed)
                                                                                                                                                                                                                                                                love.graphics.setColor(tLeft < 10 and {1, 0.2, 0.2} or theme.text)
                                                                                                                                                                                                                                                                love.graphics.print("Czas: " .. tLeft .. "s", 10, yOff)
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                -- Pasek postępu
                                                                                                                                                                                                                                                                love.graphics.setColor(0.15, 0.15, 0.15, 0.7)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 10, H - 30, 200, 18)
                                                                                                                                                                                                                                                                local progress = math.min(math.max(player.x / (goal.x + goal.width), 0), 1)
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0.85, 0.4)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 10, H - 30, 200 * progress, 18)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 0, 0.5 + 0.5 * math.sin(love.timer.getTime() * 5))
                                                                                                                                                                                                                                                                love.graphics.rectangle("line", 10, H - 30, 200, 18)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print(math.floor(progress * 100) .. "%", 215, H - 30)

                                                                                                                                                                                                                                                                -- Powiadomienia osiągnięć
                                                                                                                                                                                                                                                                drawAchievementNotifications()

                                                                                                                                                                                                                                                                -- Game Over / Win
                                                                                                                                                                                                                                                                if gameOver then
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.6)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, W, H)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 0.2, 0.2)
                                                                                                                                                                                                                                                                love.graphics.print("GAME OVER", W/2 - 80, H/2 - 40, 0, 2, 2)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print("R - restart    Esc - menu", W/2 - 100, H/2 + 20)
                                                                                                                                                                                                                                                                elseif gameWon then
                                                                                                                                                                                                                                                                love.graphics.setColor(0, 0, 0, 0.6)
                                                                                                                                                                                                                                                                love.graphics.rectangle("fill", 0, 0, W, H)
                                                                                                                                                                                                                                                                love.graphics.setColor(0.2, 1, 0.4)
                                                                                                                                                                                                                                                                love.graphics.print("WYGRAŁEŚ!", W/2 - 80, H/2 - 50, 0, 2, 2)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 0)
                                                                                                                                                                                                                                                                love.graphics.print("High Score: " .. math.floor(highScore), W/2 - 80, H/2 + 10, 0, 1.2, 1.2)
                                                                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                                                                love.graphics.print("R - restart    Esc - menu", W/2 - 100, H/2 + 45)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end
