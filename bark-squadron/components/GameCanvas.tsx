import React, { useEffect, useRef } from 'react';
import { GameState, Plane, Bullet, Particle, GameStats, Entity, EnemyType, GameSettings } from '../types';
import {
  GRAVITY, DRAG, THRUST, MAX_SPEED, MIN_SPEED,
  BULLET_SPEED, BULLET_LIFE, BULLET_COOLDOWN, PLAYER_HP, ENEMY_STATS,
  PLAYER_SIZE, BULLET_SIZE, SEA_LEVEL,
  COLOR_PLAYER, COLOR_BULLET_PLAYER, COLOR_BULLET_ENEMY, COLOR_SKY_TOP, COLOR_SKY_BOTTOM, COLOR_WATER_TOP
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
  });

  // --- Core Game Logic ---

  // BUG FIX: Completely reset the game state
  const resetGame = (width: number, height: number) => {
    gameRef.current.player = {
      id: 'player',
      type: 'player',
      pos: { x: 0, y: -400 }, // Start high up
      velocity: { x: 8, y: 0 },
      angle: 0,
      radius: PLAYER_SIZE,
      hp: PLAYER_HP,
      maxHp: PLAYER_HP,
      cooldown: 0,
      ammo: 999,
      team: 0,
      dead: false,
      color: COLOR_PLAYER,
      rotationSpeed: 0.05, // Will be overridden by input logic
      speedStat: MAX_SPEED,
      afterburner: false
    };
    gameRef.current.enemies = [];
    gameRef.current.bullets = [];
    gameRef.current.particles = [];
    gameRef.current.camera = { x: 0, y: -200 };
    gameRef.current.wave = 1;
    gameRef.current.shake = 0;

    spawnWave(1);
  };

  const spawnWave = (wave: number) => {
    const diffMod = settings.difficulty === 'easy' ? 0.7 : settings.difficulty === 'hard' ? 1.5 : 1.0;
    const enemyCount = Math.floor((2 + Math.floor(wave * 1.3)) * diffMod);

    for (let i = 0; i < enemyCount; i++) {
      let type = EnemyType.GRUNT;
      const roll = Math.random();
      if (wave > 2 && roll > 0.6) type = EnemyType.ACE;
      if (wave > 4 && roll > 0.85) type = EnemyType.BOMBER;

      const stats = ENEMY_STATS[type];
      const spawnX = (Math.random() > 0.5 ? 1200 : -1200) + gameRef.current.camera.x;
      const spawnY = (Math.random() * 400 - 400) + gameRef.current.camera.y;

      gameRef.current.enemies.push({
        id: `enemy-${wave}-${i}`,
        type: 'enemy',
        enemyType: type,
        pos: { x: spawnX, y: spawnY },
        velocity: { x: Math.random() > 0.5 ? 6 : -6, y: 0 },
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
                                   speedStat: stats.speed,
                                   afterburner: false
      });
    }
  };

  // State Management Hooks
  useEffect(() => {
    // If we enter BRIEFING, we assume a new game is about to start, so we reset.
    // This fixes the bug where starting a new game puts you at death location.
    if (gameState === GameState.BRIEFING) {
      if (canvasRef.current) {
        resetGame(canvasRef.current.width, canvasRef.current.height);
      }
    }
  }, [gameState]);

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
    const ctx = canvas.getContext('2d', { alpha: false }); // Optimize
    if (!ctx) return;

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      gameRef.current.width = canvas.width;
      gameRef.current.height = canvas.height;
    };
    window.addEventListener('resize', resize);
    resize();

    // Initial safe check (though BRIEFING useEffect handles most reset logic)
    if (gameState === GameState.PLAYING && !gameRef.current.player) {
      resetGame(canvas.width, canvas.height);
    }

    const loop = (time: number) => {
      if (gameState === GameState.PLAYING) {
        update(canvas.width, canvas.height);
        draw(ctx, canvas.width, canvas.height);
        requestRef.current = requestAnimationFrame(loop);
      } else if (gameState === GameState.PAUSED) {
        draw(ctx, canvas.width, canvas.height);
      }
    };

    requestRef.current = requestAnimationFrame(loop);

    return () => {
      cancelAnimationFrame(requestRef.current);
      window.removeEventListener('resize', resize);
    };
  }, [gameState, settings]);


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

    if (game.shake > 0) game.shake *= 0.9;
    if (game.shake < 0.5) game.shake = 0;

    // --- Player Control ---
    const p = game.player;
    const keys = game.keys;

    // Turning with sensitivity setting
    const effectiveTurnSpeed = p.rotationSpeed * settings.sensitivity; // Default is ~1.0
    if (keys.ArrowLeft || keys.a) p.angle -= effectiveTurnSpeed;
    if (keys.ArrowRight || keys.d) p.angle += effectiveTurnSpeed;

    // Thrust / Afterburner
    const isBoosting = keys.ArrowUp || keys.w;
    p.afterburner = isBoosting;

    if (isBoosting) {
      p.velocity.x += Math.cos(p.angle) * THRUST;
      p.velocity.y += Math.sin(p.angle) * THRUST;

      // Jet Exhaust Particles
      if (game.frameCount % 2 === 0 && settings.particles) {
        game.particles.push(createParticle(
          p.pos.x - Math.cos(p.angle) * 30,
                                           p.pos.y - Math.sin(p.angle) * 30,
                                           'rgba(255, 100, 0, 0.6)', 10, 8, 'fire'
        ));
      }
    }

    // Gravity & Physics
    p.velocity.y += GRAVITY;
    p.velocity.x *= DRAG;
    p.velocity.y *= DRAG;

    const speed = Math.sqrt(p.velocity.x ** 2 + p.velocity.y ** 2);

    // Max Speed Cap
    if (speed > p.speedStat) {
      const ratio = p.speedStat / speed;
      p.velocity.x *= ratio;
      p.velocity.y *= ratio;
    }
    // Stall Speed
    if (speed < MIN_SPEED) {
      p.angle += 0.08; // Nose drops faster in jet stall
      p.velocity.y += 0.1;
    }

    p.pos.x += p.velocity.x;
    p.pos.y += p.velocity.y;

    // --- Water Interactions (Skimming) ---
    const distToWater = SEA_LEVEL - p.pos.y;

    // Crash into water
    if (p.pos.y > SEA_LEVEL) {
      p.pos.y = SEA_LEVEL;
      p.velocity.y = -p.velocity.y * 0.4;
      p.velocity.x *= 0.85;
      p.hp -= 25;
      game.shake = 15;
      createSplash(game, p.pos.x, SEA_LEVEL, 20);
    }
    // Skimming effect (Low flyby)
    else if (distToWater > 0 && distToWater < 80 && Math.abs(p.velocity.x) > 4) {
      if (game.frameCount % 3 === 0 && settings.particles) {
        // Create mist/wake behind plane
        const wakeX = p.pos.x - Math.cos(p.angle) * 40;
        const wakeY = SEA_LEVEL;
        game.particles.push(createParticle(wakeX, wakeY, 'rgba(255,255,255,0.4)', 40, 10 + Math.random() * 10, 'wake'));

        // If very close, creating ripples
        if (distToWater < 30) {
          game.particles.push(createParticle(p.pos.x, SEA_LEVEL, 'rgba(255,255,255,0.8)', 20, 5, 'splash'));
        }
      }
    }

    if (p.pos.y < -3000) p.velocity.y += 0.2; // Ceiling

    // Shooting
    if (p.cooldown > 0) p.cooldown--;
    if ((keys.Space) && p.cooldown <= 0) {
      shoot(game, p);
      // Minigun recoil (very slight for jets)
      p.velocity.x -= Math.cos(p.angle) * 0.05;
      p.velocity.y -= Math.sin(p.angle) * 0.05;
    }

    setPlayerHp(p.hp);
    if (p.hp <= 0 && !p.dead) {
      p.dead = true;
      game.shake = 30;
      createExplosion(game, p.pos.x, p.pos.y, 80, '#ffffff');
      setTimeout(onGameOver, 1500);
    }

    // --- Enemy AI ---
    game.enemies.forEach(e => {
      const distToPlayer = Math.hypot(p.pos.x - e.pos.x, p.pos.y - e.pos.y);
      let targetAngle = e.angle;

      if (!p.dead) {
        if (e.enemyType === EnemyType.BOMBER) {
          targetAngle = Math.atan2(p.pos.y - e.pos.y, p.pos.x - e.pos.x);
        } else if (e.enemyType === EnemyType.ACE) {
          // Interceptor logic
          const predictX = p.pos.x + p.velocity.x * 20;
          const predictY = p.pos.y + p.velocity.y * 20;
          targetAngle = Math.atan2(predictY - e.pos.y, predictX - e.pos.x);
        } else {
          targetAngle = Math.atan2(p.pos.y - e.pos.y, p.pos.x - e.pos.x);
        }
      }

      const diff = targetAngle - e.angle;
      const angleDiff = Math.atan2(Math.sin(diff), Math.cos(diff));
      e.angle += Math.sign(angleDiff) * e.rotationSpeed;

      // Smart throttle
      if (Math.abs(angleDiff) < 0.5) {
        e.afterburner = true;
        e.velocity.x += Math.cos(e.angle) * (THRUST * 0.9);
        e.velocity.y += Math.sin(e.angle) * (THRUST * 0.9);
      } else {
        e.afterburner = false;
        e.velocity.x += Math.cos(e.angle) * (THRUST * 0.4);
        e.velocity.y += Math.sin(e.angle) * (THRUST * 0.4);
      }

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

      // Enemy Water Logic
      if (e.pos.y > SEA_LEVEL) {
        e.pos.y = SEA_LEVEL;
        e.velocity.y = -e.velocity.y * 0.4;
        createSplash(game, e.pos.x, SEA_LEVEL, 10);
      }
      // Enemy Skimming
      if (SEA_LEVEL - e.pos.y < 60 && SEA_LEVEL - e.pos.y > 0 && settings.particles && game.frameCount % 4 === 0) {
        game.particles.push(createParticle(e.pos.x, SEA_LEVEL, 'rgba(255,255,255,0.3)', 30, 8, 'wake'));
      }

      if (e.cooldown > 0) e.cooldown--;
      const shootThreshold = e.enemyType === EnemyType.BOMBER ? 0.98 : 0.92;
      const accuracy = e.enemyType === EnemyType.ACE ? 0.2 : 0.4;

      if (distToPlayer < 800 && Math.abs(angleDiff) < accuracy && e.cooldown <= 0 && !p.dead && Math.random() > shootThreshold) {
        shoot(game, e);
      }
    });

    // --- Bullets ---
    for (let i = game.bullets.length - 1; i >= 0; i--) {
      const b = game.bullets[i];
      b.life--;
      b.pos.x += b.velocity.x;
      b.pos.y += b.velocity.y;

      // Water impact
      if (b.pos.y > SEA_LEVEL) {
        createSplash(game, b.pos.x, SEA_LEVEL, 3);
        game.bullets.splice(i, 1);
        continue;
      }

      // Trail
      if (settings.particles && b.life % 2 === 0) {
        // Tracer effect
        game.particles.push(createParticle(b.pos.x, b.pos.y, b.team === 0 ? 'rgba(253, 224, 71, 0.5)' : 'rgba(248, 113, 113, 0.5)', 5, 2, 'spark'));
      }

      let hit = false;
      if (b.team === 0) { // Player bullet
        for (let j = game.enemies.length - 1; j >= 0; j--) {
          const e = game.enemies[j];
          if (checkCollision(b, e)) {
            e.hp -= 15;
            hit = true;
            game.particles.push(createParticle(b.pos.x, b.pos.y, '#fff', 5, 4, 'spark'));
            if (e.hp <= 0) {
              createExplosion(game, e.pos.x, e.pos.y, e.enemyType === EnemyType.BOMBER ? 80 : 40, e.color);
              game.enemies.splice(j, 1);
              game.shake += 5;
              setStats(prev => ({ ...prev, score: prev.score + (e.enemyType === 'bomber' ? 500 : 150), kills: prev.kills + 1 }));
            }
            break;
          }
        }
      } else { // Enemy bullet
        if (checkCollision(b, p)) {
          p.hp -= settings.difficulty === 'hard' ? 10 : 5;
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

      part.velocity.x *= 0.95;
      part.velocity.y *= 0.95;
      if (part.type === 'smoke') part.velocity.y -= 0.02;
      if (part.type === 'splash' || part.type === 'wake') part.velocity.y += 0.1;

      // Kill water particles if they sink
      if ((part.type === 'splash' || part.type === 'wake') && part.pos.y > SEA_LEVEL + 10) {
        part.life = 0;
      }

      if (part.life <= 0) game.particles.splice(i, 1);
    }

    // --- Camera Follow ---
    const targetCamX = p.pos.x - width / 2;
    // Look ahead logic
    const lookAheadX = p.velocity.x * 20;
    const targetCamY = Math.min(p.pos.y - height / 2 + p.velocity.y * 10, SEA_LEVEL - height + 100);

    // Smooth camera
    game.camera.x += (targetCamX + lookAheadX - game.camera.x) * 0.08;
    game.camera.y += (targetCamY - game.camera.y) * 0.08;
  };

  // --- Rendering ---

  const draw = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
    const game = gameRef.current;
    if (!game.player) return;

    // 1. Dynamic Sky
    const gradient = ctx.createLinearGradient(0, 0, 0, height);
    gradient.addColorStop(0, COLOR_SKY_TOP);
    gradient.addColorStop(1, COLOR_SKY_BOTTOM);
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, width, height);

    ctx.save();

    // Shake
    const shakeX = (Math.random() - 0.5) * game.shake;
    const shakeY = (Math.random() - 0.5) * game.shake;
    ctx.translate(-game.camera.x + shakeX, -game.camera.y + shakeY);

    // 2. Sun
    const sunX = game.camera.x * 0.9 + width * 0.8; // Parallax sun
    const sunY = game.camera.y * 0.9 + -300;
    ctx.fillStyle = '#fef08a';
    ctx.shadowBlur = 60;
    ctx.shadowColor = '#fef08a';
    ctx.beginPath();
    ctx.arc(sunX, sunY, 80, 0, Math.PI*2);
    ctx.fill();
    ctx.shadowBlur = 0;

    // 3. Background Clouds
    drawClouds(ctx, game.camera.x, game.camera.y, 0.3, -200);

    // 4. Reflections
    if (settings.highQuality) {
      drawReflections(ctx, game.player, game.enemies);
    }

    // 5. Water Surface
    drawWater(ctx, game.camera.x, width, height, game.frameCount);

    // 6. Game Objects
    game.enemies.forEach(e => drawJet(ctx, e));
    if (!game.player.dead) drawJet(ctx, game.player);

    game.bullets.forEach(b => {
      ctx.fillStyle = b.team === 0 ? COLOR_BULLET_PLAYER : COLOR_BULLET_ENEMY;

      // Draw as elongated tracers
      ctx.save();
      ctx.translate(b.pos.x, b.pos.y);
      ctx.rotate(Math.atan2(b.velocity.y, b.velocity.x));
      ctx.beginPath();
      // Glowing core
      ctx.shadowBlur = 5;
      ctx.shadowColor = ctx.fillStyle;
      ctx.rect(-10, -2, 20, 4);
      ctx.fill();
      ctx.shadowBlur = 0;
      ctx.restore();
    });

    // 7. Foreground Clouds
    drawClouds(ctx, game.camera.x, game.camera.y, 0.7, 100);

    // 8. Particles
    game.particles.forEach(p => {
      const alpha = p.life / p.maxLife;
      ctx.globalAlpha = alpha;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      let size = p.size;

      if (p.type === 'wake') {
        // Elongated wake foam
        size = p.size * alpha;
        ctx.ellipse(p.pos.x, p.pos.y, size * 2, size * 0.5, 0, 0, Math.PI*2);
      } else {
        if (p.type === 'fire') size = p.size * alpha;
        if (p.type === 'smoke') size = p.size + (1-alpha) * 15;
        ctx.arc(p.pos.x, p.pos.y, size, 0, Math.PI * 2);
      }
      ctx.fill();
      ctx.globalAlpha = 1.0;
    });

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

  const drawWater = (ctx: CanvasRenderingContext2D, camX: number, width: number, height: number, frame: number) => {
    ctx.fillStyle = COLOR_WATER_TOP;
    ctx.fillRect(camX - width, SEA_LEVEL, width * 3, height + 1000);

    const grad = ctx.createLinearGradient(0, SEA_LEVEL, 0, SEA_LEVEL + 600);
    grad.addColorStop(0, 'rgba(2, 132, 199, 0.1)');
    grad.addColorStop(1, 'rgba(12, 74, 110, 0.95)');
    ctx.fillStyle = grad;
    ctx.fillRect(camX - width, SEA_LEVEL, width * 3, height + 1000);

    // Shiny Waves
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
    ctx.lineWidth = 2;

    const startX = Math.floor((camX - width) / 50) * 50;
    const endX = camX + width * 2;

    for (let y = SEA_LEVEL; y < SEA_LEVEL + 500; y += 30) {
      const parallax = (y - SEA_LEVEL) * 0.05 + 0.1;
      const offset = Math.sin(y * 0.1 + frame * 0.02) * 20;

      ctx.beginPath();
      for (let x = startX; x < endX; x += 80) {
        const waveH = Math.sin(x * 0.01 + frame * 0.04 + y) * 4;
        const drawX = x + offset;
        ctx.moveTo(drawX, y + waveH);
        ctx.lineTo(drawX + 40, y + waveH);
      }
      ctx.stroke();
    }

    ctx.strokeStyle = '#7dd3fc';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(camX - width, SEA_LEVEL);
    ctx.lineTo(camX + width * 2, SEA_LEVEL);
    ctx.stroke();
  };

  const drawReflections = (ctx: CanvasRenderingContext2D, player: Plane, enemies: Plane[]) => {
    ctx.save();
    ctx.beginPath();
    ctx.rect(gameRef.current.camera.x - 2000, SEA_LEVEL, 4000, 2000);
    ctx.clip();

    const entities = [player, ...enemies];
    entities.forEach(e => {
      if (e.dead) return;
      const dist = SEA_LEVEL - e.pos.y;
      if (dist < 0 || dist > 400) return;

      ctx.save();
      const refY = SEA_LEVEL + dist;
      ctx.translate(e.pos.x, refY);
      ctx.scale(1, -0.6);
      ctx.globalAlpha = 0.25 - (dist / 1200);
      drawJet(ctx, e, true); // Pass true for isReflection to avoid drawing detailed UI in reflection
      ctx.restore();
    });
    ctx.restore();
  };

  const drawJet = (ctx: CanvasRenderingContext2D, p: Plane, isReflection = false) => {
    ctx.save();
    ctx.translate(p.pos.x, p.pos.y);

    // HP Bar (Not in reflections)
    if (!isReflection && p.hp < p.maxHp) {
      ctx.save();
      ctx.fillStyle = 'rgba(0,0,0,0.5)';
      ctx.fillRect(-20, -45, 40, 4);
      ctx.fillStyle = p.hp < p.maxHp * 0.3 ? 'red' : '#22c55e';
      ctx.fillRect(-19, -44, 38 * (Math.max(0, p.hp) / p.maxHp), 2);
      ctx.restore();
    }

    ctx.rotate(p.angle);

    const mainColor = p.color;
    const isEnemy = p.team === 1;

    // --- JET DRAWING ---

    // Afterburner glow (Underneath)
    if (p.afterburner) {
      ctx.save();
      ctx.globalCompositeOperation = 'screen';
      ctx.shadowBlur = 15;
      ctx.shadowColor = '#f97316';
      ctx.fillStyle = 'rgba(255, 100, 0, 0.8)';
      ctx.beginPath();
      ctx.moveTo(-20, -3);
      ctx.lineTo(-45 - Math.random()*10, 0); // Flicker
      ctx.lineTo(-20, 3);
      ctx.fill();
      ctx.restore();

      // Heat distortion rings (Simplified)
      if (settings.highQuality && !isReflection && Math.random() > 0.5) {
        ctx.strokeStyle = 'rgba(255,255,255,0.3)';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.arc(-35, 0, 5 + Math.random()*3, 0, Math.PI*2);
        ctx.stroke();
      }
    }

    // Wings (Delta)
    ctx.fillStyle = mainColor;
    ctx.beginPath();
    ctx.moveTo(10, 0);
    ctx.lineTo(-15, -18); // Left Wing tip
    ctx.lineTo(-10, 0);
    ctx.lineTo(-15, 18);  // Right Wing tip
    ctx.fill();

    // Fuselage
    ctx.fillStyle = lightenColor(mainColor, 10);
    ctx.beginPath();
    ctx.moveTo(25, 0); // Nose
    ctx.lineTo(-20, -6);
    ctx.lineTo(-22, 6);
    ctx.fill();

    // Cockpit / Canopy
    ctx.fillStyle = '#0ea5e9'; // Glass Blue
    ctx.beginPath();
    ctx.ellipse(5, 0, 8, 3, 0, 0, Math.PI*2);
    ctx.fill();
    // Glint
    ctx.fillStyle = 'rgba(255,255,255,0.6)';
    ctx.beginPath();
    ctx.ellipse(7, -1, 3, 1, 0, 0, Math.PI*2);
    ctx.fill();

    // Tail fins
    ctx.fillStyle = darkenColor(mainColor, 20);
    ctx.beginPath();
    ctx.moveTo(-15, 0);
    ctx.lineTo(-28, -10);
    ctx.lineTo(-22, 0);
    ctx.lineTo(-28, 10);
    ctx.fill();

    // Weapon pods
    ctx.fillStyle = '#334155';
    ctx.fillRect(-5, -12, 10, 2);
    ctx.fillRect(-5, 10, 10, 2);

    ctx.restore();
  };

  const drawClouds = (ctx: CanvasRenderingContext2D, camX: number, camY: number, parallax: number, yOffset: number) => {
    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
    const cloudSpacing = 900;
    const startI = Math.floor((camX * parallax) / cloudSpacing) - 2;
    const endI = startI + 5;

    for(let i = startI; i < endI; i++) {
      const x = i * cloudSpacing;
      const y = yOffset + (Math.sin(i * 999) * 150) - (camY * parallax * 0.4);

      if (y < -400 || y > 1200) continue;

      const screenX = x - (camX * parallax);

      ctx.beginPath();
      // Flatter, stratus-like clouds for high altitude feel
      ctx.ellipse(screenX, y, 120, 40, 0, 0, Math.PI * 2);
      ctx.ellipse(screenX + 60, y - 20, 90, 50, 0, 0, Math.PI * 2);
      ctx.ellipse(screenX - 50, y + 10, 80, 30, 0, 0, Math.PI * 2);
      ctx.fill();
    }
  };

  // --- Helpers ---

  const shoot = (game: any, entity: Plane) => {
    entity.cooldown = BULLET_COOLDOWN;

    // Muzzle flash positions (Wing mounted guns)
    const offsets = [10, -10];
    offsets.forEach(off => {
      const bx = entity.pos.x + Math.cos(entity.angle) * 10 + Math.cos(entity.angle + Math.PI/2) * off;
      const by = entity.pos.y + Math.sin(entity.angle) * 10 + Math.sin(entity.angle + Math.PI/2) * off;

      game.particles.push(createParticle(bx, by, '#fff', 3, 4, 'spark'));

      game.bullets.push({
        id: Math.random().toString(),
                        pos: { x: bx, y: by },
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
    });
  };

  const createParticle = (x: number, y: number, color: string, life: number, size: number, type: 'fire' | 'smoke' | 'spark' | 'splash' | 'wake'): Particle => {
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
      if (Math.random() > 0.5) {
        game.particles.push(createParticle(x, y, '#f97316', 20 + Math.random() * 20, 10 + Math.random()*10, 'fire'));
      }
      game.particles.push(createParticle(x, y, '#334155', 40 + Math.random() * 40, 5 + Math.random()*15, 'smoke'));
      game.particles.push(createParticle(x, y, baseColor, 30 + Math.random() * 10, 3, 'spark'));
    }
    game.particles.push(createParticle(x, y, 'rgba(255,255,255,0.4)', 15, 60, 'smoke')); // Shockwave
  };

  const createSplash = (game: any, x: number, y: number, size: number) => {
    if (!settings.particles) return;
    for(let i=0; i<size; i++) {
      const p = createParticle(x, y, '#e0f2fe', 40, 4 + Math.random()*6, 'splash');
      p.velocity.y = -Math.random() * 6 - 2;
      p.velocity.x = (Math.random() - 0.5) * 8;
      game.particles.push(p);
    }
  };

  const checkCollision = (a: Entity, b: Entity) => {
    const dx = a.pos.x - b.pos.x;
    const dy = a.pos.y - b.pos.y;
    const dist = Math.sqrt(dx*dx + dy*dy);
    return dist < (a.radius + b.radius);
  };

  const lightenColor = (col: string, amt: number) => col;
  const darkenColor = (col: string, amt: number) => col;

  return <canvas ref={canvasRef} className="w-full h-full block" />;
};

export default GameCanvas;
