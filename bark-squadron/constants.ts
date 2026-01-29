// Physics - SLOWED DOWN for better control
export const GRAVITY = 0.05; // Reduced gravity
export const DRAG = 0.985;   // Slightly more drag
export const THRUST = 0.15;  // Reduced thrust
export const TURN_SPEED = 0.05; // Slower turning circle
export const MAX_SPEED = 5.5;   // Cap speed lower
export const MIN_SPEED = 1.5;   // Stall speed

// Combat
export const BULLET_SPEED = 9;
export const BULLET_LIFE = 80; 
export const BULLET_COOLDOWN = 12;
export const PLAYER_HP = 100;

// Enemy Stats
export const ENEMY_STATS = {
  grunt: { hp: 30, speed: 4.5, turn: 0.04, color: '#ef4444', size: 18 },
  ace: { hp: 50, speed: 6.0, turn: 0.07, color: '#a855f7', size: 16 },
  bomber: { hp: 120, speed: 3.0, turn: 0.02, color: '#166534', size: 24 }
};

// Dimensions
export const PLAYER_SIZE = 20; // Slightly larger hitbox
export const BULLET_SIZE = 3;

// Colors
export const COLOR_SKY_TOP = '#1e3a8a'; 
export const COLOR_SKY_BOTTOM = '#60a5fa';
export const COLOR_PLAYER = '#ffffff';
export const COLOR_BULLET_PLAYER = '#fbbf24'; 
export const COLOR_BULLET_ENEMY = '#f87171';
