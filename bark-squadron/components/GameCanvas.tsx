import React, { useEffect, useRef } from 'react';
import { GameState, Plane, Bullet, Particle, GameStats, Entity, EnemyType, GameSettings } from '../types';
import {
  GRAVITY, DRAG, THRUST, TURN_SPEED, MAX_SPEED, MIN_SPEED,
  BULLET_SPEED, BULLET_LIFE, BULLET_COOLDOWN, PLAYER_HP, ENEMY_STATS,
  PLAYER_SIZE, BULLET_SIZE,
  COLOR_PLAYER, COLOR_BULLET_PLAYER, COLOR_BULLET_ENEMY, COLOR_SKY_TOP, COLOR_SKY_BOTTOM
} from '../constants';

interface GameCanvasProps {
  gameState: GameState;
  settings: GameSettings;
  setGameState: (state: GameState) => void;
  setStats: React.Dispatch<React.SetStateAction<GameStats>>;
  setPlayerHp: (hp: number) => void;
  onGameOver: () => void;
}

const GameCanvas: React.FC<GameCanvasProps> = ({ gameState, settings, setGameState, setStats, setPlayerHp, onGameOver }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const requestRef = useRef<number>(0);
  
  // Mutable game state
  const gameRef = useRef({
    player: null as Plane | null,
    enemies: [] as Plane[],
    bullets: [] as Bullet[],
    particles: [] as Particle[],
    keys: {
      ArrowUp: false,
      ArrowDown: false,
      ArrowLeft: false,
      ArrowRight: false,
      Space: false,
      w: false,
      s: false,
      a: false,
      d: false,
    } as Record<string, boolean>,
    camera: { x: 0, y: 0 },
    shake: 0,
    wave: 1,
    frameCount: 0,
    width: 0,
    height: 0,
    terrain: [] as number[], // Array of Y heights for ground
  });

  // Init Game
  const initGame = (width: number, height: number) => {
    gameRef.current.player = {
      id: 'player',
      type: 'player',
      pos: { x: 0, y: -200 }, // Start in air relative to center
      velocity: { x: 5, y: 0 },
      angle: 0,
      radius: PLAYER_SIZE,
      hp: PLAYER_HP,
      maxHp: PLAYER_HP,
      cooldown: 0,
      ammo: 999,
      team: 0,
      dead: false,
      color: COLOR_PLAYER,
      rotationSpeed: TURN_SPEED,
      speedStat: MAX_SPEED
    };
    gameRef.current.enemies = [];
    gameRef.current.bullets = [];
    gameRef.current.particles = [];
    gameRef.current.camera = { x: 0, y: 0 };
    gameRef.current.wave = 1;
    gameRef.current.shake = 0;
    
    // Generate terrain points
    gameRef.current.terrain = [];
    for(let i=0; i<=100; i++) {
        gameRef.current.terrain.push(Math.sin(i * 0.2) * 100 + Math.sin(i * 0.05) * 200);
    }
    
    spawnWave(1);
  };

  const spawnWave = (wave: number) => {
    // Difficulty modifier
    const diffMod = settings.difficulty === 'easy' ? 0.7 : settings.difficulty === 'hard' ? 1.5 : 1.0;
    const enemyCount = Math.floor((2 + Math.floor(wave * 1.2)) * diffMod);

    for (let i = 0; i < enemyCount; i++) {
      // Determine Enemy Type based on Wave
      let type = EnemyType.GRUNT;
      const roll = Math.random();
      if (wave > 2 && roll > 0.7) type = EnemyType.ACE;
      if (wave > 4 && roll > 0.9) type = EnemyType.BOMBER;

      const stats = ENEMY_STATS[type];
      const spawnX = (Math.random() > 0.5 ? 800 : -800) + gameRef.current.camera.x;
      const spawnY = (Math.random() * 400 - 200) + gameRef.current.camera.y;

      gameRef.current.enemies.push({
        id: `enemy-${wave}-${i}`,
        type: 'enemy',
        enemyType: type,
        pos: { x: spawnX, y: spawnY },
        velocity: { x: Math.random() > 0.5 ? 4 : -4, y: 0 },
        angle: Math.random() * Math.PI * 2,
        radius: stats.size,
        hp: stats.hp,
        maxHp: stats.hp,
        cooldown: Math.random() * 50,
        ammo: 999,
        team: 1,
        dead: false,
        color: stats.color,
        rotationSpeed: stats.turn,
        speedStat: stats.speed
      });
    }
  };

  // Input Handling
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      gameRef.current.keys[e.key] = true;
      if (e.code === 'Space') gameRef.current.keys['Space'] = true;
      if (e.key === 'Escape') {
         if (gameState === GameState.PLAYING) setGameState(GameState.PAUSED);
         else if (gameState === GameState.PAUSED) setGameState(GameState.PLAYING);
      }
    };
    const handleKeyUp = (e: KeyboardEvent) => {
      gameRef.current.keys[e.key] = false;
      if (e.code === 'Space') gameRef.current.keys['Space'] = false;
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [gameState]);

  // Main Loop
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      gameRef.current.width = canvas.width;
      gameRef.current.height = canvas.height;
    };
    window.addEventListener('resize', resize);
    resize();

    if (gameState === GameState.PLAYING && !gameRef.current.player) {
      initGame(canvas.width, canvas.height);
    }

    const loop = (time: number) => {
      if (gameState === GameState.PLAYING) {
        update(canvas.width, canvas.height);
        draw(ctx, canvas.width, canvas.height);
        requestRef.current = requestAnimationFrame(loop);
      } else if (gameState === GameState.PAUSED) {
        // Just draw one frame to keep background visible
        draw(ctx, canvas.width, canvas.height);
      }
    };

    requestRef.current = requestAnimationFrame(loop);

    return () => {
      cancelAnimationFrame(requestRef.current);
      window.removeEventListener('resize', resize);
    };
  }, [gameState, settings]); // Re-bind if settings change


  // --- Logic ---

  const update = (width: number, height: number) => {
    const game = gameRef.current;
    if (!game.player) return;
    game.frameCount++;

    if (game.enemies.length === 0) {
      game.wave++;
      setStats(prev => ({ ...prev, wave: game.wave }));
      spawnWave(game.wave);
    }

    // Screen shake decay
    if (game.shake > 0) game.shake *= 0.9;
    if (game.shake < 0.5) game.shake = 0;

    // --- Player Control ---
    const p = game.player;
    const keys = game.keys;

    // Turning
    if (keys.ArrowLeft || keys.a) p.angle -= p.rotationSpeed;
    if (keys.ArrowRight || keys.d) p.angle += p.rotationSpeed;

    // Thrust
    const isBoosting = keys.ArrowUp || keys.w;
    if (isBoosting) {
      p.velocity.x += Math.cos(p.angle) * THRUST;
      p.velocity.y += Math.sin(p.angle) * THRUST;
      
      // Exhaust
      if (game.frameCount % 3 === 0 && settings.particles) {
         game.particles.push(createParticle(
           p.pos.x - Math.cos(p.angle) * 15,
           p.pos.y - Math.sin(p.angle) * 15,
           'rgba(200,200,200,0.5)', 20, 2, 'smoke'
         ));
      }
    }

    // Gravity & Physics
    p.velocity.y += GRAVITY;
    p.velocity.x *= DRAG;
    p.velocity.y *= DRAG;

    // Speed Cap
    const speed = Math.sqrt(p.velocity.x ** 2 + p.velocity.y ** 2);
    if (speed > p.speedStat) {
      const ratio = p.speedStat / speed;
      p.velocity.x *= ratio;
      p.velocity.y *= ratio;
    }
    // Stall logic
    if (speed < MIN_SPEED) {
        p.angle += 0.05; // Nose dip
        p.velocity.y += 0.05; // Fall faster
    }

    // Position Update
    p.pos.x += p.velocity.x;
    p.pos.y += p.velocity.y;

    // Ground Collision (Approximate by checking Y vs arbitrary floor for now, later terrain)
    // We will define floor as +800 relative to start 0
    const FLOOR_Y = 600;
    if (p.pos.y > FLOOR_Y) {
        p.pos.y = FLOOR_Y;
        p.velocity.y = -p.velocity.y * 0.5; // Bounce
        p.hp -= 20;
        game.shake = 10;
        createExplosion(game, p.pos.x, p.pos.y, 20, '#5c4033'); // Dust
    }
    // Ceiling
    if (p.pos.y < -1500) {
        p.velocity.y += 0.2;
    }

    // Shooting
    if (p.cooldown > 0) p.cooldown--;
    if ((keys.Space) && p.cooldown <= 0) {
      shoot(game, p);
      // Recoil
      p.velocity.x -= Math.cos(p.angle) * 0.2;
      p.velocity.y -= Math.sin(p.angle) * 0.2;
    }

    setPlayerHp(p.hp);
    if (p.hp <= 0 && !p.dead) {
        p.dead = true;
        game.shake = 30;
        createExplosion(game, p.pos.x, p.pos.y, 100, '#ffffff');
        setTimeout(onGameOver, 1500);
    }

    // --- Enemy AI ---
    game.enemies.forEach(e => {
      const distToPlayer = Math.hypot(p.pos.x - e.pos.x, p.pos.y - e.pos.y);
      let targetAngle = e.angle;
      
      if (!p.dead) {
        // AI Behaviors
        if (e.enemyType === EnemyType.BOMBER) {
           // Bombers fly straight mostly, slow turn towards player if far
           const angleToPlayer = Math.atan2(p.pos.y - e.pos.y, p.pos.x - e.pos.x);
           targetAngle = angleToPlayer;
        } else if (e.enemyType === EnemyType.ACE) {
           // Aces try to get behind you
           const behindX = p.pos.x - Math.cos(p.angle) * 200;
           const behindY = p.pos.y - Math.sin(p.angle) * 200;
           targetAngle = Math.atan2(behindY - e.pos.y, behindX - e.pos.x);
        } else {
           // Grunts just chase directly
           targetAngle = Math.atan2(p.pos.y - e.pos.y, p.pos.x - e.pos.x);
        }
      }
      
      // Smooth turning
      const diff = targetAngle - e.angle;
      const angleDiff = Math.atan2(Math.sin(diff), Math.cos(diff));
      e.angle += Math.sign(angleDiff) * e.rotationSpeed;

      // Thrust
      e.velocity.x += Math.cos(e.angle) * (THRUST * 0.8);
      e.velocity.y += Math.sin(e.angle) * (THRUST * 0.8);
      
      // Physics
      e.velocity.y += GRAVITY;
      e.velocity.x *= DRAG;
      e.velocity.y *= DRAG;
      
      const eSpeed = Math.sqrt(e.velocity.x ** 2 + e.velocity.y ** 2);
      if (eSpeed > e.speedStat) {
        const ratio = e.speedStat / eSpeed;
        e.velocity.x *= ratio;
        e.velocity.y *= ratio;
      }

      e.pos.x += e.velocity.x;
      e.pos.y += e.velocity.y;

      // Floor collision
      if (e.pos.y > FLOOR_Y) {
        e.pos.y = FLOOR_Y;
        e.velocity.y = -e.velocity.y * 0.5;
      }

      // Shoot
      if (e.cooldown > 0) e.cooldown--;
      // Grunts shoot if looking at you, Aces shoot more accurately, Bombers shoot rarely
      const shootThreshold = e.enemyType === EnemyType.BOMBER ? 0.99 : 0.95;
      const accuracy = e.enemyType === EnemyType.ACE ? 0.3 : 0.5;
      
      if (distToPlayer < 500 && Math.abs(angleDiff) < accuracy && e.cooldown <= 0 && !p.dead && Math.random() > shootThreshold) {
        shoot(game, e);
      }
    });

    // --- Bullets ---
    for (let i = game.bullets.length - 1; i >= 0; i--) {
      const b = game.bullets[i];
      b.life--;
      b.pos.x += b.velocity.x;
      b.pos.y += b.velocity.y;

      // Trail
      if (settings.particles && b.life % 2 === 0) {
        game.particles.push(createParticle(b.pos.x, b.pos.y, b.team === 0 ? '#fcd34d' : '#f87171', 10, 1, 'spark'));
      }

      let hit = false;
      // Collision Detection
      if (b.team === 0) { // Player bullet
         for (let j = game.enemies.length - 1; j >= 0; j--) {
            const e = game.enemies[j];
            if (checkCollision(b, e)) {
               e.hp -= 15;
               hit = true;
               game.particles.push(createParticle(b.pos.x, b.pos.y, '#fff', 5, 2, 'spark'));
               if (e.hp <= 0) {
                 createExplosion(game, e.pos.x, e.pos.y, e.enemyType === EnemyType.BOMBER ? 60 : 30, e.color);
                 game.enemies.splice(j, 1);
                 game.shake += 5;
                 setStats(prev => ({ ...prev, score: prev.score + (e.enemyType === 'bomber' ? 300 : 100), kills: prev.kills + 1 }));
               }
               break;
            }
         }
      } else { // Enemy bullet
         if (checkCollision(b, p)) {
            p.hp -= settings.difficulty === 'hard' ? 15 : 8;
            hit = true;
            game.shake += 2;
            createExplosion(game, b.pos.x, b.pos.y, 5, COLOR_BULLET_ENEMY);
         }
      }

      if (hit || b.life <= 0) game.bullets.splice(i, 1);
    }

    // --- Particles ---
    for (let i = game.particles.length - 1; i >= 0; i--) {
      const part = game.particles[i];
      part.life--;
      part.pos.x += part.velocity.x;
      part.pos.y += part.velocity.y;
      
      // Drag/Gravity for particles
      part.velocity.x *= 0.95;
      part.velocity.y *= 0.95;
      if (part.type === 'smoke') part.velocity.y -= 0.02; // Smoke rises

      if (part.life <= 0) game.particles.splice(i, 1);
    }

    // --- Camera Follow ---
    const targetCamX = p.pos.x - width / 2;
    const targetCamY = p.pos.y - height / 2;
    // Smooth Lerp
    game.camera.x += (targetCamX - game.camera.x) * 0.1;
    game.camera.y += (targetCamY - game.camera.y) * 0.1;
    
    // Floor clamp for camera
    if (game.camera.y > 200) game.camera.y = 200;
  };

  // --- Rendering ---

  const draw = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
    const game = gameRef.current;
    if (!game.player) return;
    
    // Dynamic Sky Gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, height);
    gradient.addColorStop(0, COLOR_SKY_TOP);
    gradient.addColorStop(1, COLOR_SKY_BOTTOM);
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, width, height);

    ctx.save();
    
    // Apply Shake
    const shakeX = (Math.random() - 0.5) * game.shake;
    const shakeY = (Math.random() - 0.5) * game.shake;
    ctx.translate(-game.camera.x + shakeX, -game.camera.y + shakeY);

    // 1. Draw Parallax Background (Mountains/Hills)
    drawTerrain(ctx, game.camera.x, game.camera.y, width, height, game.terrain);

    // 2. Draw Clouds
    drawClouds(ctx, game.camera.x, game.camera.y);

    // 3. Draw Game Objects
    // Enemies
    game.enemies.forEach(e => drawBiplane(ctx, e));

    // Player
    if (!game.player.dead) drawBiplane(ctx, game.player);

    // Bullets
    game.bullets.forEach(b => {
      ctx.fillStyle = b.team === 0 ? COLOR_BULLET_PLAYER : COLOR_BULLET_ENEMY;
      ctx.beginPath();
      ctx.arc(b.pos.x, b.pos.y, BULLET_SIZE, 0, Math.PI * 2);
      ctx.fill();
    });

    // Particles
    game.particles.forEach(p => {
      const alpha = p.life / p.maxLife;
      ctx.globalAlpha = alpha;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      let size = p.size;
      if (p.type === 'fire') size = p.size * alpha; // Fire shrinks
      if (p.type === 'smoke') size = p.size + (1-alpha) * 10; // Smoke expands
      
      ctx.arc(p.pos.x, p.pos.y, size, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalAlpha = 1.0;
    });
    
    // Hitboxes (Debug)
    if (settings.showHitboxes) {
        ctx.strokeStyle = 'lime';
        ctx.lineWidth = 1;
        [game.player, ...game.enemies].forEach(e => {
            if (e && !e.dead) {
                ctx.beginPath();
                ctx.arc(e.pos.x, e.pos.y, e.radius, 0, Math.PI * 2);
                ctx.stroke();
            }
        });
    }

    ctx.restore();
  };

  // --- Artistic Helpers ---

  const drawBiplane = (ctx: CanvasRenderingContext2D, p: Plane) => {
    ctx.save();
    ctx.translate(p.pos.x, p.pos.y);
    
    // Health Bar
    if (p.hp < p.maxHp) {
        ctx.save();
        ctx.rotate(-p.angle); // Keep bar horizontal relative to screen usually, or relative to plane? Let's keep relative to plane is easier, but rotating it back is better for UI
        // Actually, let's keep it simple and draw above rotated plane
        ctx.fillStyle = 'rgba(0,0,0,0.5)';
        ctx.fillRect(-20, -35, 40, 5);
        ctx.fillStyle = p.hp < p.maxHp * 0.3 ? 'red' : '#22c55e';
        ctx.fillRect(-19, -34, 38 * (Math.max(0, p.hp) / p.maxHp), 3);
        ctx.restore();
    }

    // Shadow (Offset)
    ctx.fillStyle = 'rgba(0,0,0,0.2)';
    ctx.beginPath();
    ctx.ellipse(0, 40, 15, 5, 0, 0, Math.PI * 2);
    ctx.fill();

    // Rotate Plane
    ctx.rotate(p.angle);
    
    // Flip if flying left to keep plane upright-ish or just inverted? 
    // Standard dogfight games rotate fully. 
    // But to make the drawing look "right" (pilot head up), we might mirror Y if angle is > 90.
    // For this simple top-down/side view hybrid, full rotation is fine.
    
    const isEnemy = p.team === 1;
    const mainColor = p.color;
    const accentColor = isEnemy ? '#333' : '#e2e8f0';

    // -- Drawing the Biplane --
    
    // 1. Bottom Wing
    ctx.fillStyle = mainColor;
    ctx.fillRect(-15, 10, 30, 4);
    
    // 2. Struts
    ctx.fillStyle = '#64748b'; // Slate 500
    ctx.fillRect(-10, -10, 2, 20);
    ctx.fillRect(5, -10, 2, 20);

    // 3. Fuselage (Body)
    ctx.fillStyle = mainColor;
    ctx.beginPath();
    ctx.moveTo(25, 0); // Nose
    ctx.lineTo(-20, 0); // Tail start
    ctx.lineTo(-25, -5); // Tail top
    ctx.lineTo(-25, 5); // Tail bottom
    ctx.lineTo(-20, 0);
    ctx.fill();

    // 4. Cockpit / Pilot
    ctx.fillStyle = '#1e293b'; // Dark
    ctx.beginPath();
    ctx.ellipse(0, -2, 8, 5, 0, 0, Math.PI * 2);
    ctx.fill();
    // Scarf (Simulated)
    ctx.strokeStyle = isEnemy ? 'black' : 'red';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(-5, -2);
    ctx.lineTo(-15 + Math.random()*5, -2 + Math.random()*5); // Flapping scarf
    ctx.stroke();

    // 5. Top Wing
    ctx.fillStyle = mainColor;
    ctx.fillRect(-18, -10, 36, 4);
    // Stripe on wing
    ctx.fillStyle = accentColor;
    ctx.fillRect(-5, -10, 4, 4);

    // 6. Propeller
    ctx.fillStyle = 'rgba(200, 200, 200, 0.6)';
    ctx.beginPath();
    const propSize = 18;
    // Spin animation based on time or random
    const angle = Date.now() / 20; 
    ctx.ellipse(25, 0, 2, propSize * Math.abs(Math.sin(angle)), 0, 0, Math.PI * 2);
    ctx.fill();
    
    // 7. Tail Fin
    ctx.fillStyle = mainColor;
    ctx.beginPath();
    ctx.moveTo(-20, 0);
    ctx.lineTo(-28, -12);
    ctx.lineTo(-24, 0);
    ctx.fill();

    ctx.restore();
  };

  const drawTerrain = (ctx: CanvasRenderingContext2D, camX: number, camY: number, width: number, height: number, terrain: number[]) => {
      // Distant mountains (Parallax slow)
      ctx.fillStyle = '#1e1b4b'; // Dark blue
      ctx.beginPath();
      ctx.moveTo(-width, height);
      for(let x = -width; x < width * 2; x+=50) {
          const worldX = x + camX * 0.9; // Moves with camera mostly
          const h = Math.sin(worldX * 0.002) * 200 + 400;
          ctx.lineTo(x, height - h + (camY * 0.1)); // Reduced Y parallax
      }
      ctx.lineTo(width * 2, height);
      ctx.fill();

      // Closer Hills (Ground)
      ctx.fillStyle = '#064e3b'; // Dark Green
      ctx.beginPath();
      ctx.moveTo(-width, height); // Bottom Left
      
      const groundY = 600; // Base ground level
      const segmentWidth = 100;
      
      // We need to map screen X to world X to get terrain index
      const startCol = Math.floor(camX / segmentWidth) - 10;
      const endCol = startCol + (width / segmentWidth) + 20;

      for (let i = startCol; i <= endCol; i++) {
         const wx = i * segmentWidth - camX;
         // Procedural-ish noise based on index
         const noise = Math.sin(i * 0.5) * 50 + Math.sin(i * 0.1) * 150;
         const wy = (groundY + noise) - camY;
         ctx.lineTo(wx, wy);
      }

      ctx.lineTo(width, height);
      ctx.lineTo(-width, height);
      ctx.fill();
  };

  const drawClouds = (ctx: CanvasRenderingContext2D, camX: number, camY: number) => {
     ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
     // Background clouds
     for(let i = -5; i < 15; i++) {
        const x = (i * 600) - (camX * 0.5 % 600); 
        const y = 100 + (Math.sin(i)*100) - (camY * 0.5);
        
        ctx.beginPath();
        ctx.arc(x, y, 60, 0, Math.PI * 2);
        ctx.arc(x + 50, y - 20, 70, 0, Math.PI * 2);
        ctx.arc(x + 100, y, 60, 0, Math.PI * 2);
        ctx.fill();
     }
  };

  // --- Helpers ---
  
  const shoot = (game: any, entity: Plane) => {
     entity.cooldown = BULLET_COOLDOWN;
     // Muzzle flash
     game.particles.push(createParticle(
         entity.pos.x + Math.cos(entity.angle) * 25,
         entity.pos.y + Math.sin(entity.angle) * 25,
         '#fff', 5, 2, 'spark'
     ));
     
     game.bullets.push({
       id: Math.random().toString(),
       pos: { 
         x: entity.pos.x + Math.cos(entity.angle) * 20, 
         y: entity.pos.y + Math.sin(entity.angle) * 20 
       },
       velocity: {
         x: entity.velocity.x + Math.cos(entity.angle) * BULLET_SPEED,
         y: entity.velocity.y + Math.sin(entity.angle) * BULLET_SPEED
       },
       angle: entity.angle,
       radius: BULLET_SIZE,
       dead: false,
       team: entity.team,
       life: BULLET_LIFE
     });
  };

  const createParticle = (x: number, y: number, color: string, life: number, size: number, type: 'fire' | 'smoke' | 'spark'): Particle => {
    return {
      id: Math.random().toString(),
      pos: { x, y },
      velocity: { x: (Math.random() - 0.5) * 2, y: (Math.random() - 0.5) * 2 },
      angle: 0,
      radius: size,
      dead: false,
      color,
      life,
      maxLife: life,
      size,
      type
    };
  };

  const createExplosion = (game: any, x: number, y: number, count: number, baseColor: string) => {
    if (!settings.particles) return;
    for(let i=0; i<count; i++) {
      // Fire
      if (Math.random() > 0.5) {
          game.particles.push(createParticle(x, y, '#f97316', 20 + Math.random() * 20, 10 + Math.random()*10, 'fire'));
      }
      // Smoke
      game.particles.push(createParticle(x, y, '#525252', 40 + Math.random() * 40, 5 + Math.random()*15, 'smoke'));
      // Debris
      game.particles.push(createParticle(x, y, baseColor, 30 + Math.random() * 10, 3, 'spark'));
    }
  };

  const checkCollision = (a: Entity, b: Entity) => {
    const dx = a.pos.x - b.pos.x;
    const dy = a.pos.y - b.pos.y;
    const dist = Math.sqrt(dx*dx + dy*dy);
    return dist < (a.radius + b.radius);
  };

  return <canvas ref={canvasRef} className="w-full h-full block" />;
};

export default GameCanvas;
