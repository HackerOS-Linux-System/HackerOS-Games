export enum GameState {
  MENU,
  BRIEFING,
  PLAYING,
  PAUSED,
  GAME_OVER
}

export enum EnemyType {
  GRUNT = 'grunt',
  ACE = 'ace',
  BOMBER = 'bomber'
}

export interface Vector2 {
  x: number;
  y: number;
}

export interface Entity {
  id: string;
  pos: Vector2;
  velocity: Vector2;
  angle: number; // in radians
  radius: number;
  dead: boolean;
}

export interface Plane extends Entity {
  type: 'player' | 'enemy';
  enemyType?: EnemyType; // Only for enemies
  hp: number;
  maxHp: number;
  cooldown: number;
  ammo: number;
  team: number; // 0 = player, 1 = enemy
  color: string;
  rotationSpeed: number; // Individual agility
  speedStat: number;     // Individual max speed
}

export interface Bullet extends Entity {
  team: number;
  life: number; // Frames remaining
}

export interface Particle extends Entity {
  color: string;
  life: number;
  maxLife: number;
  size: number;
  type: 'fire' | 'smoke' | 'spark';
}

export interface GameStats {
  score: number;
  wave: number;
  kills: number;
}

export interface GameSettings {
  difficulty: 'easy' | 'normal' | 'hard';
  showHitboxes: boolean;
  particles: boolean;
}
