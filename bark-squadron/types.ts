export enum GameState {
  MENU,
  BRIEFING,
  PLAYING,
  PAUSED,
  GAME_OVER,
  LEADERBOARD,
}

export enum EnemyType {
  GRUNT = 'grunt',
  ACE = 'ace',
  BOMBER = 'bomber',
}

export interface Vector2 {
  x: number;
  y: number;
}

export interface Entity {
  id: string;
  pos: Vector2;
  velocity: Vector2;
  angle: number;
  radius: number;
  dead: boolean;
}

export interface Plane extends Entity {
  type: 'player' | 'enemy';
  enemyType?: EnemyType;
  hp: number;
  maxHp: number;
  cooldown: number;
  ammo: number;
  team: number;
  color: string;
  rotationSpeed: number;
  speedStat: number;
  afterburner: boolean;
}

export interface Bullet extends Entity {
  team: number;
  life: number;
}

export interface Particle extends Entity {
  color: string;
  life: number;
  maxLife: number;
  size: number;
  type: 'fire' | 'smoke' | 'spark' | 'splash' | 'wake';
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
  highQuality: boolean;
  sensitivity: number;
  volume: number;
}

export interface HighScore {
  score: number;
  wave: number;
  kills: number;
  difficulty: string;
  timestamp: number;
}
