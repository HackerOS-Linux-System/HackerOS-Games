camera = {x = 0}
levels = {
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
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 300, y = 400, width = 200, height = 20, moving = true, speed = 130, range = 200, baseX = 300},
            {x = 600, y = 300, width = 150, height = 20, moving = true, speed = 150, range = 150, baseY = 300, axis = 'y'},
            {x = 900, y = 450, width = 200, height = 20},
            {x = 1200, y = 350, width = 150, height = 20, moving = true, speed = 120, range = 200, baseX = 1200},
            {x = 1500, y = 450, width = 200, height = 20},
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 400, width = 200, height = 20, moving = true, speed = 160, range = 100, baseY = 400, axis = 'y'},
            {x = 2700, y = 300, width = 150, height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 400, width = 200, height = 20, moving = true, speed = 140, range = 150, baseX = 3500},
            {x = 3900, y = 300, width = 150, height = 20},
            {x = 4300, y = 550, width = 1000, height = 50},
            {x = 4700, y = 400, width = 200, height = 20},
            {x = 5100, y = 550, width = 1000, height = 50} -- Platforma dla bossa
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
            {x = 4400, y = 280, width = 20, height = 20},
            {x = 4800, y = 530, width = 20, height = 20}
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
            {x = 4150, y = 250, collected = false},
            {x = 4550, y = 500, collected = false}
        },
        enemies = {
            {x = 500, y = 500, radius = 20, speed = 160, dir = 1, range = 250, baseX = 500, disabled = false, type = 'patrol'},
            {x = 1100, y = 400, radius = 20, speed = 180, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 2000, y = 500, radius = 20, speed = 200, dir = 1, range = 300, baseX = 2000, disabled = false, type = 'patrol'},
            {x = 2600, y = 400, radius = 20, speed = 170, dir = -1, range = 150, baseY = 400, disabled = false, type = 'drone'},
            {x = 3200, y = 500, radius = 20, speed = 190, dir = 1, range = 250, baseX = 3200, disabled = false, type = 'patrol'},
            {x = 3600, y = 400, radius = 20, speed = 160, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 4000, y = 500, radius = 20, speed = 180, dir = 1, range = 300, baseX = 4000, disabled = false, type = 'patrol'},
            -- Boss
            {x = 5100, y = 400, radius = 50, speed = 100, dir = 1, range = 200, baseX = 5100, disabled = false, type = 'boss', health = 3, shootTimer = 2}
        },
        powerups = {
            {x = 800, y = 400, collected = false, type = 'invincibility'},
            {x = 1400, y = 300, collected = false, type = 'double_jump'},
            {x = 2200, y = 350, collected = false, type = 'shield'},
            {x = 2800, y = 250, collected = false, type = 'speed'},
            {x = 3400, y = 350, collected = false, type = 'double_jump'},
            {x = 3800, y = 250, collected = false, type = 'shield'},
            {x = 4200, y = 350, collected = false, type = 'invincibility'},
            {x = 4600, y = 250, collected = false, type = 'speed'}
        },
        goal = {x = 5500, y = 500, width = 50, height = 50}
    },
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 400, y = 450, width = 150, height = 20, moving = true, speed = 150, range = 250, baseX = 400},
            {x = 700, y = 350, width = 200, height = 20, moving = true, speed = 140, range = 200, baseY = 350, axis = 'y'},
            {x = 1100, y = 500, width = 150, height = 20},
            {x = 1400, y = 400, width = 200, height = 20, rotating = true, speed = 2, centerX = 1500, centerY = 400, radius = 100}, -- Nowy typ: rotująca platforma
            {x = 1800, y = 550, width = 1000, height = 50},
            {x = 2300, y = 300, width = 150, height = 20, moving = true, speed = 160, range = 150, baseX = 2300},
            {x = 2700, y = 200, width = 200, height = 20},
            {x = 3100, y = 550, width = 1000, height = 50},
            {x = 3500, y = 450, width = 150, height = 20},
            {x = 3900, y = 350, width = 200, height = 20, moving = true, speed = 170, range = 200, baseY = 350, axis = 'y'}
        },
        spikes = {
            {x = 500, y = 430, width = 20, height = 20},
            {x = 800, y = 330, width = 20, height = 20},
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
            {x = 450, y = 400, collected = false},
            {x = 750, y = 300, collected = false},
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
            {x = 600, y = 500, radius = 25, speed = 170, dir = 1, range = 300, baseX = 600, disabled = false, type = 'patrol'},
            {x = 1300, y = 450, radius = 25, speed = 180, dir = -1, range = 250, baseY = 450, disabled = false, type = 'drone'},
            {x = 2100, y = 500, radius = 25, speed = 190, dir = 1, range = 350, baseX = 2100, disabled = false, type = 'patrol'},
            {x = 2800, y = 400, radius = 25, speed = 170, dir = -1, range = 200, baseY = 400, disabled = false, type = 'drone'},
            {x = 3400, y = 500, radius = 25, speed = 200, dir = 1, range = 300, baseX = 3400, disabled = false, type = 'patrol'}
        },
        powerups = {
            {x = 900, y = 450, collected = false, type = 'invincibility'},
            {x = 1600, y = 350, collected = false, type = 'double_jump'},
            {x = 2500, y = 300, collected = false, type = 'shield'},
            {x = 3000, y = 200, collected = false, type = 'speed'},
            {x = 3700, y = 400, collected = false, type = 'double_jump'}
        },
        goal = {x = 4500, y = 500, width = 50, height = 50}
    },
    {
        platforms = {
            {x = 0, y = 550, width = 1000, height = 50},
            {x = 500, y = 450, width = 200, height = 20, rotating = true, speed = 3, centerX = 600, centerY = 450, radius = 150},
            {x = 900, y = 350, width = 150, height = 20, moving = true, speed = 180, range = 250, baseY = 350, axis = 'y'},
            {x = 1300, y = 500, width = 200, height = 20},
            {x = 1700, y = 400, width = 150, height = 20, moving = true, speed = 160, range = 200, baseX = 1700},
            {x = 2100, y = 550, width = 1000, height = 50},
            {x = 2600, y = 300, width = 200, height = 20},
            {x = 3000, y = 200, width = 150, height = 20, rotating = true, speed = 2.5, centerX = 3100, centerY = 200, radius = 120},
            {x = 3400, y = 550, width = 1000, height = 50},
            {x = 3900, y = 450, width = 200, height = 20},
            {x = 4300, y = 350, width = 150, height = 20, moving = true, speed = 190, range = 300, baseX = 4300}
        },
        spikes = {
            {x = 600, y = 430, width = 20, height = 20},
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
            {x = 550, y = 400, collected = false},
            {x = 950, y = 300, collected = false},
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
            {x = 700, y = 500, radius = 30, speed = 180, dir = 1, range = 350, baseX = 700, disabled = false, type = 'patrol'},
            {x = 1500, y = 450, radius = 30, speed = 190, dir = -1, range = 300, baseY = 450, disabled = false, type = 'drone'},
            {x = 2300, y = 500, radius = 30, speed = 200, dir = 1, range = 400, baseX = 2300, disabled = false, type = 'patrol'},
            {x = 3200, y = 400, radius = 30, speed = 180, dir = -1, range = 250, baseY = 400, disabled = false, type = 'drone'},
            {x = 3800, y = 500, radius = 30, speed = 210, dir = 1, range = 350, baseX = 3800, disabled = false, type = 'patrol'}
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
    }
}
function loadLevel(level)
if not levels[level] then
    level = 1
    end
    platforms = levels[level].platforms or {}
    spikes = levels[level].spikes or {}
    data = levels[level].data or {}
    enemies = levels[level].enemies or {}
    powerups = levels[level].powerups or {}
    goal = levels[level].goal or {x = 1000, y = 500, width = 50, height = 50}
    resetPlayer()
    camera.x = 0
    multiplier = 1
    comboTimer = 0
    timeElapsed = 0
    if gameMode == 'time_attack' then
        timeLimit = 60 + (level * 15)
        end
        end
        function updateLevel(dt)
        for _, platform in ipairs(platforms) do
            if platform.moving then
                if platform.axis == 'y' then
                    platform.y = platform.y + platform.speed * dt * (platform.dir or 1)
                    if math.abs(platform.y - platform.baseY) > platform.range / 2 then
                        platform.speed = -platform.speed
                        end
                        else
                            platform.x = platform.x + platform.speed * dt * (platform.dir or 1)
                            if math.abs(platform.x - platform.baseX) > platform.range / 2 then
                                platform.speed = -platform.speed
                                end
                                end
                                elseif platform.rotating then
                                    -- Rotacja platformy
                                    local angle = love.timer.getTime() * platform.speed
                                    platform.x = platform.centerX + math.cos(angle) * platform.radius
                                    platform.y = platform.centerY + math.sin(angle) * platform.radius
                                    end
                                    end
                                    for _, enemy in ipairs(enemies) do
                                        if not enemy.disabled then
                                            if enemy.type == 'drone' then
                                                enemy.y = enemy.y + enemy.speed * enemy.dir * dt
                                                if math.abs(enemy.y - enemy.baseY) > enemy.range / 2 then
                                                    enemy.dir = -enemy.dir
                                                    end
                                                    elseif enemy.type == 'boss' then
                                                        enemy.x = enemy.x + enemy.speed * enemy.dir * dt
                                                        if math.abs(enemy.x - enemy.baseX) > enemy.range / 2 then
                                                            enemy.dir = -enemy.dir
                                                            end
                                                            enemy.shootTimer = enemy.shootTimer - dt
                                                            if enemy.shootTimer <= 0 then
                                                                enemy.shootTimer = 2
                                                                createParticles(enemy.x, enemy.y, 20, {1, 0, 0})
                                                                end
                                                                else
                                                                    enemy.x = enemy.x + enemy.speed * enemy.dir * dt
                                                                    if math.abs(enemy.x - enemy.baseX) > enemy.range / 2 then
                                                                        enemy.dir = -enemy.dir
                                                                        end
                                                                        end
                                                                        end
                                                                        end
                                                                        end
                                                                        function drawLevel()
                                                                        -- Ulepszone tło w stylu Geometry Dash: więcej warstw parallax, kolory
                                                                        love.graphics.setBackgroundColor(0.05, 0.05, 0.1)
                                                                        love.graphics.setColor(0.1, 0.1, 0.3, 0.7)
                                                                        for x = -camera.x * 0.3 % 100, 6000, 100 do
                                                                            love.graphics.line(x, 0, x, love.graphics.getHeight())
                                                                            end
                                                                            for y = 0, love.graphics.getHeight(), 100 do
                                                                                love.graphics.line(0, y, 6000, y)
                                                                                end
                                                                                love.graphics.setColor(0.15, 0.15, 0.35, 0.5)
                                                                                for x = -camera.x * 0.6 % 50, 6000, 50 do
                                                                                    love.graphics.line(x, 0, x, love.graphics.getHeight())
                                                                                    end
                                                                                    for y = 0, love.graphics.getHeight(), 50 do
                                                                                        love.graphics.line(0, y, 6000, y)
                                                                                        end
                                                                                        love.graphics.setColor(0, 1, 0)
                                                                                        for _, platform in ipairs(platforms) do
                                                                                            love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
                                                                                            end
                                                                                            love.graphics.setColor(1, 0, 0)
                                                                                            for _, spike in ipairs(spikes) do
                                                                                                love.graphics.rectangle("fill", spike.x, spike.y, spike.width, spike.height)
                                                                                                end
                                                                                                love.graphics.setColor(1, 1, 0)
                                                                                                for _, d in ipairs(data) do
                                                                                                    if not d.collected then
                                                                                                        love.graphics.circle("fill", d.x + 10, d.y + 10, 10)
                                                                                                        end
                                                                                                        end
                                                                                                        for _, p in ipairs(powerups) do
                                                                                                            if not p.collected then
                                                                                                                if p.type == 'invincibility' then
                                                                                                                    love.graphics.setColor(0, 0, 1)
                                                                                                                    elseif p.type == 'speed' then
                                                                                                                        love.graphics.setColor(1, 0, 1)
                                                                                                                        elseif p.type == 'double_jump' then
                                                                                                                            love.graphics.setColor(0, 1, 0.5)
                                                                                                                            elseif p.type == 'shield' then
                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                end
                                                                                                                                love.graphics.rectangle("fill", p.x, p.y, 20, 20)
                                                                                                                                end
                                                                                                                                end
                                                                                                                                for _, enemy in ipairs(enemies) do
                                                                                                                                    if enemy.disabled then
                                                                                                                                        love.graphics.setColor(0.5, 0.5, 0.5)
                                                                                                                                        elseif enemy.type == 'drone' then
                                                                                                                                            love.graphics.setColor(1, 0.5, 0)
                                                                                                                                            elseif enemy.type == 'boss' then
                                                                                                                                                love.graphics.setColor(1, 0, 0.5)
                                                                                                                                                else
                                                                                                                                                    love.graphics.setColor(1, 0, 0)
                                                                                                                                                    end
                                                                                                                                                    love.graphics.circle("fill", enemy.x, enemy.y, enemy.radius)
                                                                                                                                                    end
                                                                                                                                                    local pulse = 0.8 + 0.2 * math.sin(love.timer.getTime() * 2)
                                                                                                                                                    love.graphics.setColor(0, pulse, 0)
                                                                                                                                                    love.graphics.rectangle("fill", goal.x, goal.y, goal.width, goal.height)
                                                                                                                                                    end
                                                                                                                                                    function updateGame(dt)
                                                                                                                                                    if gameOver or gameWon then return end
                                                                                                                                                        timeElapsed = timeElapsed + dt
                                                                                                                                                        if gameMode == 'time_attack' and timeElapsed > timeLimit then
                                                                                                                                                            gameOver = true
                                                                                                                                                            end
                                                                                                                                                            updatePlayer(dt)
                                                                                                                                                            updateLevel(dt)
                                                                                                                                                            -- Płynna kamera z lekkim wyprzedzeniem jak w GD
                                                                                                                                                            local targetX = player.x - love.graphics.getWidth() / 2 + 100
                                                                                                                                                            camera.x = camera.x + (targetX - camera.x) * 0.15 * dt * 60
                                                                                                                                                            if checkCollision(player, goal) then
                                                                                                                                                                if gameMode == 'endless' then
                                                                                                                                                                    currentLevel = (currentLevel % #levels) + 1
                                                                                                                                                                    loadLevel(currentLevel)
                                                                                                                                                                    player.autoSpeed = player.autoSpeed + 20 -- Zwiększanie prędkości dla wciągania
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
                                                                                                                                                                                end
                                                                                                                                                                                end
                                                                                                                                                                                if score > highScore then
                                                                                                                                                                                    highScore = score
                                                                                                                                                                                    saveHighScore(highScore)
                                                                                                                                                                                    end
                                                                                                                                                                                    if player.y > love.graphics.getHeight() then
                                                                                                                                                                                        loseLife()
                                                                                                                                                                                        end
                                                                                                                                                                                        end
                                                                                                                                                                                        function drawGame()
                                                                                                                                                                                        love.graphics.translate(-camera.x, 0)
                                                                                                                                                                                        drawLevel()
                                                                                                                                                                                        drawPlayer()
                                                                                                                                                                                        love.graphics.translate(camera.x, 0)
                                                                                                                                                                                        love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                        love.graphics.print("Score: " .. math.floor(score), 10, 10)
                                                                                                                                                                                        love.graphics.print("High Score: " .. math.floor(highScore), 10, 30)
                                                                                                                                                                                        love.graphics.print("Level: " .. currentLevel, 10, 50)
                                                                                                                                                                                        love.graphics.print("Lives: " .. lives, 10, 70)
                                                                                                                                                                                        love.graphics.print("Multiplier: x" .. multiplier, 10, 90)
                                                                                                                                                                                        if player.invincible then
                                                                                                                                                                                            love.graphics.print("Invincible: " .. math.ceil(player.invincibleTimer) .. "s", 10, 110)
                                                                                                                                                                                            end
                                                                                                                                                                                            if player.hackTimer > 0 then
                                                                                                                                                                                                love.graphics.print("Hack CD: " .. math.ceil(player.hackTimer) .. "s", 10, 130)
                                                                                                                                                                                                end
                                                                                                                                                                                                if player.speedBoostTimer > 0 then
                                                                                                                                                                                                    love.graphics.print("Speed: " .. math.ceil(player.speedBoostTimer) .. "s", 10, 150)
                                                                                                                                                                                                    end
                                                                                                                                                                                                    if player.doubleJumpAvailable then
                                                                                                                                                                                                        love.graphics.print("Double Jump: Active", 10, 170)
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if player.shield then
                                                                                                                                                                                                            love.graphics.print("Shield: Active", 10, 190)
                                                                                                                                                                                                            end
                                                                                                                                                                                                            if gameMode == 'time_attack' then
                                                                                                                                                                                                                love.graphics.print("Time Left: " .. math.ceil(timeLimit - timeElapsed), 10, 210)
                                                                                                                                                                                                                end
                                                                                                                                                                                                                -- Progress bar z animacją
                                                                                                                                                                                                                love.graphics.setColor(1, 1, 1)
                                                                                                                                                                                                                local progress = math.min(player.x / goal.x, 1)
                                                                                                                                                                                                                love.graphics.rectangle("fill", 10, love.graphics.getHeight() - 30, 200 * progress, 20)
                                                                                                                                                                                                                love.graphics.setColor(1, 1, 0, 0.5 + 0.5 * math.sin(love.timer.getTime() * 5))
                                                                                                                                                                                                                love.graphics.rectangle("line", 10, love.graphics.getHeight() - 30, 200, 20)
                                                                                                                                                                                                                if gameOver then
                                                                                                                                                                                                                    love.graphics.setColor(1, 0, 0)
                                                                                                                                                                                                                    love.graphics.print("Game Over! Press R to Restart or Esc for Menu", 200, 300, 0, 1.5, 1.5)
                                                                                                                                                                                                                    elseif gameWon then
                                                                                                                                                                                                                        love.graphics.setColor(0, 1, 0)
                                                                                                                                                                                                                        love.graphics.print("You Win! High Score: " .. math.floor(highScore) .. "\nPress R to Restart or Esc for Menu", 200, 300, 0, 1.5, 1.5)
                                                                                                                                                                                                                        end
                                                                                                                                                                                                                        end
